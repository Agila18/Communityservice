"""VHN (Village Health Nurse) mode routes — worker-facing features."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db

router = APIRouter()


@router.get("/dashboard")
async def vhn_dashboard(db: AsyncSession = Depends(get_db)):
    """VHN worker dashboard — overview of assigned patients."""
    # TODO: return patient list, pending screenings, alerts
    return {"patients_count": 0, "pending_screenings": 0, "alerts": []}


@router.get("/patients")
async def list_patients(db: AsyncSession = Depends(get_db)):
    """List all patients assigned to this VHN worker."""
    return {"patients": []}


@router.get("/patient/{patient_id}")
async def get_patient_summary(patient_id: str, db: AsyncSession = Depends(get_db)):
    """Get AI-generated health summary for a specific patient."""
    # TODO: aggregate screening, cycle, notebook data; run summarizer
    return {"patient_id": patient_id, "summary": {}}


@router.post("/patient/{patient_id}/flag")
async def flag_patient(patient_id: str, db: AsyncSession = Depends(get_db)):
    """Flag a patient for urgent follow-up."""
    return {"message": "நோயாளி அவசர பின்தொடர்தலுக்கு குறிக்கப்பட்டார்"}  # Patient flagged


@router.get("/reports")
async def generate_reports(db: AsyncSession = Depends(get_db)):
    """Generate village-level health reports for PHC submission."""
    # TODO: aggregate data, generate PDF report
    return {"report_url": ""}
