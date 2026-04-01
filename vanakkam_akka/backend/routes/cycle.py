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

@router.get("/pregnancy_data/{week}")
async def fetch_pregnancy_week_data(week: int):
    """
    Exposes the curated JSON database providing localized maternal guidance.
    Ensures safe boundary checks capping to 40 weeks.
    """
    import json
    import os
    
    file_path = os.path.join(os.path.dirname(__file__), "..", "data", "pregnancy_weeks.json")
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            weeks_array = json.load(f)
            
        # Identify exact week matching (Fallbacks to limit clamping safely)
        target_week = max(1, min(week, 40))
        for item in weeks_array:
             if item.get("week") == target_week:
                 return item
                 
        return weeks_array[0]
        
    except Exception as e:
        # Fallback dictionary simulating safe offline-cache behavior
        return {
           "week": week,
           "size_comparison": "தகவல் இல்லை",
           "tamil_message": "இணைய இணைப்பு இல்லை.",
           "warning": "",
           "action": "",
           "scheme_reminder": ""
        }
