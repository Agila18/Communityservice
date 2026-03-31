"""
Vanakkam Akka — Pydantic request/response schemas.
Serialization layer between API and database models.
"""

from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Enums (mirrored from DB models for API layer)
# ---------------------------------------------------------------------------
class RiskLevelEnum(str, Enum):
    GREEN = "GREEN"
    YELLOW = "YELLOW"
    RED = "RED"


class RecordTypeEnum(str, Enum):
    PRESCRIPTION = "prescription"
    LAB = "lab"
    SCAN = "scan"


class FlowLevelEnum(str, Enum):
    SPOTTING = "spotting"
    LIGHT = "light"
    MEDIUM = "medium"
    HEAVY = "heavy"


class RecurrenceEnum(str, Enum):
    ONCE = "once"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"


# ---------------------------------------------------------------------------
# Auth / User
# ---------------------------------------------------------------------------
class UserCreate(BaseModel):
    phone_number: str = Field(..., min_length=10, max_length=15)
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=10, le=120)
    language_pref: str = Field(default="ta", pattern="^(ta|en)$")
    literacy_mode: str = Field(default="voice", pattern="^(voice|text|hybrid)$")
    location_district: Optional[str] = None
    password: str = Field(..., min_length=4)


class UserResponse(BaseModel):
    id: int
    phone_number: str
    name: str
    age: Optional[int]
    language_pref: str
    literacy_mode: str
    location_district: Optional[str]
    is_vhn: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


# ---------------------------------------------------------------------------
# Screening
# ---------------------------------------------------------------------------
class ScreeningStart(BaseModel):
    module: str = Field(..., description="Screening category: maternal, menstrual, general, etc.")


class ScreeningAnswer(BaseModel):
    session_id: int
    answer: str = Field(..., min_length=1)
    language: str = Field(default="ta")


class ScreeningResult(BaseModel):
    id: int
    module: str
    symptoms_reported: Optional[str]
    ai_response: Optional[str]
    risk_level: RiskLevelEnum
    recommendation: Optional[str]
    referral_needed: bool
    timestamp: datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Cycle Tracker
# ---------------------------------------------------------------------------
class CycleLogCreate(BaseModel):
    start_date: date
    end_date: Optional[date] = None
    flow_level: Optional[FlowLevelEnum] = None
    symptoms: Optional[str] = None  # comma-separated or JSON
    notes: Optional[str] = None


class CycleLogResponse(BaseModel):
    id: int
    start_date: date
    end_date: Optional[date]
    flow_level: Optional[FlowLevelEnum]
    symptoms: Optional[str]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Health Notebook
# ---------------------------------------------------------------------------
class NotebookEntryCreate(BaseModel):
    record_type: RecordTypeEnum
    title: Optional[str] = None
    notes: Optional[str] = None
    image_url: Optional[str] = None


class NotebookEntryResponse(BaseModel):
    id: int
    record_type: RecordTypeEnum
    title: Optional[str]
    image_url: Optional[str]
    ocr_text: Optional[str]
    ai_explanation: Optional[str]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Reminders
# ---------------------------------------------------------------------------
class ReminderCreate(BaseModel):
    reminder_type: str = Field(..., pattern="^(medication|appointment|custom)$")
    scheduled_time: datetime
    message_tamil: str
    message_english: Optional[str] = None
    recurrence: RecurrenceEnum = RecurrenceEnum.ONCE


class ReminderResponse(BaseModel):
    id: int
    reminder_type: str
    scheduled_time: datetime
    message_tamil: str
    is_completed: bool
    recurrence: RecurrenceEnum
    created_at: datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Consultation
# ---------------------------------------------------------------------------
class ConsultationBooking(BaseModel):
    preferred_time: Optional[datetime] = None
    pre_summary: Optional[str] = None  # patient's description of concern


class ConsultationResponse(BaseModel):
    id: int
    nurse_id: Optional[int]
    status: str
    scheduled_at: Optional[datetime]
    pre_summary: Optional[str]
    post_advice: Optional[str]
    duration_minutes: Optional[int]
    created_at: datetime

    model_config = {"from_attributes": True}
