from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import List, Dict

from database.connection import get_db
from models.db_models import User, HealthProfile, ScreeningSession, CycleEntry
from ai.screener import process_screening_message
from ai.cycle_analyzer import analyze_cycle_pattern

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
    
    # -------------------------------------------------------------------------
    # Rule Override: AI transition from period to pregnancy.
    # When period 12+ days late AND nausea reported in voice chat:
    # prompt for pregnancy test and trigger the UI transition state
    # -------------------------------------------------------------------------
    all_text_user = " ".join([m["content"] for m in req.conversation_history if m["role"] == "user"]) + " " + req.message
    
    if not user_profile["is_pregnant"] and any(w in all_text_user.lower() for w in ["வாந்தி", "nausea"]):
        # Fetch their actual cycle data securely to compute the 12+ day threshold accurately
        cycle_result = await db.execute(
            select(CycleEntry).where(CycleEntry.user_id == req.user_id).order_by(CycleEntry.start_date.asc()).limit(5)
        )
        cycle_data = cycle_result.scalars().all()
        
        # Analyze historical cycles computationally
        if cycle_data:
            analysis = analyze_cycle_pattern(cycle_data)
            # cycle_analyzer.py natively checks if > (avg + 10). Let's explicitly calculate > 12 days late.
            avg_len = analysis.get("avg_cycle_length", 28)
            from datetime import date
            days_since = (date.today() - cycle_data[-1].start_date).days
            if days_since > (avg_len + 12):
                return {
                    "ai_response": "அக்கா, pregnancy test எடுத்தீர்களா? PHC-ல் free-ல் கிடைக்கும்",
                    "is_complete": True,
                    "risk_level": "PREGNANCY_TRANSITION_PROMPT" # Flags UI to show the 'Yes/No' confirmation screen
                }
    
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
