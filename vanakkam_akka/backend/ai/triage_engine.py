def classify_risk(symptoms_text: str, is_pregnant: bool, pregnancy_week: int = 0) -> str:
    """
    Rule-based risk classifier using symptom patterns.
    Evaluates raw colloquial Tamil and English keyword triggers.
    Returns: RED, YELLOW, or GREEN
    """
    text = symptoms_text.lower()
    
    # Check RED Flags (Critical / Emergency conditions)
    if is_pregnant:
        if any(w in text for w in ["heavy bleeding", "இரத்தப்போக்கு", "ரத்தம் அதிகமா"]):
            return "RED" # Severe bleeding -> Placenta issues / Miscarriage risk
        
        if any(w in text for w in ["headache", "தலை வலி"]) and any(w in text for w in ["swelling", "வீக்கம்"]):
            return "RED" # Severe headache + swelling -> Preeclampsia flag
            
        if any(w in text for w in ["fetal movement", "குழந்தை அசையல", "அசைவு தெரியல"]) and pregnancy_week > 28:
            return "RED" # Lack of fetal movement in 3rd trimester -> Fetal distress
            
    # Check YELLOW Flags (Requires clinical attention / Non-emergency)
    if any(w in text for w in ["dizziness", "தலை சுத்து", "மயக்கம்"]) and any(w in text for w in ["fatigue", "சோர்வு", "வெளுத்து"]):
        return "YELLOW" # Dizziness + Fatigue -> Anemia possible
        
    if any(w in text for w in ["irregular", "மாதம் சரியா வரல", "தள்ளி"]):
        if any(w in text for w in ["weight", "எடை ", "குண்டாயிட்டேன்"]):
            return "YELLOW" # Irregular cycles + Weight gain -> PCOS possible
        
    # Default GREEN for mild cold, minor stomach upset, generic tiredness
    return "GREEN"
