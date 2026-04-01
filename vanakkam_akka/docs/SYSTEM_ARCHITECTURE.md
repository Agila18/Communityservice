# System Architecture: Vanakkam Akka

## 1. Complete System Diagram Description

The *Vanakkam Akka* platform is engineered as a loosely coupled, offline-first distributed architecture bridging native mobile environments with a FastAPI asynchronous processing layer. 

**Component Breakdown:**
- **Client (Flutter):** A 2G-optimized native UI rendering dynamically mapped Tamil localized views. Completely driven by massive (48px+) touch targets and strict accessibility semantics mimicking agricultural interaction constraints. 
- **Offline Sync Layer (Hive + WorkManager):** A headless caching daemon instantly routing abstract states down into the OS disk, bypassing HTTP loaders. When `connectivity_plus` detects optimal packets, it flushes the queue sequentially via TCP backoffs (1m -> 5m -> 15m) preventing battery drains mapping natively out to `/api/v1/*`.
- **FastAPI Core (`backend/`):** A high-performance async routing layer ingesting localized String/Audio constructs resolving against Postgres schemas dynamically via SQLAlchemy.
- **AI Triage (`triage_engine.py`):** The primary diagnostic boundary. Validates strings explicitly looking for deterministic maternal hazards evaluating before fallback predictive mappings.
- **Intelligence Layer (`cross_module_analyzer.py`):** Acts as a global loop checking across 4 isolated database environments tracking historical arrays synthesizing overarching risks natively.

## 2. AI Decision Tree Documentation

Unlike traditional chatbots, the engine prioritizes deterministic rules over generative guessing.
1. **Miscarriage Danger:** IF `< 20 Weeks Pregnant` AND `(bleed OR spot)` -> Route: RED (Immediate PHC routing).
2. **Preeclampsia Hunt:** IF `> 28 Weeks Pregnant` AND `(headache OR swell OR blur)` -> Route: RED (High Vitals Priority).
3. **Fetal Distress:** IF `> 28 Weeks` AND `(no kicks OR movement slow)` -> Route: RED.
4. **General Malaise:** IF `Fever > 2 days` -> Route: YELLOW.

Everything else gracefully downgrades to standard ML inference mapped loosely to GREEN/YELLOW bounds translating colloquial Tamil specifically matching semantic logic securely into `Condition` types.

## 3. Cross-Module Intelligence Flow

The architecture explicitly rejects siloed tracking. The background job daemon integrates:
* **Pattern A:** Delayed Cycle Tracker `> 35 days` + Triage input `Nausea` = Pregnancy Test Alert.
* **Pattern B:** Missed Pill Reminders `> 5x` + Triage input `Fatigue` = Anemia Non-Adherence.
* **Pattern C:** Screening profile `Postpartum < 90 days` + Triage input `Sad/Empty` = PPD (Depression) Escalation.

## 4. Offline Sync Architecture

1. **State Injection:** User invokes action -> UI intercepts and transforms payload natively into `HiveBox(action)`.
2. **Execution:** UI completely detaches moving forward, drawing instantly off cache tracking.
3. **Queue Monitor:** Background `callbackDispatcher()` locks natively into iOS/Android bindings, interrogating `_queueBox`.
4. **Resiliency Validation:** Uses tracking timestamps. Retries explicitly limited ensuring isolated API floodgating resolves gracefully preserving poor 2G bandwidth in extreme constraints.

## 5. API Endpoint Reference

### Consultations (`/api/v1/consult/*`)
- `POST /new` -> Creates active AI-summary prepending Doctor timelines. 
- `POST /voice-message` -> Accepts `.m4a` binaries transcribing natively.
- `GET /sessions/{user_id}` -> Returns historical arrays.

### Triage (`/api/v1/screening/*`)
- `POST /analyze` -> Synthesizes rural Tamil input strings -> Output: Risk Object.

### Data Aggregation (`/api/v1/notebook/*`)
- `POST /analyze` -> Validates isolated MLKit raw Strings returning structural localizations natively parsing Labs -> Simple Tamil.
- `POST /generate-summary/{user_id}` -> Combines cycles, profiles, logs inherently formulating massive asynchronous printable ISO-A5 Clinical Summary PDFs locally.
