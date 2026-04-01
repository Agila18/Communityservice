from typing import List, Dict, Any
from collections import Counter
from datetime import datetime

def analyze_village_patterns(screenings_list: List[Any]) -> Dict[str, Any]:
    """
    Community Detection mapping specifically resolving District-scale structural anomalies.
    Scans recent explicit records bounding 7-days for identical repeating maternal complaints mapping Outbreaks natively!
    """
    if not screenings_list: 
        return None
    
    symptom_counter = Counter()
    
    # NLP interception mapping arrays directly tracking explicit viral descriptors
    for record in screenings_list:
        symps_str = getattr(record, "symptoms_reported", "")
        if not symps_str: continue
        
        text = symps_str.lower()
        if any(w in text for w in ["வயிறு வலி", "stomach pain"]): symptom_counter["வயிற்று வலி (Stomach Pain)"] += 1
        if any(w in text for w in ["காய்ச்சல்", "fever", "hot"]): symptom_counter["காய்ச்சல் (Fever)"] += 1
        if any(w in text for w in ["வாந்தி", "nausea"]): symptom_counter["வாந்தி (Nausea)"] += 1
        if any(w in text for w in ["பேதி", "diarrhea"]): symptom_counter["பேதி (Diarrhea)"] += 1
        if any(w in text for w in ["தலைவலி", "headache"]): symptom_counter["தலைவலி (Headache)"] += 1
        
    alerts = []
    
    # Mathematical Trigger Threshold representing high-density outbreak physics in confined mapping sectors
    trigger_limit = 3
    
    for symptom, count in symptom_counter.items():
        if count >= trigger_limit:
            alerts.append(f"இந்த வாரம் {count} பேர் {symptom} சொன்னார்கள் — PHC-க்கு தெரிவிக்கவும்")
            
    if alerts:
        return {
            "status": "alert",
            "messages": alerts,
            "tamil_alert": "\n\n".join(alerts),
            "generated_at": datetime.now().isoformat()
        }
    return None
