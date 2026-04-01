from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from models.db_models import User, HealthProfile, ScreeningSession, CycleEntry, ReminderItem, HealthRecord, RecordType

class Flag(BaseModel):
    pattern_name: str
    description: str
    severity: str

class HealthInsight(BaseModel):
    overall_risk: str
    top_concern: str
    cross_module_flags: List[Flag]
    recommended_action: str
    vhn_alert_needed: bool
    personalized_message: str

async def analyze_full_health_picture(user_id: int, db: AsyncSession) -> HealthInsight:
    """
    The Intelligence Engine differentiating Vanakkam Akka fundamentally from standard symptom checkers.
    Cross-references disparate UI schemas (Cycle constraints, Pill tracking, Voice complaints) actively constructing a Unified Holistic Image.
    """
    thirty_days_ago = datetime.now() - timedelta(days=30)
    
    # 1. Scrape entire 30-Day history recursively across structural silos
    profile = await db.scalar(select(HealthProfile).where(HealthProfile.user_id == user_id))
    if not profile:
        profile = HealthProfile(pregnancy_status=False, pregnancy_week=0, postpartum_date=None)
        
    screenings_res = await db.execute(
        select(ScreeningSession)
        .where((ScreeningSession.user_id == user_id) & (ScreeningSession.timestamp >= thirty_days_ago))
        .order_by(ScreeningSession.timestamp.desc())
    )
    screenings = screenings_res.scalars().all()
    
    cycles_res = await db.execute(
        select(CycleEntry)
        .where((CycleEntry.user_id == user_id) & (CycleEntry.start_date >= thirty_days_ago.date()))
        .order_by(CycleEntry.start_date.desc())
    )
    cycles = cycles_res.scalars().all()
    
    reminders_res = await db.execute(
        select(ReminderItem)
        .where((ReminderItem.user_id == user_id) & (ReminderItem.scheduled_time >= thirty_days_ago))
    )
    reminders = reminders_res.scalars().all()
    
    recent_symptoms = " ".join([s.symptoms_reported for s in screenings if s.symptoms_reported]).lower()
    
    flags = []
    highest_risk = "GREEN"
    top_concern = "எந்த பிரச்சனையும் இல்லை (No immediate concerns)"
    vhn_alert = False
    action = "தொடர்ந்து நன்றாக கவனித்துக்கொள்ளுங்கள்"
    message = "அக்கா, நீங்கள் மிகவும் நன்றாக உங்கள் ஆரோக்கியத்தை பார்த்துக்கொள்கிறீர்கள். இதே போல தொடரவும்."
    
    # ===============================================================
    # PATTERN 1: Cycle Tracker (Late) + Voice Screening (Nausea)
    # ===============================================================
    if not profile.pregnancy_status:
        is_late = False
        if len(cycles) > 0:
            last_period = cycles[0].start_date
            if (datetime.now().date() - last_period).days > 35:
                is_late = True
        
        if is_late and any(w in recent_symptoms for w in ["வாந்தி", "nausea", "தலைசுற்றல்", "dizzy"]):
            flags.append(Flag(pattern_name="PREGNANCY_SUSPICION", description="மாதவிடாய் தள்ளிப்போயுள்ளது மற்றும் வாந்தி அறிகுறி உள்ளது.", severity="YELLOW"))
            if highest_risk == "GREEN": highest_risk = "YELLOW"
            top_concern = "கர்ப்பமாக இருக்க வாய்ப்பு உள்ளது"
            action = "PHC-ல் கர்ப்ப பரிசோதனை (Pregnancy Test) செய்யவும்"
            message = "அக்கா, உங்களுக்கு மாதவிடாய் தள்ளிப்போயுள்ளது, வாந்தியும் இருப்பதால், ஒரு வேளை நீங்கள் கர்ப்பமாக இருக்கலாம். மருத்துவமனையில் ஒரு டெஸ்ட் எடுக்கவும்."

    # ===============================================================
    # PATTERN 2: Pregnancy (Week 28+) + Voice (Headache/Swelling) -> Preeclampsia
    # ===============================================================
    if profile.pregnancy_status and profile.pregnancy_week >= 28:
        if any(w in recent_symptoms for w in ["தலைவலி", "headache", "கண் இருட்டு", "வீக்கம்", "swelling"]):
            flags.append(Flag(pattern_name="PREECLAMPSIA_RISK", description="கர்ப்ப காலத்தில் தலைவலி மற்றும் வீக்கம் - உயர் ரத்த அழுத்த ஆபத்து.", severity="RED"))
            highest_risk = "RED"
            vhn_alert = True
            top_concern = "உயர் ரத்த அழுத்த ஆபத்து (High BP)"
            action = "உடனடியாக PHC-க்கு செல்லவும்"
            message = "அக்கா, இந்த நேரத்தில் தலைவலியோ வீக்கமோ இருந்தால் அது ரத்த அழுத்தம் (BP) அதிகமாக இருப்பதை காட்டலாம். உடனே நர்ஸ் அக்காவிடம் பேசுங்கள்."

    # ===============================================================
    # PATTERN 3: Reminders (5+ Missed Iron) + Voice (Fatigue) -> Anemia Adherence
    # ===============================================================
    missed_iron = len([r for r in reminders if "iron" in r.reminder_type.lower() and not r.is_completed])
    if missed_iron >= 5 and any(w in recent_symptoms for w in ["சோர்வு", "fatigue", "மயக்கம்", "tired"]):
         flags.append(Flag(pattern_name="ANEMIA_ADHERENCE", description="இரும்பு மாத்திரை சரியாக எடுக்கவில்லை மற்றும் உடல் சோர்வு உள்ளது.", severity="YELLOW"))
         if highest_risk == "GREEN": highest_risk = "YELLOW"
         top_concern = "ரத்த சோகை ஆபத்து (Anemia)"
         vhn_alert = True
         action = "இரும்பு மாத்திரைகளை தவறாமல் எடுக்கவும்"
         message = "அக்கா, நீங்கள் இரும்பு மாத்திரையை சரிவர சாப்பிடவில்லை போலும். சோர்வாக இருந்தால் கண்டிப்பாக மாத்திரை சாப்பிட வேண்டும்."

    # ===============================================================
    # PATTERN 4: Screening (Repeated YELLOW) + No Consult booked -> Engagement Drop
    # ===============================================================
    yellow_count = len([s for s in screenings if s.risk_level.value == "YELLOW"])
    if yellow_count >= 2:
         flags.append(Flag(pattern_name="ENGAGEMENT_DROP", description="தொடர்ந்து மஞ்சள் ஆபத்து நிலை, ஆனால் மருத்துவரை நாடவில்லை.", severity="YELLOW"))
         if highest_risk == "GREEN": highest_risk = "YELLOW"
         top_concern = "மருத்துவ ஆலோசனை தேவை"
         vhn_alert = True
         action = "Tele-consultation மூலம் நர்ஸிடம் பேசுங்கள்"
         if highest_risk != "RED": # Don't override critical Preeclampsia text
             message = "அக்கா, உங்களுக்கு தொடர்ந்து சில தொந்தரவுகள் இருப்பது போல் தெரிகிறது. தயவுசெய்து நர்ஸ் அக்காவிடம் ஒரு முறை பேசவும்."

    # ===============================================================
    # PATTERN 5: Profile (Postpartum < 3mo) + Voice (Sad/Empty) -> Postpartum Depression
    # ===============================================================
    if profile.postpartum_date:
        days_pp = (datetime.now().date() - profile.postpartum_date).days
        if days_pp < 90 and any(w in recent_symptoms for w in ["கவலை", "அழுகை", "sad", "empty", "மன அழுத்தம்", "தூக்கமின்மை", "கண்ணீர்"]):
             flags.append(Flag(pattern_name="POSTPARTUM_DEPRESSION", description="குழந்தை பிறப்புக்குப் பின் மன அழுத்தம்.", severity="RED"))
             highest_risk = "RED"
             vhn_alert = True
             top_concern = "மனக்கவலை மற்றும் மன அழுத்தம் (PPD)"
             action = "VHN இடம் உதவி கேளுங்கள்"
             message = "அக்கா, குழந்தை பிறந்த பிறகு இப்படி கவலையாக இருப்பது சகஜம் தான். நீங்கள் தனியாக இல்லை. உங்களை புரிந்துகொள்ளும் VHN அக்காவிடம் இதைப்பற்றி பேசுங்கள்."

    insight = HealthInsight(
         overall_risk=highest_risk,
         top_concern=top_concern,
         cross_module_flags=flags,
         recommended_action=action,
         vhn_alert_needed=vhn_alert,
         personalized_message=message
    )
    return insight


async def run_daily_analysis_job(db: AsyncSession):
    """
    Scheduled daemon simulator natively bypassing standard HTTP pipelines. 
    Runs every 24 hours implicitly over the entire mapped rural Postgres dataset.
    """
    users = await db.execute(select(User))
    for user in users.scalars().all():
        try:
           # Pull the holistic matrix bridging all 4 application arrays
           insight = await analyze_full_health_picture(user.id, db)
           
           if insight.vhn_alert_needed and insight.overall_risk == "RED":
               # Mock: Force APN Notification trigger alerting the VHN actively mapped to this Village District
               print(f"CRITICAL SCHEDULED NOTIFICATION: User {user.id} requires immediate maternal intervention -> {insight.top_concern}")
               
           # Mock: Store Insight block statically updating User's Home Dashboard
        except Exception as e:
           # Log and continue loop safely preventing bad data from crashing the night processing run
           print(f"Cross-Module Failure targeting User ID {user.id}: {e}")
