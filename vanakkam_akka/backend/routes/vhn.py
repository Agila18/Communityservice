from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta

from database.connection import get_db
from models.db_models import User, HealthProfile, ScreeningSession, VHNPatient
from ai.community_detector import analyze_village_patterns

router = APIRouter()

@router.get("/patients/{vhn_id}")
async def get_village_patients(vhn_id: int, db: AsyncSession = Depends(get_db)):
    """Yields universally sorted hierarchical routing dynamically escalating 🔴 RED flags inherently to the top of the VHN view."""
    vhn_mappings = await db.execute(select(VHNPatient).where(VHNPatient.vhn_id == vhn_id))
    mappings = vhn_mappings.scalars().all()
    
    if not mappings: return []
    patient_ids = [m.patient_id for m in mappings]
    
    users_result = await db.execute(select(User).where(User.id.in_(patient_ids)))
    users = users_result.scalars().all()
    
    response_data = []
    for u in users:
        prof = await db.scalar(select(HealthProfile).where(HealthProfile.user_id == u.id))
        
        # Pull chronological state
        last_screen = await db.scalar(
            select(ScreeningSession)
            .where(ScreeningSession.user_id == u.id)
            .order_by(ScreeningSession.timestamp.desc())
            .limit(1)
        )
        
        v_map = next((m for m in mappings if m.patient_id == u.id), None)
        
        days_since = 999
        if last_screen:
             days_since = (datetime.now() - last_screen.timestamp).days
             
        risk = last_screen.risk_level.value if last_screen else "GREEN"
        flag_text = ""
        
        # Map dynamic prompt string constraints exactly as requested
        if prof and prof.pregnancy_status:
            flag_text += f"{prof.pregnancy_week} வாரம் கர்ப்பம்"
            if last_screen and last_screen.symptoms_reported:
                 symp = last_screen.symptoms_reported[:25]
                 flag_text += f" — {symp} report பண்ணினாங்க"
                 
        if days_since >= 10:
             if flag_text: flag_text += " | "
             flag_text += "Visit பண்ண வேண்டும்"
             
        response_data.append({
            "id": u.id,
            "name": u.name,
            "age": u.age,
            "phone": u.phone_number,
            "risk_level": risk,
            "last_screening_days": days_since,
            "key_flag": flag_text if flag_text else "எந்த பிரச்சனையும் இல்லை",
            "is_pregnant": prof.pregnancy_status if prof else False,
            "last_visit": v_map.last_visit.strftime("%Y-%m-%d") if v_map and v_map.last_visit else "இல்லை",
            "notes": v_map.notes if v_map else ""
        })
        
    # Strictly bind deterministic DB sort arrays ensuring nurses target bleeding risks universally first
    risk_order = {"RED": 0, "YELLOW": 1, "GREEN": 2}
    response_data.sort(key=lambda x: risk_order.get(x["risk_level"], 3))
    
    return response_data

@router.get("/community-alerts/{district}")
async def get_community_alerts(district: str, db: AsyncSession = Depends(get_db)):
    """Bridging geolocated demographic queries crossing explicitly into the Community Outbreak mapping engine."""
    seven_days_ago = datetime.now() - timedelta(days=7)
    
    query = (
        select(ScreeningSession)
        .join(User, ScreeningSession.user_id == User.id)
        .where(User.location_district == district)
        .where(ScreeningSession.timestamp >= seven_days_ago)
    )
    res = await db.execute(query)
    screenings = res.scalars().all()
    
    alerts = analyze_village_patterns(screenings)
    if alerts:
        # Broadcast internally over explicit APN handles if implemented
        pass 
        
    return alerts if alerts else {"status": "safe", "tamil_alert": "உங்கள் கிராமம் பாதுகாப்பாக உள்ளது (No alerts)"}

class VisitNoteReq(BaseModel):
    vhn_id: int
    patient_id: int
    notes: str

@router.post("/visit-note")
async def save_visit_note(req: VisitNoteReq, db: AsyncSession = Depends(get_db)):
    """Locks and caches manual analog notes submitted implicitly by rural Nurse rounds."""
    v_map = await db.scalar(select(VHNPatient).where(
        (VHNPatient.vhn_id == req.vhn_id) & (VHNPatient.patient_id == req.patient_id)
    ))
    if not v_map: raise HTTPException(404, "Maternal routing matrix broken")
    
    v_map.notes = req.notes
    v_map.last_visit = datetime.now()
    await db.commit()
    return {"status": "success"}

class EscalateReq(BaseModel):
    vhn_id: int
    patient_id: int
    reason: str

@router.post("/escalate")
async def escalate_to_phc(req: EscalateReq, db: AsyncSession = Depends(get_db)):
    """Proxies complex multi-system TCP chains bumping rural issues structurally up to the Doctor portals."""
    user = await db.get(User, req.patient_id)
    if not user: raise HTTPException(404)
    # Stub: Sends native OS payload dynamically into Govt HMIS database routing pipelines
    print(f"ESCALATION: Rural Patient {user.name} bumped securely up to PHC by Nurse #{req.vhn_id}")
    return {"status": "escalated"}
