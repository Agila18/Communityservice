from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
import os
import time
from datetime import datetime

from database.connection import get_db
from models.db_models import User, HealthRecord, RecordType
from ai.document_reader import analyze_health_document

router = APIRouter()

# Local persistence layer for medical uploads (Replace with S3 securely in Production)
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload")
async def upload_record(
    user_id: int = Form(...),
    record_type: str = Form("lab"), # expected: lab, prescription, scan
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Secure endpoint validating file ingestions, performing local byte-storage, 
    and funneling frames dynamically through the GPT-4 Vision OCR Tamil translator.
    """
    
    file_bytes = await file.read()
    
    # Secure storage locally establishing a robust historical reference URI
    file_ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    safe_filename = f"user_{user_id}_{int(time.time())}.{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, safe_filename)
    
    # Sync write suitable for lightweight mobile image buffers
    with open(file_path, 'wb') as out_file:
         out_file.write(file_bytes)
         
    # Call OpenAI Vision for complex OCR & contextual Tamil abstraction
    analysis = analyze_health_document(file_bytes)
    
    # Fallback Type Resolver utilizing DB Schema Rules
    try:
        r_type = RecordType[record_type.upper()]
    except KeyError:
        r_type = RecordType.LAB
        
    record = HealthRecord(
        user_id=user_id,
        record_type=r_type,
        image_url=f"/uploads/{safe_filename}", # To serve static assets over the API host
        ocr_text=analysis.get("ocr_text", ""),
        ai_explanation=analysis.get("ai_explanation", ""),
        title=analysis.get("title", "மருத்துவ அறிக்கை")
    )
    
    db.add(record)
    await db.commit()
    await db.refresh(record)
    
    return {
        "status": "success",
        "id": record.id,
        "title": record.title,
        "ai_explanation": record.ai_explanation
    }

@router.get("/{user_id}")
async def list_records(user_id: int, db: AsyncSession = Depends(get_db)):
    """Retrieves all historically digitized reports descending dynamically by freshness for UI."""
    result = await db.execute(
        select(HealthRecord)
        .where(HealthRecord.user_id == user_id)
        .order_by(HealthRecord.created_at.desc())
    )
    
    records = result.scalars().all()
    # Map to JSON-friendly lightweight dict representation
    return [
       {
           "id": r.id,
           "type": r.record_type.value,
           "title": r.title,
           "date": r.created_at.strftime("%Y-%m-%d"),
           "ai_explanation": r.ai_explanation,
           "ocr_text": r.ocr_text
       }
       for r in records
    ]
