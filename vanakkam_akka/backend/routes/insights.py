"""Continuous Intelligence Layer — cross-module patterns (Cycle + Voice + Reminders)."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db
from ai.cross_module_analyzer import analyze_full_health_picture, HealthInsight

router = APIRouter()


@router.get("/{user_id}", response_model=HealthInsight)
async def get_cross_module_insights(user_id: int, db: AsyncSession = Depends(get_db)):
    """Aggregates screening, cycle, and reminder signals into one holistic insight."""
    return await analyze_full_health_picture(user_id, db)
