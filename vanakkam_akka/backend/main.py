"""
Vanakkam Akka — FastAPI Backend
Tamil-language AI health app for rural women in India.
"""

import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database.connection import init_db, close_db
from routes import (
    auth,
    screening,
    cycle,
    notebook,
    consultation,
    reminders,
    nutrition,
    vhn,
)

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
    title="Vanakkam Akka API",
    description=(
        "Backend API for the Vanakkam Akka health app — "
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
allowed_origins = os.getenv(
    "ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:8080"
).split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
API_PREFIX = "/api/v1"

app.include_router(auth.router,          prefix=f"{API_PREFIX}/auth",          tags=["Authentication"])
app.include_router(screening.router,     prefix=f"{API_PREFIX}/screening",     tags=["Health Screening"])
app.include_router(cycle.router,         prefix=f"{API_PREFIX}/cycle",         tags=["Cycle Tracker"])
app.include_router(notebook.router,      prefix=f"{API_PREFIX}/notebook",      tags=["Health Notebook"])
app.include_router(consultation.router,  prefix=f"{API_PREFIX}/consultation",  tags=["Teleconsultation"])
app.include_router(reminders.router,     prefix=f"{API_PREFIX}/reminders",     tags=["Reminders"])
app.include_router(nutrition.router,     prefix=f"{API_PREFIX}/nutrition",     tags=["Nutrition"])
app.include_router(vhn.router,           prefix=f"{API_PREFIX}/vhn",           tags=["VHN Mode"])

# ---------------------------------------------------------------------------
# Root health-check
# ---------------------------------------------------------------------------
@app.get("/", tags=["Health Check"])
async def root():
    return {
        "app": "Vanakkam Akka API",
        "status": "running",
        "version": "1.0.0",
        "message": "வணக்கம்! சேவையகம் இயங்குகிறது.",  # Server is running
    }


@app.get("/health", tags=["Health Check"])
async def health_check():
    return {"status": "healthy"}
