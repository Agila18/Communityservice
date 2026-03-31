"""Teleconsultation routes — video call booking and Agora token generation."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db

router = APIRouter()


@router.post("/book")
async def book_consultation(db: AsyncSession = Depends(get_db)):
    """Book a teleconsultation with a doctor."""
    # TODO: accept ConsultationBooking schema, match with available doctor
    return {"message": "சந்திப்பு பதிவு செய்யப்பட்டது", "booking_id": ""}  # Appointment booked


@router.get("/token/{channel_name}")
async def get_agora_token(channel_name: str):
    """Generate an Agora RTC token for video call."""
    # TODO: generate Agora token using app certificate
    return {"token": "", "channel": channel_name}


@router.get("/upcoming")
async def upcoming_consultations(db: AsyncSession = Depends(get_db)):
    """Get upcoming consultation appointments."""
    return {"consultations": []}


@router.get("/{consultation_id}")
async def get_consultation(consultation_id: str, db: AsyncSession = Depends(get_db)):
    """Get details of a specific consultation."""
    return {"consultation": {}}


@router.post("/{consultation_id}/notes")
async def add_doctor_notes(consultation_id: str, db: AsyncSession = Depends(get_db)):
    """Add doctor notes after a consultation (doctor-side)."""
    # TODO: save doctor notes, prescription, follow-up
    return {"message": "மருத்துவர் குறிப்புகள் சேமிக்கப்பட்டன"}  # Doctor notes saved
