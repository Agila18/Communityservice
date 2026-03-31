from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import List, Optional
from datetime import date

from database.connection import get_db
from models.db_models import User, CycleEntry, FlowLevel
from ai.cycle_analyzer import analyze_cycle_pattern

router = APIRouter()

class PeriodLogRequest(BaseModel):
    user_id: int
    start_date: date
    flow_level: Optional[str] = "MEDIUM" # LIGHT, MEDIUM, HEAVY
    symptoms: Optional[List[str]] = []

@router.post("/period")
async def log_period(req: PeriodLogRequest, db: AsyncSession = Depends(get_db)):
    """Receives and stores deterministic menstrual log variables."""
    # Serialize Python arrays into comma-separated text blocks compliant with the DB schema
    symptoms_str = ", ".join(req.symptoms) if req.symptoms else ""
    
    # Robustly decode String enums back into SQLAlchemy Python Enum representations
    flow_enum = None
    if req.flow_level:
        try:
           flow_enum = FlowLevel[req.flow_level.upper()] 
        except KeyError:
           flow_enum = FlowLevel.MEDIUM
           
    entry = CycleEntry(
        user_id=req.user_id,
        start_date=req.start_date,
        flow_level=flow_enum,
        symptoms=symptoms_str
    )
    
    db.add(entry)
    await db.commit()
    return {"status": "success", "message": "Period cycle successfully persisted."}

@router.get("/analysis/{user_id}")
async def get_cycle_analysis(user_id: int, db: AsyncSession = Depends(get_db)):
    """Yields an algorithmic analysis mapping historical lengths utilizing the last 5 intervals."""
    result = await db.execute(
        select(CycleEntry)
        .where(CycleEntry.user_id == user_id)
        .order_by(CycleEntry.start_date.asc())
        .limit(5)
    )
    entries = result.scalars().all()
    
    if not entries:
        return {
            "avg_cycle_length": 0,
            "irregularity_flag": False,
            "pregnancy_probability": False,
            "recommendation_tamil": "எந்த தகவலும் இல்லை. மாத தேதியை பதிவு செய்யவும்."
        }
        
    # Funnel into the mathematical heuristic aggregator
    return analyze_cycle_pattern(entries)
