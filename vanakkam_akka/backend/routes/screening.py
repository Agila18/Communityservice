from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import List, Dict

from database.connection import get_db
from models.db_models import User, HealthProfile, ScreeningSession
from ai.screener import process_screening_message

router = APIRouter()

class MessageRequest(BaseModel):
    user_id: int
    message: str
    conversation_history: List[Dict[str, str]]

@router.post("/message")
async def chat_message(req: MessageRequest, db: AsyncSession = Depends(get_db)):
    """Receives sequential voice dialog strings, pipes through LangChain AI, and persists complete sessions."""
    
    # Fetch base demographic traits
    result = await db.execute(select(User).where(User.id == req.user_id))
    user = result.scalar_one_or_none()
    
    user_profile = {
        "name": user.name if user else "அக்கா", 
        "age": user.age if user else 25,
        "is_pregnant": False,
        "pregnancy_week": 0
    }
    
    # Fetch specific reproductive/maternal status for accurate Triage Engine validation
    hp_result = await db.execute(select(HealthProfile).where(HealthProfile.user_id == req.user_id))
    health = hp_result.scalar_one_or_none()
    
    if health:
        user_profile["is_pregnant"] = health.pregnancy_status
        user_profile["pregnancy_week"] = health.pregnancy_week
    
    # Process through the AI Screener logic
    ai_result = await process_screening_message(req.message, req.conversation_history, user_profile)
    
    # Check if the AI determined a conclusive risk factor, triggering a DB pipeline persistence action
    if ai_result.get("is_complete"):
        # Combine the user utterances for raw storage
        reported_symptoms = " | ".join([m["content"] for m in req.conversation_history if m["role"] == "user"])
        reported_symptoms += f" | {req.message}"
        
        new_session = ScreeningSession(
            user_id=req.user_id,
            symptoms_reported=reported_symptoms,
            ai_response=ai_result["ai_response"],
            risk_level=ai_result["risk_level"],
            module="GENERAL_CHAT"
        )
        db.add(new_session)
        await db.commit()
        
    return ai_result
