"""Authentication routes — Firebase OTP login / registration via ID Token."""

from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
import os
import jwt
from datetime import datetime, timedelta

# Note: firebase_admin must be initialized externally in your main.py / app setup.
from firebase_admin import auth as firebase_auth

from database.connection import get_db
from models.db_models import User, HealthProfile

router = APIRouter()

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-jwt-secret-key-change-this")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))

class VerifyOTPRequest(BaseModel):
    id_token: str  # Firebase ID token sent from the Flutter client

@router.post("/verify-otp")
async def verify_otp(req: VerifyOTPRequest, db: AsyncSession = Depends(get_db)):
    """Verifies Firebase ID token, creates user if new, returns JWT token payload."""
    try:
        # Verify Firebase token with Google servers (Validates expiration, format, sig)
        decoded_token = firebase_auth.verify_id_token(req.id_token)
        phone_number = decoded_token.get("phone_number")
        
        if not phone_number:
            raise HTTPException(status_code=400, detail="Phone number absent in Firebase token.")
            
        # Check if user already exists
        result = await db.execute(select(User).where(User.phone_number == phone_number))
        user = result.scalar_one_or_none()
        
        is_new_user = False
        if not user:
            # Create a brand new user
            user = User(
                phone_number=phone_number,
                name="புதிய பயனர்", # "New User" in Tamil placeholder
                language_pref="ta"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            is_new_user = True
            
        # Generate application JWT session token
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode = {
            "sub": str(user.id), 
            "phone": phone_number, 
            "exp": expire
        }
        access_token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        
        return {
            "token": access_token,
            "user_id": user.id,
            "is_new_user": is_new_user
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"தவறான அங்கீகாரம் (Invalid Auth/Expired): {str(e)}"
        )

class ProfileSetupRequest(BaseModel):
    name: str
    age: int
    district: str
    literacy_mode: str
    health_conditions: list[str]

@router.post("/profile")
async def process_profile_setup(req: Request, profile_data: ProfileSetupRequest, db: AsyncSession = Depends(get_db)):
    """Resolves profile initialization appending HealthProfile models"""
    # Verify User Token
    auth_header = req.headers.get("Authorization")
    if not auth_header:
        raise HTTPException(status_code=401, detail="Missing Authorization Header")
        
    try:
        token = auth_header.split(" ")[1]
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub"))
    except Exception:
         raise HTTPException(status_code=401, detail="Invalid token")
         
    # Update Base App User Row
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not verified")
        
    user.name = profile_data.name
    user.age = profile_data.age
    user.location_district = profile_data.district
    user.literacy_mode = profile_data.literacy_mode
    
    # Generate associated health profile row
    cond_str = ", ".join(profile_data.health_conditions)
    result_hp = await db.execute(select(HealthProfile).where(HealthProfile.user_id == user.id))
    hp = result_hp.scalar_one_or_none()
    
    if hp:
        hp.known_conditions = cond_str
    else:
        hp = HealthProfile(
           user_id=user.id,
           known_conditions=cond_str,
           num_pregnancies=0
        )
        db.add(hp)
        
    await db.commit()
    return {"status": "success", "message": "Profile complete."}

# Kept for backward compatibility to retrieve current user status:
@router.get("/me")
async def get_current_user(db: AsyncSession = Depends(get_db)):
    """Get current authenticated user profile."""
    return {"message": "பயனர் விவரங்கள்"}  # User details stub
