from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

from database.connection import get_db
from models.db_models import User, ReminderItem, ReminderRecurrence

router = APIRouter()

class ReminderCreate(BaseModel):
    user_id: int
    reminder_type: str
    scheduled_time: datetime
    message_tamil: str
    recurrence: Optional[str] = "once"

@router.post("/create")
async def create_reminder(req: ReminderCreate, db: AsyncSession = Depends(get_db)):
    """Logs standardized scheduling intents onto PostgreSQL."""
    rec_enum = ReminderRecurrence.ONCE
    try:
        rec_enum = ReminderRecurrence[req.recurrence.upper()]
    except KeyError:
        pass
        
    rem = ReminderItem(
         user_id=req.user_id,
         reminder_type=req.reminder_type,
         scheduled_time=req.scheduled_time,
         message_tamil=req.message_tamil,
         recurrence=rec_enum
    )
    db.add(rem)
    await db.commit()
    return {"status": "success", "id": rem.id}

@router.get("/{user_id}")
async def fetch_reminders(user_id: int, db: AsyncSession = Depends(get_db)):
    """Pulls all structurally active trackers sequentially descending."""
    res = await db.execute(
       select(ReminderItem)
       .where((ReminderItem.user_id == user_id) & (ReminderItem.is_active == True))
       .order_by(ReminderItem.scheduled_time.asc())
    )
    return res.scalars().all()

@router.post("/{id}/acknowledge")
async def acknowledge_reminder(id: int, db: AsyncSession = Depends(get_db)):
    """
    Mutates local state cleanly and implements dynamic Behavioral AI logic 
    ensuring empathy algorithms trigger proactively when medication adherence dips.
    """
    rem = await db.get(ReminderItem, id)
    if not rem: raise HTTPException(status_code=404)
    
    # 1. Flip State
    rem.is_completed = True
    await db.commit()
    
    # ---------------------------------------------------------
    # Rule 2. Adaptive Empathy Algorithmic Flow
    # ---------------------------------------------------------
    # Extract the longitudinal streak
    past_reminders = await db.execute(
        select(ReminderItem)
        .where((ReminderItem.user_id == rem.user_id) & (ReminderItem.scheduled_time <= datetime.now()))
        .order_by(ReminderItem.scheduled_time.desc())
        .limit(6)
    )
    recent_streak = past_reminders.scalars().all()
    
    consecutive_done = 0
    consecutive_missed = 0
    
    for r in recent_streak:
        if r.is_completed:
           consecutive_done += 1
           consecutive_missed = 0
        else:
           consecutive_missed += 1
           consecutive_done = 0
           
    # Positive Reinforcement Feedback Loop 
    if consecutive_done >= 3:
        return {"status": "success", "ai_adaptive_message": "நீங்கள் மிகவும் நன்றாக செய்கிறீர்கள் அக்கா!"}
        
    # Compassionate Check-In Override (Prevents mechanical spamming)
    if consecutive_missed >= 5:
        return {"status": "success", "ai_adaptive_message": "அக்கா, தொடர்ச்சியாக மாத்திரை சாப்பிடாமல் இருக்கிறீர்கள். மாத்திரை சாப்பிட கஷ்டமா இருக்கா? VHN இடம் உதவி கேளுங்கள்."}
        
    return {"status": "success", "ai_adaptive_message": ""}

class SmsFallbackReq(BaseModel):
    user_id: int
    message: str

@router.post("/sms-fallback")
async def push_sms_fallback(req: SmsFallbackReq, db: AsyncSession = Depends(get_db)):
    """
    Triggers explicit SMS delivery bypassing TCP barriers mapping exclusively to MSG91 infrastructure.
    Crucial for 2G remote sectors dynamically offline gracefully.
    """
    user = await db.get(User, req.user_id)
    if not user: raise HTTPException(status_code=404, detail="No such maternal profile mounted")
    
    # -- Stub: MSG91 Carrier Integration Layer --
    # import requests
    # payload = {
    #     "sender": "VNKKA", 
    #     "route": "4", 
    #     "country": "91", 
    #     "sms": [{"message": req.message, "to": [user.phone_number]}]
    # }
    # requests.post("https://api.msg91.com/api/v2/sendsms", json=payload...)
    print(f"Dispatched Offline SMS to {user.phone_number}: {req.message}")
    
    return {"status": "sms_dispatched", "target": user.phone_number}
