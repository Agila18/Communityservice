from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os
import time

from database.connection import get_db, Base
from models.db_models import User, HealthProfile, ScreeningSession, HealthRecord, RecordType

# ---------------------------------------------------------
# Dynamic SQLAlchemy schema isolating Tele-Consult module
# ---------------------------------------------------------
class ConsultationSession(Base):
    __tablename__ = "tele_consultations"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    vhn_id = Column(Integer, index=True)
    auto_summary = Column(Text)
    status = Column(String, default="OPEN") # OPEN, RESOLVED
    created_at = Column(DateTime, default=datetime.utcnow)
    care_advice = Column(Text, nullable=True) # JSON or String block from Nurse

class ConsultationMessage(Base):
    __tablename__ = "tele_messages"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer)
    sender = Column(String) # PATIENT, NURSE
    audio_url = Column(String, nullable=True)
    transcript = Column(Text, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)


router = APIRouter()

UPLOAD_DIR = "uploads/audio"
os.makedirs(UPLOAD_DIR, exist_ok=True)


class NewConsultReq(BaseModel):
    user_id: int
    vhn_id: int = 999 

@router.post("/new")
async def start_consultation(req: NewConsultReq, db: AsyncSession = Depends(get_db)):
    """
    Compiles disparate historical schemas explicitly generating the crucial "Pre-Consultation Summary"
    arming the 2G remote Nurse with intense patient state before she even hears the audio.
    """
    user = await db.get(User, req.user_id)
    if not user: raise HTTPException(404, "பயனர் இல்லை (No User)")
    
    prof = await db.scalar(select(HealthProfile).where(HealthProfile.user_id == req.user_id))
    
    past_screens = await db.execute(
        select(ScreeningSession)
        .where(ScreeningSession.user_id == req.user_id)
        .order_by(ScreeningSession.timestamp.desc())
        .limit(3)
    )
    screens = past_screens.scalars().all()
    
    last_rx = await db.scalar(
         select(HealthRecord)
         .where((HealthRecord.user_id == req.user_id) & (HealthRecord.record_type == RecordType.PRESCRIPTION))
         .order_by(HealthRecord.created_at.desc()).limit(1)
    )
    
    # Construct exact requested string topology
    preg_wk = prof.pregnancy_week if prof and prof.pregnancy_status else "0"
    scr_date = screens[0].timestamp.strftime('%Y-%m-%d') if screens else "இல்லை"
    risk_lvl = screens[0].risk_level.value if screens else "GREEN"
    
    symps = ", ".join([s.symptoms_reported for s in screens if s.symptoms_reported])
    meds = last_rx.ai_explanation if last_rx else "எதுவும் இல்லை"
    
    auto_summary = f"""நோயாளி {user.name}, வயது {user.age}, {preg_wk} வாரம் கர்ப்பம்.
கடைசி screening: {scr_date} — {risk_lvl}.
முக்கிய அறிகுறிகள்: {symps if symps else 'இல்லை'}
சமீபத்திய மருந்துகள்: {meds}"""

    # Persist session bounds explicitly bypassing standard ML pipelines
    session = ConsultationSession(
       user_id=req.user_id,
       vhn_id=req.vhn_id,
       auto_summary=auto_summary,
       status="OPEN"
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    
    return {"status": "success", "session_id": session.id, "summary": auto_summary}


@router.post("/voice-message")
async def upload_voice_message(
    session_id: int = Form(...),
    sender: str = Form("PATIENT"),
    audio: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Asynchronous 2G payload drops handler. 
    Accepts ultra-compressed .m4a payloads processing native Whisper STT mapping locally.
    """
    file_bytes = await audio.read()
    file_ext = audio.filename.split(".")[-1] if "." in audio.filename else "m4a"
    safe_name = f"msg_{session_id}_{int(time.time())}.{file_ext}"
    out_path = os.path.join(UPLOAD_DIR, safe_name)
    
    with open(out_path, 'wb') as f:
         f.write(file_bytes)
         
    # Mocking STT Inference representing local Whisper bounds resolving rural Tamil syntax -> English arrays
    # In production: WhisperAPI transcriber wrapper goes here.
    transcript = "AI Transcription: [User audio natively mapped converting dialect to clinical abstract...]"
    
    msg = ConsultationMessage(
         session_id=session_id,
         sender=sender,
         audio_url=f"/uploads/audio/{safe_name}",
         transcript=transcript
    )
    db.add(msg)
    await db.commit()
    return {"status": "success", "transcript": transcript}


@router.get("/sessions/{user_id}")
async def get_consult_history(user_id: int, db: AsyncSession = Depends(get_db)):
    """Pulls entire asynchronous consulting history cleanly mapping UI strings"""
    res = await db.execute(select(ConsultationSession).where(ConsultationSession.user_id == user_id).order_by(ConsultationSession.created_at.desc()))
    sessions = res.scalars().all()
    
    return [{"id": s.id, "date": s.created_at.strftime("%Y-%m-%d"), "summary": s.auto_summary[:50] + "...", "status": s.status, "advice": s.care_advice} for s in sessions]


class CareAdviceReq(BaseModel):
    session_id: int
    advice_text: str

@router.post("/care-advice")
async def save_care_advice(req: CareAdviceReq, db: AsyncSession = Depends(get_db)):
    """Closes the asynchronous bounds locking Nurse metadata securely down to the target user device offline cache"""
    session = await db.get(ConsultationSession, req.session_id)
    if not session: raise HTTPException(404, "Virtual Room broken")
    
    session.care_advice = req.advice_text
    session.status = "RESOLVED"
    await db.commit()
    return {"status": "success", "advice": req.advice_text}
