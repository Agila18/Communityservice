# Contributing to Vanakkam Akka

Welcome! This is an academic research project — AI Health Platform for Rural Tamil Women.

## Project Overview

**Vanakkam Akka** is a comprehensive Tamil-language AI health platform designed specifically for rural women in Tamil Nadu. The project combines:

- **Flutter Mobile App**: Offline-first, voice-enabled interface with Tamil localization
- **FastAPI Backend**: AI-powered health screening, teleconsultation, and data management
- **AI Integration**: Gemini API for health analysis, Bhashini for Tamil NLP
- **Real-time Features**: Video consultations via Agora, Firebase messaging
- **VHN Mode**: Special interface for Village Health Nurses

## Core Features

### 🏥 Health Screening
- Voice-based symptom analysis in colloquial Tamil
- AI-powered triage system (GREEN/YELLOW/RED risk levels)
- Emergency routing for high-risk conditions
- Offline-first design for 2G connectivity

### 📱 Cycle Tracking
- Menstrual cycle monitoring with Tamil voice input
- Pregnancy risk detection
- Reminder system for supplements and medications

### 👩‍⚕️ Teleconsultation
- Video calls with healthcare providers via Agora
- Real-time Tamil transcription
- Medical record sharing
- Appointment scheduling

### 📋 Health Notebook
- Digital health records storage
- Lab result analysis with Tamil explanations
- PDF generation for clinical summaries
- Government scheme integration

### 🎯 VHN Mode
- Dedicated interface for Village Health Nurses
- Patient management dashboard
- Bulk messaging capabilities
- Analytics and reporting

## Prerequisites (install these first)

| Tool | Version | Download |
|------|---------|----------|
| Flutter | 3.16+ | flutter.dev |
| Android Studio | Latest | developer.android.com/studio |
| Python | 3.11+ | python.org |
| PostgreSQL | 15+ | postgresql.org |
| Git | Any | git-scm.com |

## Step 1 — Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/vanakkam-akka.git
cd vanakkam-akka
```

## Step 2 — Get your own API keys (all free)

You need your own keys — do not ask for mine.

| Key | Where to get | Time |
|-----|-------------|------|
| Firebase (all services) | console.firebase.google.com | 15 min |
| Gemini API | aistudio.google.com | 5 min |
| Bhashini API | bhashini.gov.in | 20 min |
| Agora Video SDK | agora.io | 10 min |
| MSG91 SMS | msg91.com | 5 min |

### Firebase Setup
1. Create new project: "vanakkam-akka-[your-name]"
2. Enable:
   - Authentication → Phone Sign-in
   - Cloud Firestore
   - Cloud Messaging
   - Storage
3. Download:
   - `google-services.json` → paste to `android/app/`
   - Service Account Key → save as `backend/serviceAccountKey.json`

### Gemini API Setup
1. Go to aistudio.google.com
2. Create API key
3. Copy key for .env file

### Bhashini API Setup
1. Register at bhashini.gov.in
2. Use purpose: "academic research, rural health, Tamil Nadu"
3. Wait for approval (1-2 days)
4. Alternative: Use Google Cloud Speech API while waiting

## Step 3 — Set up .env

```bash
cd backend
cp .env.example .env
# Open .env and fill in your keys
```

Required .env variables:
```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost/vanakkam_akka_db
GEMINI_API_KEY=YOUR_GEMINI_KEY_HERE
BHASHINI_API_KEY=YOUR_BHASHINI_KEY_HERE
BHASHINI_USER_ID=YOUR_BHASHINI_USER_ID
SECRET_KEY=any_long_random_string_minimum_32_chars
FIREBASE_CREDENTIALS=./serviceAccountKey.json
MSG91_API_KEY=YOUR_MSG91_KEY_HERE
AGORA_APP_ID=YOUR_AGORA_APP_ID
```

## Step 4 — Install dependencies

```bash
# Flutter dependencies
flutter pub get

