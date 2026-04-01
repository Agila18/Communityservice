from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
import os
import time

from database.connection import get_db
from models.db_models import HealthRecord, RecordType
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

class AnalyzeRequest(BaseModel):
    extracted_text: str

@router.post("/analyze")
async def analyze_ocr(req: AnalyzeRequest):
    """
    Ingests raw computationally cheap OCR representations processed fully natively off phone CPU.
    Takes the resultant block and strictly structures it converting doctor shorthand -> simple localized Tamil.
    """
    chat = ChatOpenAI(
        model="gpt-4o-mini",
        max_tokens=400,
        temperature=0.2,
        api_key=os.getenv("OPENAI_API_KEY", "dummy")
    )
    
    sys_prompt = """This is a medical report/prescription for a rural Tamil woman. 
Extract key values and explain in very simple Tamil as if talking to someone with no medical education. 
Use 'உங்கள்' (your) language. For prescriptions: explain each medicine name, when to take, what it is for. 
For lab reports: explain each value in simple terms, flag anything abnormal.

Return exactly this JSON:
{
  "extracted_text": "<Brief English Summary>",
  "tamil_explanation": "<Simple Tamil explanation. Use bullet points if multiple medicines.>",
  "detected_values": {"key": "value"},
  "flags": ["list of abnormal flags if any"]
}"""

    try:
        msg = chat.invoke([
            HumanMessage(content=[
                {"type": "text", "text": sys_prompt},
                {"type": "text", "text": req.extracted_text}
            ])
        ])
        
        # Cleanup output constraints
        clean_json = msg.content.strip()
        if clean_json.startswith("```json"): clean_json = clean_json[7:]
        if clean_json.endswith("```"): clean_json = clean_json[:-3]
            
        import json
        return json.loads(clean_json.strip())
        
    except Exception as e:
        return {
           "extracted_text": req.extracted_text[:100],
           "tamil_explanation": "மன்னிக்கவும், ரிப்போர்ட்டை என்னால் முழுமையாக படிக்க முடியவில்லை. முக்கிய வார்த்தைகள் கிடைக்கவில்லை.",
           "detected_values": {},
           "flags": []
        }

@router.post("/upload")
async def upload_notebook_record(
    user_id: int = Form(...),
    record_type: str = Form("lab"),
    ocr_text: str = Form(""),
    ai_explanation: str = Form(""),
    title: str = Form("மருத்துவ பதிவு"),
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """Finalizes and solidifies the verified record structurally committing media to offline backup folders."""
    file_bytes = await file.read()
    file_ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    safe_name = f"user_{user_id}_{int(time.time())}.{file_ext}"
    out_path = os.path.join(UPLOAD_DIR, safe_name)
    
    with open(out_path, 'wb') as out_file:
         out_file.write(file_bytes)
         
    try:
        r_type = RecordType[record_type.upper()]
    except:
        r_type = RecordType.LAB
        
    record = HealthRecord(
        user_id=user_id,
        record_type=r_type,
        image_url=f"/uploads/{safe_name}",
        ocr_text=ocr_text,
        ai_explanation=ai_explanation,
        title=title
    )
    
    db.add(record)
    await db.commit()
    await db.refresh(record)
    
    return {"status": "success", "id": record.id}

@router.post("/generate-summary/{user_id}")
async def generate_visit_summary(user_id: int, db: AsyncSession = Depends(get_db)):
    """Pulls isolated modules globally constructing a dense bilingual clinical snapshot."""
    from models.db_models import User, HealthProfile, ScreeningSession
    
    # 1. Extract unified User Demographics & Health Profiles
    user = await db.scalar(select(User).where(User.id == user_id))
    profile = await db.scalar(select(HealthProfile).where(HealthProfile.user_id == user_id))
    
    # 2. Extract most recent Conversational Diagnostic Flags
    last_screening = await db.scalar(
        select(ScreeningSession)
        .where(ScreeningSession.user_id == user_id)
        .order_by(ScreeningSession.timestamp.desc())
        .limit(1)
    )
    
    # 3. Extract latest active OCR medications
    last_rx = await db.scalar(
        select(HealthRecord).where(
             (HealthRecord.user_id == user_id) & (HealthRecord.record_type == RecordType.PRESCRIPTION)
        ).order_by(HealthRecord.created_at.desc()).limit(1)
    )
    
    # 4. Extract latest Biochemical Lab findings
    last_lab = await db.scalar(
        select(HealthRecord).where(
             (HealthRecord.user_id == user_id) & (HealthRecord.record_type == RecordType.LAB)
        ).order_by(HealthRecord.created_at.desc()).limit(1)
    )
    
    # Generative AI summarization synthesizing raw boolean flags into fluid clinical Tamil prose
    import os
    from langchain_openai import ChatOpenAI
    from langchain_core.messages import HumanMessage
    
    chat = ChatOpenAI(model="gpt-4o-mini", temperature=0.1, max_tokens=300, api_key=os.getenv("OPENAI_API_KEY", "dummy"))
    
    symptoms_str = last_screening.symptoms_reported if last_screening else "எந்த அறிகுறியும் இல்லை"
    
    sys_prompt = f"""You are an expert rural healthcare AI summarizing a patient file for a doctor.
Patient Data:
- Symptoms: {symptoms_str}
- Latest Lab values/comments: {last_lab.ocr_text if last_lab else 'Not available'}
- Pregnancy status: {'Pregnant' if profile and profile.pregnancy_status else 'Not pregnant'}

Task: 
Write ONE short descriptive paragraph summarizing their current health condition exclusively in simple conversational rural Tamil.
Do not use bullet points. Limit to 3-4 sentences mapping their primary complaints directly alongside their blood tests if available.
Example Output: 'இந்த நோயாளி 5 மாத கர்ப்பிணியாக உள்ளார். கடைசியாக வாந்தி மற்றும் தலைசுற்றல் என்று கூறியுள்ளார். ரத்த சோகை உள்ளதால் இரும்புச்சத்து மாத்திரை எடுத்து வருகிறார்.' 
"""
    try:
        msg = chat.invoke(sys_prompt)
        summary_tamil = msg.content.strip()
    except:
        summary_tamil = "தகவல்களை ஒருங்கிணைக்க முடியவில்லை."
    
    # Construct bilingual JSON payload returning cleanly shaped boundaries
    return {
       "user_name": user.name if user else "Akka",
       "user_age": user.age if user else 0,
       "district": user.location_district if user else "Tamil Nadu",
       "pregnancy_week": profile.pregnancy_week if profile and profile.pregnancy_status else None,
       "risk_level": last_screening.risk_level.value if last_screening else "GREEN",
       "latest_symptoms": symptoms_str,
       "ai_summary_tamil": summary_tamil,
       "latest_prescription": {"explanation": last_rx.ai_explanation} if last_rx else None,
       "latest_lab": {"explanation": last_lab.ai_explanation} if last_lab else None,
    }
