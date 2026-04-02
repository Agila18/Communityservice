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
    try:
        # Validate input
        if not req.user_id or req.user_id <= 0:
            return {
                "status": "error", 
                "message": "Invalid user_id. Must be a positive integer.",
                "success": False
            }
        
        if not req.start_date:
            return {
                "status": "error", 
                "message": "start_date is required.",
                "success": False
            }
        
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
        return {
            "status": "success", 
            "message": "Period cycle successfully persisted.",
            "success": True,
            "data": {"entry_id": entry.id}
        }
    except Exception as e:
        await db.rollback()
        return {
            "status": "error",
            "message": f"Failed to save period data: {str(e)}",
            "success": False
        }

@router.get("/analysis/{user_id}")
async def get_cycle_analysis(user_id: int, db: AsyncSession = Depends(get_db)):
    """Yields an algorithmic analysis mapping historical lengths utilizing the last 5 intervals."""
    try:
        if not user_id or user_id <= 0:
            return {
                "avg_cycle_length": 0,
                "irregularity_flag": False,
                "pregnancy_probability": False,
                "recommendation_tamil": "சரியான பயனர் ID தேவை. (Valid user ID required.)",
                "success": False
            }
        
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
                "recommendation_tamil": "எந்த தகவலும் இல்லை. மாத தேதியை பதிவு செய்யவும்.",
                "success": True,
                "data_count": 0
            }
            
        # Funnel into the mathematical heuristic aggregator
        analysis = analyze_cycle_pattern(entries)
        analysis["success"] = True
        analysis["data_count"] = len(entries)
        return analysis
        
    except Exception as e:
        return {
            "avg_cycle_length": 28,
            "irregularity_flag": False,
            "pregnancy_probability": False,
            "recommendation_tamil": "பகுப்பாய்வில் பிழை. மீண்டும் முயற்சிக்கவும்.",
            "success": False,
            "error": str(e)
        }

@router.get("/pregnancy_data/{week}")
async def fetch_pregnancy_week_data(week: int):
    """
    Exposes the curated JSON database providing localized maternal guidance.
    Ensures safe boundary checks capping to 40 weeks.
    """
    try:
        if not week or week <= 0 or week > 40:
            return {
                "week": week,
                "size_comparison": "தவறான வாரம்",
                "tamil_message": "வாரம் 1-40 க்குள் இருக்க வேண்டும்",
                "warning": "",
                "action": "",
                "scheme_reminder": "",
                "success": False
            }
        
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
                     item["success"] = True
                     return item
                    
            # Fallback to first week if not found
            fallback = weeks_array[0] if weeks_array else {}
            fallback["success"] = True
            fallback["message"] = "தரவு இல்லாததால் முதல் வார தகவல் காட்டப்படுகிறது"
            return fallback
            
        except Exception as e:
            # Fallback dictionary simulating safe offline-cache behavior
            return {
               "week": week,
               "size_comparison": "தகவல் இல்லை",
               "tamil_message": "இணைய இணைப்பு இல்லை.",
               "warning": "",
               "action": "",
               "scheme_reminder": "",
               "success": False,
               "error": str(e)
            }
    except Exception as e:
        return {
            "week": week,
            "size_comparison": "தகவல் இல்லை",
            "tamil_message": "சேவை பிழை. மீண்டும் முயற்சிக்கவும்.",
            "warning": "",
            "action": "",
            "scheme_reminder": "",
            "success": False,
            "error": str(e)
        }
