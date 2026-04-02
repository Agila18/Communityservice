"""
Voice API Routes - Tamil Speech Recognition with Whisper
Handles audio transcription for Tamil speech and Tanglish
"""

from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import JSONResponse
from typing import Optional

from ai.whisper_service import whisper_service, TranscriptionResult, get_tamil_transcription_config
from database.connection import get_db

router = APIRouter()

@router.post("/transcribe", response_model=TranscriptionResult)
async def transcribe_audio(
    audio_file: UploadFile = File(...),
    language: str = "ta",
    task: str = "transcribe",
    db = Depends(get_db)
):
    """
    Transcribe audio file to Tamil text using Whisper
    
    Args:
        audio_file: Audio file (WAV, MP3, M4A, FLAC, AAC, OGG)
        language: Language code (ta for Tamil, en for English)
        task: "transcribe" (default) or "translate" (to English)
    
    Returns:
        TranscriptionResult with text and metadata
    
    Example:
        curl -X POST "http://localhost:8000/api/v1/voice/transcribe" \
             -F "audio_file=@speech.wav" \
             -F "language=ta"
    """
    # Validate language
    if language not in ["ta", "en", "auto"]:
        raise HTTPException(
            status_code=400, 
            detail="Language must be 'ta' (Tamil), 'en' (English), or 'auto'"
        )
    
    # Validate task
    if task not in ["transcribe", "translate"]:
        raise HTTPException(
            status_code=400,
            detail="Task must be 'transcribe' or 'translate'"
        )
    
    try:
        result = whisper_service.transcribe_audio(
            audio_file=audio_file,
            language=language if language != "auto" else None,
            task=task
        )
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "data": {
                    "text": result.text,
                    "language": result.language,
                    "confidence": result.confidence
                },
                "message": "Transcription completed successfully"
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Transcription service error: {str(e)}"
        )

@router.get("/config")
async def get_voice_config():
    """Get Tamil voice transcription configuration"""
    config = get_tamil_transcription_config()
    
    return JSONResponse(
        status_code=200,
        content={
            "success": True,
            "data": {
                "model": config["model"],
                "language": config["language"],
                "supported_formats": config["supported_formats"],
                "features": [
                    "Clear speech recognition",
                    "Conversational Tamil",
                    "Mixed Tamil + English (Tanglish)",
                    "Different accent support"
                ]
            }
        }
    )

@router.post("/health")
async def voice_health_check():
    """Check if Whisper service is healthy"""
    try:
        # Check if model is loaded
        if whisper_service.model is None:
            raise HTTPException(status_code=503, detail="Whisper model not loaded")
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "data": {
                    "status": "healthy",
                    "model": whisper_service.model_name,
                    "service": "Whisper Tamil Speech Recognition"
                }
            }
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Voice service unavailable: {str(e)}"
        )

@router.post("/test-tamil")
async def test_tamil_recognition(
    audio_file: UploadFile = File(...),
    db = Depends(get_db)
):
    """
    Test endpoint specifically for Tamil speech recognition
    Optimized for Tamil language with best settings
    """
    try:
        result = whisper_service.transcribe_audio(
            audio_file=audio_file,
            language="ta",  # Force Tamil for testing
            task="transcribe"
        )
        
        # Add Tamil-specific analysis and context-aware responses
        text = result.text.lower()
        
        # Check for Tamil characters
        has_tamil = any('\u0b80' <= char <= '\u0bff' for char in text)
        
        # Check for common Tamil words
        tamil_words = ["வணக்கம்", "அக்கா", "சேவை", "ஆரோக்கிய", "மருத்துவ", "சாத்தம்", "மருந்தை", "ஆரோக்கம்", "மருத்து"]
        has_tamil_words = any(word in text for word in tamil_words)
        
        # Generate context-aware response
        response_text = self._generate_health_response(text, has_tamil, has_tamil_words)
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "data": {
                    "transcription": result.text,
                    "language": result.language,
                    "confidence": result.confidence,
                    "analysis": {
                        "has_tamil_script": has_tamil,
                        "has_tamil_words": has_tamil_words,
                        "recommended_for_tamil": has_tamil or has_tamil_words
                    }
                },
                "response": response_text,
                "message": "Tamil transcription completed successfully"
            }
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Tamil transcription test failed: {str(e)}"
        )
