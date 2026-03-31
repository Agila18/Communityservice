"""
Vanakkam Akka — SQLAlchemy ORM Models
All database tables for the health app backend.
"""

import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.connection import Base


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------
class RiskLevel(str, enum.Enum):
    GREEN = "GREEN"
    YELLOW = "YELLOW"
    RED = "RED"


class RecordType(str, enum.Enum):
    PRESCRIPTION = "prescription"
    LAB = "lab"
    SCAN = "scan"


class ConsultationStatus(str, enum.Enum):
    SCHEDULED = "scheduled"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class ReminderRecurrence(str, enum.Enum):
    ONCE = "once"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"


class FlowLevel(str, enum.Enum):
    SPOTTING = "spotting"
    LIGHT = "light"
    MEDIUM = "medium"
    HEAVY = "heavy"


# ---------------------------------------------------------------------------
# 1. User
# ---------------------------------------------------------------------------
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    phone_number: Mapped[str] = mapped_column(String(15), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    age: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    language_pref: Mapped[str] = mapped_column(String(5), default="ta")  # ta, en
    literacy_mode: Mapped[str] = mapped_column(String(10), default="voice")  # voice, text, hybrid
    location_district: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    password_hash: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    is_vhn: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relationships
    health_profile: Mapped[Optional["HealthProfile"]] = relationship(back_populates="user", uselist=False)
    screenings: Mapped[list["ScreeningSession"]] = relationship(back_populates="user")
    health_records: Mapped[list["HealthRecord"]] = relationship(back_populates="user")
    cycle_entries: Mapped[list["CycleEntry"]] = relationship(back_populates="user")
    reminders: Mapped[list["ReminderItem"]] = relationship(back_populates="user")
    consultations: Mapped[list["ConsultationSession"]] = relationship(
        back_populates="patient", foreign_keys="ConsultationSession.user_id"
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, name='{self.name}', phone='{self.phone_number}')>"


# ---------------------------------------------------------------------------
# 2. HealthProfile
# ---------------------------------------------------------------------------
class HealthProfile(Base):
    __tablename__ = "health_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    last_period_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    pregnancy_status: Mapped[bool] = mapped_column(Boolean, default=False)
    pregnancy_week: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    known_conditions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON string list
    num_pregnancies: Mapped[int] = mapped_column(Integer, default=0)
    blood_group: Mapped[Optional[str]] = mapped_column(String(5), nullable=True)
    height_cm: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    weight_kg: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relationships
    user: Mapped["User"] = relationship(back_populates="health_profile")

    def __repr__(self) -> str:
        return f"<HealthProfile(user_id={self.user_id}, pregnant={self.pregnancy_status})>"


# ---------------------------------------------------------------------------
# 3. ScreeningSession
# ---------------------------------------------------------------------------
class ScreeningSession(Base):
    __tablename__ = "screening_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    timestamp: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    module: Mapped[str] = mapped_column(String(50), nullable=False)  # maternal, menstrual, general, etc.
    symptoms_reported: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON list
    ai_response: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # full AI output
    risk_level: Mapped[RiskLevel] = mapped_column(Enum(RiskLevel), default=RiskLevel.GREEN)
    recommendation: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    referral_needed: Mapped[bool] = mapped_column(Boolean, default=False)

    # Relationships
    user: Mapped["User"] = relationship(back_populates="screenings")

    def __repr__(self) -> str:
        return f"<ScreeningSession(id={self.id}, risk={self.risk_level.value})>"


# ---------------------------------------------------------------------------
# 4. HealthRecord
# ---------------------------------------------------------------------------
class HealthRecord(Base):
    __tablename__ = "health_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    record_type: Mapped[RecordType] = mapped_column(Enum(RecordType), nullable=False)
    image_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    ocr_text: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # extracted text from image
    ai_explanation: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # AI summary in Tamil
    title: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    # Relationships
    user: Mapped["User"] = relationship(back_populates="health_records")

    def __repr__(self) -> str:
        return f"<HealthRecord(id={self.id}, type={self.record_type.value})>"


# ---------------------------------------------------------------------------
# 5. CycleEntry
# ---------------------------------------------------------------------------
class CycleEntry(Base):
    __tablename__ = "cycle_entries"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    flow_level: Mapped[Optional[FlowLevel]] = mapped_column(Enum(FlowLevel), nullable=True)
    symptoms: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON list
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    # Relationships
    user: Mapped["User"] = relationship(back_populates="cycle_entries")

    def __repr__(self) -> str:
        return f"<CycleEntry(id={self.id}, start={self.start_date})>"


# ---------------------------------------------------------------------------
# 6. ReminderItem
# ---------------------------------------------------------------------------
class ReminderItem(Base):
    __tablename__ = "reminder_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    reminder_type: Mapped[str] = mapped_column(String(50), nullable=False)  # medication, appointment, custom
    scheduled_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    message_tamil: Mapped[str] = mapped_column(Text, nullable=False)
    message_english: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    recurrence: Mapped[ReminderRecurrence] = mapped_column(Enum(ReminderRecurrence), default=ReminderRecurrence.ONCE)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    # Relationships
    user: Mapped["User"] = relationship(back_populates="reminders")

    def __repr__(self) -> str:
        return f"<ReminderItem(id={self.id}, type='{self.reminder_type}')>"


# ---------------------------------------------------------------------------
# 7. ConsultationSession
# ---------------------------------------------------------------------------
class ConsultationSession(Base):
    __tablename__ = "consultation_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    nurse_id: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    status: Mapped[ConsultationStatus] = mapped_column(
        Enum(ConsultationStatus), default=ConsultationStatus.SCHEDULED
    )
    scheduled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    pre_summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # AI-generated pre-call summary
    post_advice: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # Doctor/nurse notes after call
    agora_channel: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    duration_minutes: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    # Relationships
    patient: Mapped["User"] = relationship(back_populates="consultations", foreign_keys=[user_id])
    nurse: Mapped[Optional["User"]] = relationship(foreign_keys=[nurse_id])

    def __repr__(self) -> str:
        return f"<ConsultationSession(id={self.id}, status={self.status.value})>"


# ---------------------------------------------------------------------------
# 8. VHNPatient (Village Health Nurse assignment)
# ---------------------------------------------------------------------------
class VHNPatient(Base):
    __tablename__ = "vhn_patients"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    vhn_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    patient_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    last_visit: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    risk_flag: Mapped[RiskLevel] = mapped_column(Enum(RiskLevel), default=RiskLevel.GREEN)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    assigned_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    # Relationships
    vhn: Mapped["User"] = relationship(foreign_keys=[vhn_id])
    patient: Mapped["User"] = relationship(foreign_keys=[patient_id])

    def __repr__(self) -> str:
        return f"<VHNPatient(vhn={self.vhn_id}, patient={self.patient_id}, risk={self.risk_flag.value})>"