# Python backend dependencies
cd backend
python -m venv venv

# macOS/Linux:
source venv/bin/activate

# Windows:
venv\Scripts\activate

pip install -r requirements.txt
```

## Step 5 — Set up database

```bash
# Create PostgreSQL database
createdb vanakkam_akka_db

# Run migrations
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
alembic upgrade head
```

## Step 6 — Update API configuration

Find your local IP address:
```bash
# macOS:
ifconfig | grep "inet " | grep -v 127

# Windows:
ipconfig
# Look for IPv4 Address — e.g. 192.168.1.8
```

Update the API base URL in `lib/shared/services/auth_service.dart`:
```dart
final Dio _dio = Dio(BaseOptions(baseUrl: 'http://YOUR_IP:8000/api/v1'));
```

## Step 7 — Run the app

Terminal 1 (backend):
```bash
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Terminal 2 (Flutter):
```bash
cd vanakkam_akka
flutter run
```

## Project Structure

```
vanakkam_akka/
├── lib/
│   ├── core/                 # App theme, localization, constants
│   ├── features/             # Feature modules
│   │   ├── screening/        # Health screening
│   │   ├── cycle_tracker/    # Menstrual cycle tracking
│   │   ├── teleconsult/      # Video consultations
│   │   ├── health_notebook/  # Health records
│   │   ├── reminders/        # Medication reminders
│   │   ├── nutrition/        # Nutrition guidance
│   │   └── vhn_mode/         # VHN dashboard
│   ├── models/               # Data models
│   └── shared/               # Shared services and widgets
├── backend/
│   ├── routes/               # API endpoints
│   ├── models/               # Database models
│   ├── ai/                   # AI/ML modules
│   └── database/             # Database setup
└── docs/                     # Documentation
```

## Common Errors and Solutions

| Error | Fix |
|-------|-----|
| `flutter: No Firebase App` | Add `google-services.json` to `android/app/` |
| `401 Unauthorized` | Check .env keys are correct and backend is running |
| `Connection refused` | Backend not running, or wrong IP in auth_service.dart |
| `relation does not exist` | Run: `alembic upgrade head` |
| `flutter doctor` shows ✗ | Paste error to AI for specific fix |
| `Bhashini API timeout` | Use Google Cloud Speech API as alternative |
| `Agora video not working` | Check AGORA_APP_ID in .env is correct |

## Development Guidelines

### Code Style
- Follow Flutter/Dart conventions
- Use Tamil strings for all user-facing text
- Keep functions small and well-documented
- Write tests for new features

### Tamil Localization
- All user-facing text must be in Tamil
- Use colloquial, rural-friendly language
- Test voice recognition with rural accents
- Include English translations in comments

### Offline-First Design
- Cache all critical data locally using Hive
- Implement sync queues for poor connectivity
- Test with 2G network conditions
- Handle network failures gracefully

### AI Integration
- Use deterministic rules for critical health decisions
- Implement fallback for ML failures
- Log all AI decisions for audit
- Never replace clinical judgment

## Testing

```bash
# Flutter tests
flutter test

# Python backend tests
cd backend
source venv/bin/activate
pytest
```

## API Documentation

Once backend is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Contributing Workflow

1. Fork the repository
2. Create feature branch: `git checkout -b feature-name`
3. Make changes with tests
4. Commit: `git commit -m "Add feature description"`
5. Push: `git push origin feature-name`
6. Create Pull Request

## Questions?

Paste any error to AI with context: 
"I'm running vanakkam_akka Flutter+Python project, got this error: [paste error]"

## Research Context

This is part of an academic research study on maternal health in rural Tamil Nadu. All contributions should align with:
- Rural accessibility requirements
- Tamil language preservation
- Offline-first constraints
- Clinical safety protocols
- Ethical AI practices

## License

This project is for academic research purposes. Please see LICENSE file for details.
