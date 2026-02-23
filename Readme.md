# 🌸 வணக்கம் அக்கா — AI-Powered Early Health Screening & Tele-Assistance Platform for Rural Women

> *A voice-first, Tamil-language, offline-capable AI health companion for rural women in Tamil Nadu, India.*

---

## 📌 Table of Contents

- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Who Is She? — User Persona](#who-is-she--user-persona)
- [Research Contribution](#research-contribution)
- [Core Architecture — The AI Brain](#core-architecture--the-ai-brain)
- [Feature Modules](#feature-modules)
- [Tamil AI Conversation Design](#tamil-ai-conversation-design)
- [Complete User Journey](#complete-user-journey)
- [Tech Stack](#tech-stack)
- [Flutter Setup — Step by Step](#flutter-setup--step-by-step)
- [Backend Setup](#backend-setup)
- [Project Folder Structure](#project-folder-structure)
- [Tamil-Specific Tech](#tamil-specific-tech)
- [Target Districts](#target-districts)
- [Government Scheme Integration](#government-scheme-integration)
- [Design Principles](#design-principles)
- [MVP Build Plan](#mvp-build-plan)
- [Academic Publishing Angles](#academic-publishing-angles)

---

## 🌟 Project Overview

**வணக்கம் அக்கா** ("Vanakkam Akka" — Hello, Elder Sister) is a software-only, AI-powered mobile health platform designed specifically for rural women in Tamil Nadu. It removes the literacy, language, distance, and awareness barriers that prevent early health screening and timely medical care.

The platform works as a **continuous AI health intelligence layer** — not a collection of disconnected features, but one intelligent system that connects dots across time, modules, and health events to build a living health picture for each woman.

**Platform Type:** Mobile Application (Android-first)  
**Primary Language:** Tamil (தமிழ்)  
**Target Region:** Rural Tamil Nadu, India  
**Primary Users:** Rural women aged 18–45  
**Build Context:** Research / Academic Project  
**Tech Stack:** Flutter + Python FastAPI + Bhashini AI

---

## 🔍 Problem Statement

Rural women in Tamil Nadu face a convergence of health barriers that existing systems fail to address:

| Barrier | Reality |
|---|---|
| **Language** | Medical information is in English or formal Tamil — not how she speaks |
| **Literacy** | Cannot read or type comfortably on a phone |
| **Distance** | Nearest PHC may be 20–40 km away |
| **Awareness** | Conditions like anemia, PCOS, postpartum depression go undetected for years |
| **Trust** | Formal medical settings feel intimidating and judgmental |
| **Connectivity** | 2G/3G patchy — apps that need internet fail her |
| **Culture** | Reproductive health is taboo — never discussed with a doctor |
| **Time** | She waits until symptoms are severe before seeking care |

**Key Statistics (Tamil Nadu / India):**
- 57% of rural Indian women are anemic (NFHS-5)
- Only 21% of rural women receive full antenatal care
- Postpartum depression is vastly underreported — culturally invisible
- Tamil Nadu's worst maternal health indicators are in Dharmapuri, Krishnagiri, Ramanathapuram, Villupuram, Vellore

---

## 👩 Who Is She? — User Persona

> She is the person we design every decision around.

- **Age:** 18–45, married early, 2–3 children
- **Phone:** Basic Android, ₹4,000–₹8,000 range, sometimes shared with husband
- **Language:** Tamil — rural dialect (Villupuram, Dharmapuri, Madurai region)
- **Literacy:** Studied till Class 5–8; reading is slow or uncomfortable
- **Connectivity:** 2G/3G — drops indoors, cuts out in monsoon
- **Health decisions:** Influenced by mother-in-law, husband, local dai (traditional midwife)
- **Trust anchor:** Knows her Village Health Nurse (VHN) by name
- **Never had:** A private, non-judgmental conversation about her reproductive health
- **Waits until:** Symptoms are severe before seeking care — partly distance, mostly guilt

**The app must feel like a trusted female friend — not a clinical tool.**

---

## 🎓 Research Contribution

This is an academic project with the following formal research framing:

### Primary Research Question
*"Design and evaluation of an offline-capable, multilingual, voice-first AI health screening system for low-literacy rural Tamil women in Tamil Nadu, India"*

### Research Contributions

**1. System Design Contribution**
Architecture of a cross-module AI health intelligence layer that connects symptom data, reproductive cycle data, health history, and behavioral signals into a longitudinal health picture.

**2. NLP Contribution**
Tamil conversational AI calibrated for rural dialect variation — distinguishing between Chennai Tamil, Madurai Tamil, and Tirunelveli rural Tamil in health contexts.

**3. UX/Accessibility Contribution**
Design framework for voice-first, icon-heavy, low-literacy health interfaces. Cultural calibration of AI responses for Tamil Nadu rural context.

**4. Public Health Contribution**
Mapping of app features to Tamil Nadu government schemes (Makkalai Thedi Maruthuvam, Muthulakshmi Reddy Scheme, SNEHA) and National Health Mission goals.

### Publication Targets
- ICDH (International Conference on Digital Health)
- IEEE EMBC (Engineering in Medicine and Biology Conference)
- ACM CHI (Human Factors in Computing Systems)
- Health Informatics Journal

---

## 🧠 Core Architecture — The AI Brain

The AI is not a chatbot sitting in one module. It is a **continuous intelligence layer** running across everything.

```
Every interaction  →  AI Brain  →  Richer health picture  →  Smarter responses
```

### What the AI Sees Across All Modules

| Source | What AI Extracts |
|---|---|
| **Voice Conversations** | Symptoms, emotional tone, frequency, new vs recurring |
| **Period Tracker** | Cycle irregularity trends, late period + symptom correlations |
| **Pregnancy Tracker** | Week-appropriate symptom flags, danger sign detection |
| **Health Notebook** | Prescription history, lab values, missed medicines |
| **Reminder Responses** | Adherence patterns, disengagement signals |
| **Nutrition Conversations** | Cumulative dietary pattern, deficiency risk over time |
| **Consultation History** | Full context brief for next doctor/nurse automatically |

### Cross-Module Pattern Detection

The AI connects dots that no single module can:

- Period tracker shows 2 missed periods → Voice chat mentions nausea → AI flags possible pregnancy
- Pregnancy tracker at Week 28 → Voice reports headache + swelling → AI flags preeclampsia risk
- Reminder system shows 5 missed iron tablets → AI opens a caring conversation, not just a re-alert
- Three women in same village report stomach symptoms → AI flags possible local food/water issue to VHN

---

## 📱 Feature Modules

### Module 1 — 🎙️ Voice AI Health Assistant

**The hero feature. The entire app lives or dies on this.**

A conversational AI that allows women to speak symptoms in natural Tamil. The AI listens, understands rural expressions, investigates with follow-up questions, and gives simple health guidance.

**What it does:**
- Accepts voice input in Tamil (ta-IN) — no typing required
- Understands natural rural Tamil expressions, not formal medical Tamil
- Asks 4–6 adaptive follow-up questions to understand context
- Detects emotional state alongside physical symptoms
- Generates a Health Signal Card: 🟢 Safe / 🟡 Monitor / 🔴 Urgent
- Gives plain-language Tamil response with a clear next action

**Why it matters:**  
Many rural women cannot type comfortably. Voice removes the literacy barrier completely. Speaking in her own dialect — "தலை சுத்துது," "வயிறு வலிக்குது," "அந்த நேரம் சரியா வரல" — makes the interaction feel natural and trusted.

**Emotional Intelligence Layer:**  
The AI doesn't just hear physical symptoms. When she says *"உடம்பு சோர்வா இருக்கு, கஷ்டமா இருக்கு"* (body feels tired, it's hard), the AI hears possible mental distress and gently pivots to a mental health check-in.

---

### Module 2 — 🌸 Women's Cycle & Pregnancy Tracker (Unified)

**One module, two states — seamlessly connected by AI.**

#### Period Tracker (State 1)
- Logs cycle dates by voice or tap
- AI watches patterns across 3–4 cycles and flags:
  - Cycle shortening/lengthening trends → hormonal issue possible
  - 2 missed periods + recent fatigue/nausea in voice chat → pregnancy query
  - Heavy bleeding + fatigue pattern → anemia risk connection
  - Consistently painful periods → possible endometriosis/fibroid flag

#### The Transition Moment
When late period + pregnancy-consistent symptoms are detected across modules, the AI gently asks:

> *"அக்கா, உங்கள் அறிகுறிகளை பார்க்கும்போது நீங்கள் கர்ப்பமாக இருக்கலாம். PHC-ல் pregnancy test எடுத்தீர்களா?"*

If yes → Pregnancy Tracker activates automatically with LMP date pre-filled.

#### Pregnancy Tracker (State 2)
- Week-by-week guidance in Tamil — one key message, one warning, one action
- AI cross-references reported symptoms against what's normal for current week
- Government test reminders (ANC checkups at 4, 6, 8 months — free at PHC)
- JSY (Janani Suraksha Yojana) and Muthulakshmi Reddy scheme benefit alerts
- Amma Maternity Kit collection reminder
- Seasonal risk awareness (heat/hydration in May–June, monsoon infections)
- Danger sign detection:
  - Week 28+ headache + swelling → preeclampsia flag 🔴
  - Reduced fetal movement → urgent flag 🔴
  - Severe vomiting past Week 14 → hyperemesis flag 🟡

---

### Module 3 — ⚠️ AI Risk Detection Engine

**Symptom-based only — no hardware required.**

Builds risk from five pure software inputs:

1. **Reported symptoms** — from voice conversations
2. **Pregnancy stage** — from tracker (Week 28 carries different risk than Week 10)
3. **Symptom history** — recurring? Worsening? Time pattern?
4. **Demographic context** — age, number of pregnancies, known conditions
5. **Behavioral signals** — missed reminders, reduced app engagement (possible depression indicator)

**Risk Output — Always a Triad:**

```
🔴 URGENT — உடனடியாக மருத்துவமனை போங்க

AI detected: கடுமையான தலைவலி + கால் வீக்கம் + 34 வாரம் கர்ப்பம்
What it may mean: [Plain Tamil — no diagnosis, no jargon]
What to do RIGHT NOW: இன்றே PHC / மருத்துவமனை போங்க
What to tell them: [Auto-generated Tamil summary to show doctor]
```

**Academically significant:** The decision logic is a formal, documented rule set + ML layer — publishable as a system design contribution.

---

### Module 4 — 📓 Digital Health Notebook

**The digital replacement for the paper MCP (Mother and Child Protection) card.**

**What it stores:**
- Photos of prescriptions, lab reports, scans
- Pregnancy records and ANC visit notes
- Vaccination records for self and children
- Consultation summaries from tele-consult sessions

**AI Layer on the Notebook:**
- Uploads prescription photo → OCR reads it → AI explains in simple Tamil:
  > *"இது இரும்பு மாத்திரை. காலையில் சாப்பிட்ட பிறகு சாப்பிட வேண்டும்."*
- Uploads lab report → AI reads hemoglobin value → cross-references pregnancy week → flags if below safe threshold
- Before a hospital visit → **Visit Summary Card** auto-generated in Tamil — she shows it to the doctor

**Offline first:** All records stored locally, sync when connected.

**Format note:** Mirrors government MCP card structure so doctors recognize it immediately.

---

### Module 5 — 👩‍⚕️ Village Health Nurse (VHN) Mode

> Tamil Nadu uniquely has Village Health Nurses at sub-centre level. This is called **VHN Mode**, not ASHA Mode.

**VHN's interface is a field tool — fast, list-based, offline-first.**

**What VHN sees:**
- Village list of 20–50 women, sorted by AI risk score
- Who needs a visit today (AI-prioritized)
- Which women haven't logged in 10+ days
- Alert: "Sunita (🔴) missed her 8-month checkup. Visit recommended today."

**What VHN can do:**
- Enter data on behalf of women who don't have smartphones
- Add home visit notes to a woman's permanent record
- Escalate a case directly to PHC doctor
- Conduct full screening on behalf of a woman (VHN speaks, enters answers)

**Community Pattern Detection (Novel Feature):**
> "3 பெண்கள் இந்த வாரம் வயிற்று வலி report பண்ணினார்கள் — local food/water issue possible. PHC-க்கு தெரிவிக்கவும்."

This AI sees across multiple women's data and detects local health trends — a genuine research contribution.

---

### Module 6 — 📞 Low-Internet Tele-Consult Mode

**Async-first. Built for 2G reality.**

Three consultation modes:

| Mode | When to Use | Bandwidth |
|---|---|---|
| **Async Voice Message** | Default — like a WhatsApp voice note to nurse | Very low |
| **Text Chat** | Type or voice-to-text, response within hours | Minimal |
| **Video Call** | Only when connectivity allows, low-bitrate | Medium |

**Before consultation:** AI auto-generates a **Pre-Consultation Summary** — her age, symptoms, screening result, relevant history. The professional sees this before responding. She never has to repeat herself.

**After consultation:** **Care Advice Card** generated — what to do, medicines mentioned, follow-up date. Saved to Health Notebook. Shareable as an image on WhatsApp for women without smartphones.

---

### Module 7 — 🥗 Nutrition Companion (Conversational)

**Not a static guide. An ongoing daily conversation.**

```
AI: "அக்கா, இன்று காலையில் என்ன சாப்பிட்டீர்கள்?"

She: "ரொட்டி, சாய்"

AI: "நல்லது அக்கா. கொஞ்சம் வெல்லம் அல்லது 
     கடலை சேர்க்க முடியுமா? உங்கள் ரத்தத்திற்கு 
     மிகவும் நல்லது — விலையும் குறைவுதான்."
```

**Locally-grounded:** AI knows Tamil Nadu's regional food landscape — what's affordable and available in Dharmapuri vs Ramanathapuram. No exotic superfood suggestions.

**Builds over time:** Not one meal, but a pattern across days. AI spots cumulative deficiency risk. Connects nutrition data to anemia screening results.

---

### Module 8 — ⏰ Smart Reminder System

**Voice-first. SMS fallback. AI-adaptive.**

Reminders for:
- Iron tablet, calcium, prescribed medicines
- ANC checkups, PHC visits, vaccination dates
- Water intake (heat season)
- Self follow-up ("Have your symptoms improved?")

**Voice reminder format:**
> *"அக்கா, இன்று இரும்பு மாத்திரை சாப்பிட மறந்துவிடாதீர்கள்!"*

**AI-adaptive behavior:**
- Acknowledges 3 days in a row → frequency reduces, AI celebrates:
  > *"அக்கா, நீங்கள் மிகவும் நல்லது செய்கிறீர்கள்!"*
- Misses 5 reminders in a row → AI opens a caring conversation, not just re-sends
- Culturally timed → mid-morning or post-lunch, not 9am during household work

**SMS fallback:** Works without internet — critical for low-RAM phones that force-close apps.

---

## 💬 Tamil AI Conversation Design

### Rural Tamil Vocabulary the AI Must Know

| Medical Term | What She Actually Says |
|---|---|
| Periods / Menstruation | "அந்த நேரம்" / "மாதம்" |
| Pregnancy | "குழந்தை இருக்கு" |
| Dizziness | "தலை சுத்துது" |
| Stomach pain | "வயிறு வலிக்குது" |
| Nausea | "வாந்தி மாதிரி இருக்கு" |
| Tired / Fatigued | "உடம்பு சோர்வா இருக்கு" |
| Swelling | "வீக்கம் இருக்கு" |
| Irregular periods | "சரியா வரல" |
| Heavy bleeding | "அதிகமா போகுது" |
| Headache | "தலை வலிக்குது" |

### Sample Conversation Flow 1 — Dizziness Screening

```
AI: "வணக்கம் அக்கா, இன்னைக்கு எப்படி இருக்கீங்க?"

She: "தலை சுத்துது"

AI: "எப்போ இருந்து தலை சுத்துது?
     சாப்பிட்ட பிறகா, இல்லை சாப்பிடுவதற்கு முன்னாடியா?"

She: "காலையிலே சாப்பிடல, அப்புறம் வந்துச்சு"

AI: "தூக்கம் சரியா வருதா?
     கை கால் குளிர்ச்சியா இருக்கா?"

She: "ஆமா, எப்பவும் குளிர்ச்சியா இருக்கு"

AI: "அக்கா, இந்த அறிகுறிகள் ரத்த சோகை இருக்கலாம்னு 
     காட்டுது. பயப்படாதீங்க — இது சரி பண்ணலாம். 
     நாளைக்கே PHC போய் ரத்த பரிசோதனை பண்ணிக்கோங்க. 
     நான் reminder வச்சுடுறேன்."

     [🟡 Risk Card Generated]
     [Reminder set: Tomorrow 9AM — PHC visit]
```

### Sample Conversation Flow 2 — Late Period → Possible Pregnancy

```
AI: "அக்கா, இந்த மாசம் மாதவிடாய் வந்துச்சா?"

She: "இல்ல, கொஞ்சம் லேட் ஆகுது"

AI: "எத்தனை நாள் ஆச்சு?"

She: "பதினஞ்சு நாள் ஆயிடுச்சு"

AI: "காலையிலே வாந்தி மாதிரி feel ஆகுதா,
     இல்ல உடம்பு சோர்வா இருக்கா?"

She: "ஆமா, காலையிலே ரொம்ப சோர்வா இருக்கு"

AI: "அக்கா, pregnancy test எடுத்தீங்களா?
     PHC-ல போனா free-ல கிடைக்கும்.
     Makkalai Thedi Maruthuvam scheme-ல
     உங்க வீட்டுக்கே nurse வருவாங்க —
     அதுக்கு register பண்ணட்டுமா?"

     [Pregnancy Tracker activates if confirmed]
```

### Sample Conversation Flow 3 — Postpartum Mental Health

```
AI: "அக்கா, குழந்தை பிறந்து எத்தனை நாள் ஆச்சு?"

She: "ஒரு மாசம் ஆச்சு"

AI: "நல்லது அக்கா. நீங்க எப்படி feel பண்றீங்க —
     மனசு சந்தோஷமா இருக்கா?"

She: "தெரியல, ஏதோ வெறுமையா இருக்கு"

AI: "அக்கா, குழந்தை பிறந்த பிறகு இப்படி feel ஆவது 
     நிறைய பேருக்கு வருது — நீங்கள் மட்டும் இல்ல. 
     இதை யாரோட கூட share பண்றீங்களா?
     நம்மால் பேசலாம் — நீங்க சொல்றதை கேக்குறேன்."

     [Mental health check-in opens gently]
     [PHQ-9 adapted as Tamil conversation, not clinical form]
```

---

## 🔄 Complete User Journey — AI-Connected

```
She logs: Period 10 days late
          ↓
AI Voice Chat: "கடந்த மாசம் மாதவிடாய் வந்துச்சா?"
          ↓
She: "இல்ல. காலையில் உடம்பு சரியில்ல"
          ↓
AI: Possible pregnancy detected
Pregnancy Tracker activates | LMP auto-set
          ↓
Week-by-week Tamil guidance begins
JSY + Muthulakshmi Reddy scheme info shared
PHC ANC registration reminder set
          ↓
Week 28 — Voice chat: "தலை வலிக்குது, கால் வீக்கம் இருக்கு"
          ↓
AI Risk Engine: 🔴 URGENT
Possible preeclampsia indicators detected
VHN dashboard: Alert pushed instantly
          ↓
VHN visits her same day
Enters confirmation note via VHN Mode
          ↓
Async tele-consult booked with PHC nurse
Nurse sees AI summary: 28 weeks, headache 3 days,
swelling, prior BP history — full picture
          ↓
Consultation note + advice saved to Health Notebook
Reminder: PHC visit tomorrow | Bring MCP card
          ↓
Week 30 follow-up: "அக்கா, வீக்கம் குறைஞ்சுச்சா?"
```

**This is one continuous AI-connected story. Not 8 separate modules — one intelligent system.**

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Frontend** | Flutter (Dart) | Single codebase Android+iOS, runs on low-end phones, excellent offline support |
| **Backend** | Python + FastAPI | Async, fast, best AI/ML library ecosystem |
| **AI Screening** | Rule-based trees + Gemini/GPT-4 | Rule-based for predictable medical paths, LLM for open-ended conversation |
| **On-device AI** | Gemini Nano | Basic screening offline — no internet needed |
| **Tamil Voice** | Bhashini API + Google ML Kit | Bhashini for all 22 Indian languages, ML Kit for rural Tamil accent handling |
| **OCR (reports)** | Google ML Kit Text Recognition | On-device, offline, free |
| **Database (server)** | PostgreSQL | Reliable, relational, well-supported |
| **Database (device)** | Hive + SQLite | Offline-first local storage |
| **Async Chat** | WebSockets / Firebase Realtime DB | Real-time nurse messaging |
| **Voice Calls** | Twilio / Exotel | Exotel is India-optimized, low latency |
| **Video Calls** | Agora SDK | Adaptive bitrate — works on 2G/3G |
| **Auth** | Firebase Phone Auth (OTP) | No email/password — just phone number |
| **Notifications** | Firebase Cloud Messaging + SMS | SMS fallback via MSG91 for offline devices |
| **Tamil NLP** | AI4Bharat IndicNLP | Rural Tamil dialect corpus training |

---

## 📲 Flutter Setup — Step by Step

### Step 1 — Install Flutter

```bash
# macOS
brew install --cask flutter

# Windows
# Download Flutter SDK from https://flutter.dev
# Add C:\flutter\bin to your PATH environment variable

# Verify installation
flutter doctor
```

### Step 2 — Install Android Studio

Download from https://developer.android.com/studio

Create a low-end device emulator to simulate rural phone conditions:
- Device: Pixel 3a
- API Level: 30
- RAM: 2GB (simulate ₹5,000 phone)

### Step 3 — Create the Project

```bash
flutter create vanakkam_akka
cd vanakkam_akka
flutter run
```

### Step 4 — Install All Dependencies

Add to `pubspec.yaml`:

```yaml
name: vanakkam_akka
description: AI Health Platform for Rural Tamil Women

dependencies:
  flutter:
    sdk: flutter

  # ── Voice & Language ──────────────────────────
  flutter_tts: ^3.8.3               # Tamil TTS (ta-IN)
  speech_to_text: ^6.3.0            # Tamil STT (ta-IN)

  # ── Offline Storage ───────────────────────────
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  path_provider: ^2.1.1

  # ── Networking ────────────────────────────────
  dio: ^5.3.0
  web_socket_channel: ^2.4.0        # Real-time chat

  # ── Firebase ──────────────────────────────────
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0            # OTP login
  firebase_messaging: ^14.7.9       # Push notifications

  # ── Local Notifications ───────────────────────
  flutter_local_notifications: ^16.3.0

  # ── Video Consultation ────────────────────────
  agora_rtc_engine: ^6.3.0

  # ── OCR — Lab Report Reading ──────────────────
  google_mlkit_text_recognition: ^0.11.0

  # ── Camera & Image ────────────────────────────
  image_picker: ^1.0.7              # Lab report photo upload
  camera: ^0.10.5

  # ── UI & Navigation ───────────────────────────
  go_router: ^12.1.1
  provider: ^6.1.1

  # ── Localization ──────────────────────────────
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1

  # ── Share & Export ────────────────────────────
  share_plus: ^7.2.1                # Share Care Advice Card on WhatsApp
  pdf: ^3.10.7                      # Generate Visit Summary Card

  # ── Utilities ─────────────────────────────────
  connectivity_plus: ^5.0.2         # Detect online/offline state
  workmanager: ^0.5.2               # Background sync when online
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  flutter_lints: ^3.0.0
```

```bash
flutter pub get
```

### Step 5 — Configure Tamil Voice (Critical)

```dart
// lib/services/voice_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  Future<void> initTTS() async {
    await _tts.setLanguage('ta-IN');    // Tamil
    await _tts.setSpeechRate(0.8);      // Slower — clearer for rural users
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String tamilText) async {
    await _tts.speak(tamilText);
  }

  Future<void> initSTT() async {
    await _stt.initialize();
  }

  Future<String> listen() async {
    String result = '';
    await _stt.listen(
      localeId: 'ta_IN',              // Tamil locale
      onResult: (val) => result = val.recognizedWords,
    );
    return result;
  }
}
```

---

## ⚙️ Backend Setup

### Step 1 — Create Python Environment

```bash
mkdir backend && cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
```

### Step 2 — Install Dependencies

```bash
pip install fastapi uvicorn sqlalchemy psycopg2-binary \
            python-jose passlib openai google-generativeai \
            python-multipart pydantic alembic httpx \
            pillow pytesseract ai4bharat-transliteration
```

### Step 3 — PostgreSQL Setup

```bash
# macOS
brew install postgresql
brew services start postgresql
createdb vanakkam_akka_db

# Ubuntu
sudo apt install postgresql
sudo -u postgres createdb vanakkam_akka_db
```

### Step 4 — Environment Variables

Create `.env` in backend root:

```env
DATABASE_URL=postgresql://user:password@localhost/vanakkam_akka_db
OPENAI_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
BHASHINI_API_KEY=your_key_here
FIREBASE_CREDENTIALS=path/to/serviceAccountKey.json
TWILIO_SID=your_sid
TWILIO_AUTH=your_token
MSG91_API_KEY=your_key_here
SECRET_KEY=your_jwt_secret
```

### Step 5 — Run Backend

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

---

## 📁 Project Folder Structure

```
vanakkam_akka/
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── colors.dart           # Warm saffron/green palette
│   │   │   ├── text_styles.dart      # Large Tamil-readable fonts
│   │   │   └── accessibility.dart    # Icon size, contrast rules
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── localization/
│   │   │   ├── tamil_strings.dart    # All Tamil UI strings
│   │   │   └── l10n/app_ta.arb
│   │   └── sync/
│   │       └── offline_sync_manager.dart   # Queue → sync on connect
│   │
│   ├── features/
│   │   │
│   │   ├── onboarding/
│   │   │   ├── language_select.dart
│   │   │   ├── profile_setup.dart        # Voice input, icon-heavy
│   │   │   └── otp_login.dart
│   │   │
│   │   ├── screening/                    # 🎙️ Voice AI — Hero Module
│   │   │   ├── voice_chat_ui.dart
│   │   │   ├── screening_service.dart    # Bhashini + AI integration
│   │   │   ├── triage_engine.dart        # Risk classification logic
│   │   │   └── health_signal_card.dart   # 🟢🟡🔴 Result UI
│   │   │
│   │   ├── cycle_tracker/               # 🌸 Period + Pregnancy unified
│   │   │   ├── period_tracker.dart
│   │   │   ├── pregnancy_tracker.dart
│   │   │   ├── week_guide.dart           # Week-by-week Tamil guidance
│   │   │   ├── danger_sign_detector.dart
│   │   │   └── cycle_ai_bridge.dart      # AI cross-module connection
│   │   │
│   │   ├── health_notebook/             # 📓 Digital Records
│   │   │   ├── notebook_home.dart
│   │   │   ├── report_upload.dart        # Photo → OCR → AI explain
│   │   │   ├── ocr_service.dart
│   │   │   ├── visit_summary_card.dart   # Auto-generated for doctor
│   │   │   └── prescription_reader.dart
│   │   │
│   │   ├── teleconsult/                 # 📞 Async Consult
│   │   │   ├── consult_home.dart
│   │   │   ├── voice_message_chat.dart
│   │   │   ├── text_chat.dart
│   │   │   ├── video_call.dart           # Agora SDK
│   │   │   └── care_advice_card.dart
│   │   │
│   │   ├── reminders/                   # ⏰ Smart Reminders
│   │   │   ├── reminder_home.dart
│   │   │   ├── voice_reminder_service.dart
│   │   │   ├── sms_fallback.dart
│   │   │   └── adherence_tracker.dart    # AI adaptive behavior
│   │   │
│   │   ├── nutrition/                   # 🥗 Conversational Guide
│   │   │   ├── diet_chat.dart
│   │   │   ├── local_food_db.dart        # Tamil Nadu regional foods
│   │   │   └── anemia_diet_guide.dart
│   │   │
│   │   └── vhn_mode/                    # 👩‍⚕️ Village Health Nurse
│   │       ├── vhn_login.dart
│   │       ├── village_patient_list.dart
│   │       ├── risk_sorted_view.dart
│   │       ├── proxy_screening.dart      # VHN screens on behalf of woman
│   │       ├── visit_notes.dart
│   │       └── community_pattern_alert.dart  # AI cross-village detection
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── voice_button.dart         # Always visible mic
│       │   ├── icon_nav_bar.dart         # Icon-first navigation
│       │   ├── risk_card.dart
│       │   └── tamil_text.dart           # Pre-configured Tamil text widget
│       └── services/
│           ├── voice_service.dart        # TTS + STT
│           ├── ai_service.dart           # AI API client
│           ├── local_db_service.dart     # Hive operations
│           ├── sync_service.dart         # Online/offline sync
│           └── sms_service.dart          # MSG91 integration
│
│
backend/
├── main.py
├── .env
│
├── routes/
│   ├── auth.py                    # OTP login
│   ├── screening.py               # AI symptom conversation
│   ├── cycle.py                   # Period + Pregnancy data
│   ├── notebook.py                # Health records
│   ├── consultation.py            # Tele-consult
│   ├── reminders.py               # Reminder management
│   ├── nutrition.py               # Diet conversation
│   └── vhn.py                     # VHN dashboard APIs
│
├── ai/
│   ├── screener.py                # LLM symptom conversation
│   ├── triage_engine.py           # Risk classification rules + ML
│   ├── summarizer.py              # Pre-consultation summary
│   ├── tamil_nlp.py               # Bhashini + IndicNLP integration
│   ├── cross_module_analyzer.py   # AI brain — connects all modules
│   └── community_detector.py      # Village-level pattern detection
│
├── models/
│   └── db_models.py
│
└── database/
    ├── connection.py
    └── migrations/
```

---

## 🔧 Tamil-Specific Tech

### Voice Language Codes

```dart
// Flutter TTS — Tamil
await tts.setLanguage('ta-IN');

// Flutter STT — Tamil
_stt.listen(localeId: 'ta_IN');
```

### Bhashini API Integration (Tamil)

```python
# backend/ai/tamil_nlp.py

import httpx

BHASHINI_SOURCE_LANG = "ta"
BHASHINI_SCRIPT = "Taml"

async def translate_to_tamil(text: str) -> str:
    """Translate any text to Tamil via Bhashini"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://dhruva-api.bhashini.gov.in/services/inference/pipeline",
            headers={"Authorization": f"Bearer {BHASHINI_API_KEY}"},
            json={
                "pipelineTasks": [{
                    "taskType": "translation",
                    "config": {
                        "language": {
                            "sourceLanguage": "en",
                            "targetLanguage": "ta"
                        }
                    }
                }],
                "inputData": {"input": [{"source": text}]}
            }
        )
        return response.json()["pipelineResponse"][0]["output"][0]["target"]


async def tamil_tts(text: str) -> bytes:
    """Generate Tamil speech audio via Bhashini"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://dhruva-api.bhashini.gov.in/services/inference/pipeline",
            headers={"Authorization": f"Bearer {BHASHINI_API_KEY}"},
            json={
                "pipelineTasks": [{
                    "taskType": "tts",
                    "config": {
                        "language": {"sourceLanguage": "ta"},
                        "gender": "female"
                    }
                }],
                "inputData": {"input": [{"source": text}]}
            }
        )
        return response.content
```

### AI4Bharat IndicNLP — Rural Tamil Dialect

```python
pip install ai4bharat-transliteration

from ai4bharat.transliteration import XlitEngine

# Handles rural Tamil transliteration and dialect normalization
engine = XlitEngine("ta", beam_width=10)
```

---

## 🗺️ Target Districts (Tamil Nadu)

Priority districts based on worst maternal health indicators:

| District | Key Health Challenge |
|---|---|
| **Dharmapuri** | Highest maternal mortality, tribal population |
| **Krishnagiri** | Anemia prevalence, low ANC coverage |
| **Ramanathapuram** | Remote geography, fishermen community |
| **Villupuram** | Dalits, poor sanitation, nutritional deficits |
| **Vellore** | Urban-rural gap, migrant labor population |

These districts give the strongest justification and impact narrative for academic research.

---

## 🏛️ Government Scheme Integration

The app actively informs women of their entitlements:

| Scheme | What App Does |
|---|---|
| **Makkalai Thedi Maruthuvam** | Prompts to register for doorstep nurse visits |
| **Dr. Muthulakshmi Reddy Maternity Benefit** | Alerts about ₹18,000 cash benefit, documents required |
| **Janani Suraksha Yojana (JSY)** | Notifies eligible women, tracks institutional delivery |
| **Amma Maternity Kit** | Reminds to collect from PHC at specific weeks |
| **SNEHA Nutrition Scheme** | Connects to local scheme for supplementary nutrition |
| **POSHAN Abhiyaan** | Tracks nutrition targets, anemia reduction goals |

---

## 🎨 Design Principles

### Non-Negotiable Rules

**1. Voice over text, always**
Every action completable by voice alone. Literacy is never a gatekeeper.

**2. AI summarizes FOR the doctor**
She should never repeat herself. AI hands off a clean Tamil summary every time.

**3. Never say "you have X"**
The AI always says: *"இந்த அறிகுறிகள் X-ஐ காட்டலாம் — VHN அக்கா confirm பண்ணுவாங்க."*
(These symptoms may indicate X — VHN will confirm.)

**4. Offline core**
Screening and health records work without internet. Sync when connected.

**5. WhatsApp as fallback**
Care Advice Cards shareable as plain images on WhatsApp. For many rural women, WhatsApp *is* the internet.

**6. "அக்கா" is the right address**
Warm, trusted, peer-level. Not formal "நீங்கள்", not informal "நீ". "அக்கா" sets the entire emotional tone.

**7. Warm palette**
Avoid clinical white. Use saffron, deep green, turmeric yellow — colors that feel familiar, not hospital-like.

**8. Three things per screen maximum**
One message. One warning. One action. Never a wall of information.

---

## 🚀 MVP Build Plan

Build in this order. Each sprint proves the concept before expanding.

### Sprint 1 (Weeks 1–2) — Proof of Concept
> **Voice AI in Tamil — the one thing that proves everything**

- Tamil STT + TTS working (`ta-IN`)
- 10 common symptom phrases recognized
- AI responds with Tamil health guidance
- Basic risk level output (🟢🟡🔴)
- **Demo target:** Show a woman saying "தலை சுத்துது" and getting a caring Tamil response

### Sprint 2 (Weeks 3–4) — Cycle Tracker
- Period logging by voice/tap
- Pregnancy tracker with LMP input
- AI transition from period to pregnancy detection
- Week-by-week guidance (Weeks 1–40 content)

### Sprint 3 (Week 5) — Risk Engine
- Rule-based decision trees for top 5 conditions
- Symptom history cross-referencing
- Risk card UI in Tamil

### Sprint 4 (Week 6) — Health Notebook
- Photo upload from camera/gallery
- Google ML Kit OCR on lab reports
- AI explains prescription in Tamil
- Visit Summary Card generation

### Sprint 5 (Weeks 7–8) — Reminders + VHN Mode
- Voice reminders with SMS fallback
- VHN login and village patient list
- Risk-sorted view for VHN
- Proxy screening flow

### Sprint 6 (Weeks 9–10) — Integration + Polish
- Cross-module AI connections
- Offline sync testing
- UI accessibility audit
- Tamil dialect testing
- Documentation for academic submission

---

## 📄 Academic Publishing Angles

### What Makes This Publishable

**Gap in literature:** Most rural health tech papers focus on Hindi. Tamil is significantly underrepresented. A Tamil-first, voice-enabled health AI for rural women is a clear gap.

**Novel contributions:**
- Cross-module AI intelligence layer (connects period tracker + voice chat + pregnancy tracker + reminder behavior)
- Tamil NLP calibration for rural dialect variation (Chennai vs Madurai vs Tirunelveli rural Tamil)
- Cultural calibration of AI health responses for Tamil Nadu context
- VHN (Village Health Nurse) workflow integration — unique to Tamil Nadu
- Community-level pattern detection across multiple women's data

### Documentation Checklist for Submission

- [ ] System architecture diagram
- [ ] AI decision tree documentation for each health condition
- [ ] Tamil conversation design guidelines (cultural calibration rationale)
- [ ] Usability testing methodology (rural women personas or actual pilot)
- [ ] Mapping to Tamil Nadu government schemes
- [ ] Mapping to National Health Mission goals
- [ ] NFHS-5 data citations for problem justification
- [ ] Offline-first architecture technical documentation
- [ ] Privacy and data security approach

---

## 📜 License

This project is developed for academic research purposes.  
All health information provided through this platform is for screening and guidance only — not medical diagnosis.

---

## 🤝 Acknowledgements

- **Bhashini** — India's multilingual AI platform (Government of India)
- **AI4Bharat** — IndicNLP for Tamil dialect handling
- **National Health Mission, Tamil Nadu** — Scheme data and health statistics
- **NFHS-5** — National Family Health Survey baseline data

---

*வணக்கம் அக்கா — Built with care, for every woman who deserved better healthcare, sooner.*