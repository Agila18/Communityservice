"""Health notebook routes — personal health diary and records."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db

router = APIRouter()


@router.post("/entry")
async def create_entry(db: AsyncSession = Depends(get_db)):
    """Create a new health notebook entry (text, voice note, or image)."""
    # TODO: accept NotebookEntry schema, process voice-to-text if needed
    return {"message": "குறிப்பு சேமிக்கப்பட்டது", "entry_id": ""}  # Note saved


@router.get("/entries")
async def list_entries(db: AsyncSession = Depends(get_db)):
    """List all health notebook entries."""
    return {"entries": []}


@router.get("/entry/{entry_id}")
async def get_entry(entry_id: str, db: AsyncSession = Depends(get_db)):
    """Get a specific notebook entry."""
    return {"entry": {}}


@router.put("/entry/{entry_id}")
async def update_entry(entry_id: str, db: AsyncSession = Depends(get_db)):
    """Update an existing notebook entry."""
    return {"message": "குறிப்பு புதுப்பிக்கப்பட்டது"}  # Note updated


@router.delete("/entry/{entry_id}")
async def delete_entry(entry_id: str, db: AsyncSession = Depends(get_db)):
    """Delete a notebook entry."""
    return {"message": "குறிப்பு நீக்கப்பட்டது"}  # Note deleted


@router.get("/export")
async def export_notebook(db: AsyncSession = Depends(get_db)):
    """Export health notebook as PDF for doctor visits."""
    # TODO: generate PDF using reportlab
    return {"pdf_url": ""}
