# ஆரோக்யா (Arogya)

Tamil-language AI health app for rural women in India.

## Overview

Arogya is a comprehensive healthcare solution designed specifically for rural Tamil-speaking women, providing:
- AI-powered health screening
- Menstrual cycle tracking
- Pregnancy monitoring
- Voice-based interactions in Tamil
- Teleconsultation with healthcare providers
- Medication reminders
- Health record management

## Features

### 🏥 Health Screening
- AI-driven symptom analysis
- Risk assessment with color-coded alerts
- Tamil voice recognition for natural interaction

### 📱 Cycle Tracking
- Menstrual cycle monitoring
- Pregnancy week-by-week guidance
- Ovulation predictions

### 🗣️ Voice Interface
- Whisper AI for Tamil speech recognition
- Text-to-speech in Tamil
- Hands-free operation for low-literacy users

### 👩‍⚕️ Teleconsultation
- Video calls with Village Health Nurses (VHN)
- Audio message support for 2G networks
- Pre-consultation AI summaries

### 💊 Reminders
- Medication alerts with Tamil voice reminders
- ANC checkup notifications
- Custom health reminders

## Tech Stack

### Frontend (Flutter)
- Flutter 3.10.4+
- Provider for state management
- Dio for API calls
- Whisper voice service integration

### Backend (FastAPI)
- FastAPI with async SQLAlchemy
- PostgreSQL/SQLite database
- OpenAI Whisper for Tamil STT
- Gemini AI for health screening

### AI/ML Services
- Whisper AI for Tamil speech recognition
- Gemini for health screening
- Custom Tamil NLP processing

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4+
- Python 3.8+
- PostgreSQL (optional, SQLite for development)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd arogya
```

2. **Setup Flutter**
```bash
cd app
flutter pub get
flutter run
```

3. **Setup Backend**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

4. **Environment Setup**
```bash
cd backend
cp .env.example .env
# Edit .env with your configuration
```

## API Documentation

Once the backend is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Database

### Development (SQLite)
- Default: `arogya.db` (auto-created)

### Production (PostgreSQL)
```bash
# Create database
createdb arogya_db

# Run migrations
alembic upgrade head
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team

---

**ஆரோக்யா** - Your health companion in Tamil 🇮🇳