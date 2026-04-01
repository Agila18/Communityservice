def classify_risk(symptoms_text: str, is_pregnant: bool, pregnancy_week: int = 0) -> str:
    """
    Rule-based risk classifier using symptom patterns.
    Evaluates raw colloquial Tamil and English keyword triggers.
    Returns: RED, YELLOW, or GREEN
    """
    text = symptoms_text.lower()
    
    # Check RED Flags (Critical / Emergency conditions)
    if is_pregnant:
        # Week < 20 + bleeding -> miscarriage risk
        if pregnancy_week < 20 and any(w in text for w in ["bleeding", "இரத்தப்போக்கு", "ரத்தம்"]):
            return "RED"
        
        # Week > 20 + severe headache + swelling -> preeclampsia
        if pregnancy_week > 20 and any(w in text for w in ["headache", "தலை வலி"]) and any(w in text for w in ["swelling", "வீக்கம்"]):
            return "RED"
            
        # Week > 28 + no fetal movement -> fetal distress
        if pregnancy_week > 28 and any(w in text for w in ["fetal movement", "குழந்தை அசையல", "அசைவு"]):
            return "RED"
            
    # Any week (Pregnant or not) + fever > 2 days -> YELLOW
    if any(w in text for w in ["fever", "காய்ச்சல்"]) and any(w in text for w in ["2 days", "2 நாள்", "ரெண்டு"]):
        return "YELLOW"
        
    # Standard Non-Pregnant YELLOW Flags
    if any(w in text for w in ["dizziness", "தலை சுத்து", "மயக்கம்"]) and any(w in text for w in ["fatigue", "சோர்வு", "வெளுத்து"]):
        return "YELLOW" # Dizziness + Fatigue -> Anemia possible
        
    if any(w in text for w in ["irregular", "மாதம் சரியா வரல", "தள்ளி"]):
        if any(w in text for w in ["weight", "எடை ", "குண்டாயிட்டேன்"]):
            return "YELLOW" # Irregular cycles + Weight gain -> PCOS possible
        
    # Default GREEN for mild cold, minor stomach upset, generic tiredness
    return "GREEN"
