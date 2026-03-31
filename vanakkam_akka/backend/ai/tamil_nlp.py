"""
Tamil NLP — language processing utilities for Tamil text.
Handles transliteration, text normalization, and health-term extraction.
"""

from typing import Optional


class TamilNLP:
    """Tamil language NLP utilities for health domain."""

    # Common Tamil health terms mapping
    HEALTH_TERMS = {
        "தலைவலி": "headache",
        "காய்ச்சல்": "fever",
        "வயிற்றுவலி": "stomach_pain",
        "மாதவிடாய்": "menstruation",
        "கர்ப்பம்": "pregnancy",
        "ரத்தப்போக்கு": "bleeding",
        "வாந்தி": "vomiting",
        "மயக்கம்": "dizziness",
        "இருமல்": "cough",
        "மூச்சுத்திணறல்": "breathlessness",
        "வீக்கம்": "swelling",
        "உயர் ரத்த அழுத்தம்": "high_blood_pressure",
        "சர்க்கரை நோய்": "diabetes",
        "ரத்தசோகை": "anemia",
        "மார்பு வலி": "chest_pain",
    }

    def __init__(self):
        pass

    def extract_symptoms(self, tamil_text: str) -> list[str]:
        """Extract health symptoms from Tamil text input."""
        found_symptoms = []
        text_lower = tamil_text.strip()
        for tamil_term, english_key in self.HEALTH_TERMS.items():
            if tamil_term in text_lower:
                found_symptoms.append(english_key)
        return found_symptoms

    def normalize_text(self, text: str) -> str:
        """Normalize Tamil text — remove extra spaces, fix encoding."""
        # TODO: handle common encoding issues in Tamil text
        return " ".join(text.split())

    async def transliterate(
        self, text: str, direction: str = "ta_to_en"
    ) -> str:
        """Transliterate between Tamil and English scripts."""
        # TODO: use indic-transliteration library
        return text

    async def translate(
        self, text: str, source: str = "ta", target: str = "en"
    ) -> str:
        """Translate between Tamil and English."""
        # TODO: use translation API or model
        return text

    def detect_urgency_keywords(self, tamil_text: str) -> Optional[str]:
        """Detect emergency keywords in Tamil text input."""
        emergency_keywords = {
            "அவசரம்": "emergency",
            "ரத்தம்": "bleeding",
            "மயக்கம்": "unconscious",
            "வலி அதிகம்": "severe_pain",
            "மூச்சு விட முடியவில்லை": "breathing_difficulty",
            "108": "ambulance_request",
        }
        for keyword, category in emergency_keywords.items():
            if keyword in tamil_text:
                return category
        return None
