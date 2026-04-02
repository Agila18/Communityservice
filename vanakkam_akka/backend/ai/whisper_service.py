"""
Whisper AI Service for Tamil Speech Recognition
Supports clear speech, conversational Tamil, and Tanglish (Tamil + English)
"""

import os
import tempfile
import whisper as whisper_ai
from typing import Optional, Dict, Any
from fastapi import UploadFile, HTTPException
from pydantic import BaseModel

class TranscriptionResult(BaseModel):
    text: str
    language: str
    confidence: Optional[float] = None

class WhisperService:
    """Whisper-based Tamil speech recognition service"""
    
    def __init__(self, model_name: str = "base"):
        """
        Initialize Whisper service
        
        Args:
            model_name: Model size (tiny, base, small, medium, large)
                        Base model recommended for Tamil + speed balance
        """
        self.model_name = model_name
        self.model = None
        self._load_model()
    
    def _load_model(self):
        """Load Whisper model"""
        try:
            self.model = whisper_ai.load_model(self.model_name)
            print(f"✅ Whisper model '{self.model_name}' loaded successfully")
        except Exception as e:
            print(f"❌ Failed to load Whisper model: {e}")
            raise HTTPException(status_code=500, detail="Failed to load speech recognition model")
    
    def transcribe_audio(
        self, 
        audio_file: UploadFile,
        language: str = "ta",
        task: str = "transcribe"
    ) -> TranscriptionResult:
        """
        Transcribe audio file to text using Whisper
        
        Args:
            audio_file: Uploaded audio file
            language: Language code (ta for Tamil, en for English)
            task: "transcribe" or "translate" (translate to English)
        
        Returns:
            TranscriptionResult with text and metadata
        """
        if not self.model:
            raise HTTPException(status_code=500, detail="Model not loaded")
        
        # Validate audio file
        if not audio_file.content_type or not audio_file.content_type.startswith('audio/'):
            raise HTTPException(status_code=400, detail="Invalid audio file format")
        
        try:
            # Save uploaded file to temporary location
            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
                content = audio_file.file.read()
                temp_file.write(content)
                temp_file_path = temp_file.name
            
            try:
                # Transcribe with Whisper
                result = self.model.transcribe(
                    temp_file_path,
                    language=language,  # "ta" for Tamil, ensures faster + accurate results
                    task=task,
                    fp16=False,  # Better compatibility
                    verbose=False
                )
                
                # Extract confidence if available
                confidence = None
                if 'segments' in result and result['segments']:
                    # Average confidence across segments
                    confidences = [seg.get('avg_logprob', 0) for seg in result['segments']]
                    confidence = sum(confidences) / len(confidences) if confidences else None
                
                return TranscriptionResult(
                    text=result['text'].strip(),
                    language=result.get('language', language),
                    confidence=confidence
                )
                
            finally:
                # Clean up temporary file
                os.unlink(temp_file_path)
                
        except Exception as e:
            print(f"❌ Transcription error: {e}")
            raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    
    def transcribe_base64(
        self,
        audio_data: bytes,
        language: str = "ta",
        task: str = "transcribe"
    ) -> TranscriptionResult:
        """
        Transcribe audio from base64 encoded data
        
        Args:
            audio_data: Raw audio bytes
            language: Language code
            task: transcribe or translate
        
        Returns:
            TranscriptionResult
        """
        if not self.model:
            raise HTTPException(status_code=500, detail="Model not loaded")
        
        try:
            # Save to temporary file
            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
                temp_file.write(audio_data)
                temp_file_path = temp_file.name
            
            try:
                result = self.model.transcribe(
                    temp_file_path,
                    language=language,
                    task=task,
                    fp16=False,
                    verbose=False
                )
                
                return TranscriptionResult(
                    text=result['text'].strip(),
                    language=result.get('language', language)
                )
                
            finally:
                os.unlink(temp_file_path)
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")

# Global service instance
whisper_service = WhisperService()

# Tamil-specific configurations
TAMIL_CONFIG = {
    "model": "base",  # Balance between accuracy and speed for Tamil
    "language": "ta",  # Tamil language code
    "supported_formats": [
        "audio/wav", "audio/mp3", "audio/m4a", 
        "audio/flac", "audio/aac", "audio/ogg"
    ]
}

def get_tamil_transcription_config() -> Dict[str, Any]:
    """Get Tamil-specific transcription configuration"""
    return TAMIL_CONFIG
