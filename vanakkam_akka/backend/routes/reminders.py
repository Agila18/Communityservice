"""Reminders routes — medication, appointment, and health check reminders."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db

router = APIRouter()


@router.post("/create")
async def create_reminder(db: AsyncSession = Depends(get_db)):
    """Create a new reminder (medication, appointment, or custom)."""
    # TODO: accept ReminderCreate schema, schedule notification
    return {"message": "நினைவூட்டல் உருவாக்கப்பட்டது", "reminder_id": ""}  # Reminder created


@router.get("/")
async def list_reminders(db: AsyncSession = Depends(get_db)):
    """List all active reminders."""
    return {"reminders": []}


@router.put("/{reminder_id}")
async def update_reminder(reminder_id: str, db: AsyncSession = Depends(get_db)):
    """Update a reminder."""
    return {"message": "நினைவூட்டல் புதுப்பிக்கப்பட்டது"}  # Reminder updated


@router.delete("/{reminder_id}")
async def delete_reminder(reminder_id: str, db: AsyncSession = Depends(get_db)):
    """Delete a reminder."""
    return {"message": "நினைவூட்டல் நீக்கப்பட்டது"}  # Reminder deleted


@router.post("/{reminder_id}/snooze")
async def snooze_reminder(reminder_id: str):
    """Snooze a reminder by 15 minutes."""
    return {"message": "நினைவூட்டல் ஒத்திவைக்கப்பட்டது"}  # Reminder snoozed
