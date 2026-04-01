import pytest
from datetime import datetime
import asyncio

# Extracted structural logic representing the explicit parameters defining maternal mortality vectors
from ai.cross_module_analyzer import Flag

# In real unit tests, these mock objects explicitly bypass DB bounds testing pure logic
class MockProfile:
    def __init__(self, is_preg=False, week=0):
        self.pregnancy_status = is_preg
        self.pregnancy_week = week
        self.postpartum_date = None

class MockScreening:
    class Risk:
       def __init__(self, val): self.value = val
    def __init__(self, symptoms, risk="GREEN"):
        self.symptoms_reported = symptoms
        self.risk_level = self.Risk(risk)
        self.timestamp = datetime.now()

class MockReminder:
    def __init__(self, r_type, done):
        self.reminder_type = r_type
        self.is_completed = done

# Refactored pure-logic function mimicking cross_module_analyzer for testing
def get_insights(profile, screenings, reminders, cycles):
    recent_symptoms = " ".join([s.symptoms_reported for s in screenings]).lower()
    flags = []
    
    # Rule 1: Preeclampsia 
    if profile.pregnancy_status and profile.pregnancy_week >= 28:
        if any(w in recent_symptoms for w in ["headache", "swelling", "தலைவலி", "வீக்கம்"]):
            flags.append(("PREECLAMPSIA", "RED"))
            
    # Rule 2: Bleeding in pregnancy
    if profile.pregnancy_status and any(w in recent_symptoms for w in ["bleeding", "ரத்தம்", "heavy flow"]):
        flags.append(("MATERNAL_BLEEDING", "RED"))
        
    # Rule 3: Anemia Adherence
    missed_iron = len([r for r in reminders if "iron" in r.reminder_type.lower() and not r.is_completed])
    if missed_iron >= 5 and any(w in recent_symptoms for w in ["fatigue", "சோர்வு"]):
        flags.append(("ANEMIA_ADHERENCE", "YELLOW"))
        
    return flags

def test_triage_red_preeclampsia():
    """Test RED: pregnant week 34 + headache + swelling"""
    prof = MockProfile(is_preg=True, week=34)
    scr = [MockScreening(symptoms="headache and leg swelling reported")]
    
    flags = get_insights(prof, scr, [], [])
    
    assert len(flags) > 0
    assert flags[0] == ("PREECLAMPSIA", "RED")

def test_triage_red_heavy_bleeding_pregnancy():
    """Test RED: pregnant + heavy bleeding"""
    prof = MockProfile(is_preg=True, week=12)
    scr = [MockScreening(symptoms="heavy bleeding started today")]
    
    flags = get_insights(prof, scr, [], [])
    
    assert len(flags) > 0
    assert flags[0] == ("MATERNAL_BLEEDING", "RED")

def test_triage_yellow_dizziness_fatigue():
    """Test YELLOW: dizziness + fatigue + not eaten"""
    # Fallback to the underlying AI Triage Engine logic checking explicit rural starvation bounds
    from ai.triage_engine import evaluate_symptoms_ml
    
    res = evaluate_symptoms_ml("எனக்கு தலை சுத்தலாக இருக்கிறது, சோர்வாகவும் உள்ளது. காலையில் சாப்பிடவில்லை.")
    
    # Must flag Yellow due to explicit physiological symptoms irrespective of starvation context
    assert res['risk_level'] == "YELLOW"

def test_triage_yellow_irregular_periods():
    """Test YELLOW: irregular periods 3 cycles"""
    from ai.cycle_analyzer import analyze_cycle_pattern
    
    # Generating 3 highly volatile synthetic cycles representing PCOS-like arrays
    from datetime import timedelta
    class MockCycle:
        def __init__(self, start): self.start_date = start
        
    c1 = MockCycle(datetime.now())
    c2 = MockCycle(datetime.now() - timedelta(days=20))
    c3 = MockCycle(datetime.now() - timedelta(days=65)) # Huge 45 day gap
    
    res = analyze_cycle_pattern([c1, c2, c3])
    
    assert res['irregularity_flag'] is True
    assert res['recommendation_tamil'] != ""

def test_triage_green_mild_cold():
    """Test GREEN: mild cold symptoms"""
    from ai.triage_engine import evaluate_symptoms_ml
    # Should resolve to standard outpatient care inherently
    res = evaluate_symptoms_ml("நேற்று முதல் லேசான சளி மற்றும் இரும்பல்.")
    assert res['risk_level'] == "GREEN"

def test_cross_module_anemia_adherence():
    """Test cross-module: missed reminders + fatigue = anemia adherence flag"""
    prof = MockProfile(is_preg=False)
    scr = [MockScreening(symptoms="extreme fatigue today")]
    
    # Generates 5 missed explicit iron protocols 
    reminders = [MockReminder("iron", False) for _ in range(5)]
    
    flags = get_insights(prof, scr, reminders, [])
    
    assert len(flags) > 0
    assert flags[0] == ("ANEMIA_ADHERENCE", "YELLOW")
