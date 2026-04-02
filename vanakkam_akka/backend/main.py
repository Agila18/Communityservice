"""
Arogya — FastAPI Backend
Tamil-language AI health app for rural women in India.
"""

from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database.connection import init_db, close_db
from routes import (
    # screening_router,  # Temporarily disabled
    cycle_router,
    notebook_router,
    records_router,
    consultation_router,
    reminders_router,
    nutrition_router,
    vhn_router,
    insights_router,
    voice_router,
)

try:
    from routes.auth import router as auth_router
except ImportError:
    auth_router = None  # Optional: requires firebase_admin, PyJWT, etc.

load_dotenv()


# ---------------------------------------------------------------------------
# Lifespan – startup / shutdown hooks
# ---------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialise DB on startup; tear down on shutdown."""
    await init_db()
    yield
    await close_db()


# ---------------------------------------------------------------------------
# App instance
# ---------------------------------------------------------------------------
app = FastAPI(
    title="Arogya API",
    description=(
        "Backend API for the Arogya health app — "
        "AI-powered health screening, cycle tracking, teleconsultation, "
        "and nutrition guidance for rural women in Tamil Nadu."
    ),
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ---------------------------------------------------------------------------
# CORS – allow Flutter app, web dashboard, and dev servers
# ---------------------------------------------------------------------------
# Mobile / emulator clients use varying origins; keep permissive for local dev.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
API_PREFIX = "/api/v1"

if auth_router is not None:
    app.include_router(auth_router, prefix=f"{API_PREFIX}/auth", tags=["Authentication"])
# app.include_router(screening_router, prefix=f"{API_PREFIX}/screening", tags=["Health Screening"])  # Temporarily disabled
app.include_router(cycle_router, prefix=f"{API_PREFIX}/cycle", tags=["Cycle Tracker"])
app.include_router(notebook_router, prefix=f"{API_PREFIX}/notebook", tags=["Health Notebook"])
app.include_router(records_router, prefix=f"{API_PREFIX}/records", tags=["Health Records"])
app.include_router(consultation_router, prefix=f"{API_PREFIX}/consultation", tags=["Teleconsultation"])
app.include_router(reminders_router, prefix=f"{API_PREFIX}/reminders", tags=["Reminders"])
app.include_router(nutrition_router, prefix=f"{API_PREFIX}/nutrition", tags=["Nutrition"])
app.include_router(vhn_router, prefix=f"{API_PREFIX}/vhn", tags=["VHN Mode"])
app.include_router(insights_router, prefix=f"{API_PREFIX}/insights", tags=["AI Insights"])
app.include_router(voice_router, prefix=f"{API_PREFIX}/voice", tags=["Voice Recognition"])


# ---------------------------------------------------------------------------
# Root health-check
# ---------------------------------------------------------------------------
@app.get("/", tags=["Health Check"])
async def root():
    return {
        "app": "Vanakkam Akka API",
        "status": "running",
        "version": "1.0.0",
        "message": "வணக்கம்! சேவையகம் இயங்குகிறது.",
    }


@app.get("/health", tags=["Health Check"])
async def health_check():
    return {"status": "healthy"}
