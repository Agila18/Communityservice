import os
import base64
import json
from typing import Dict, Any
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

def analyze_health_document(image_bytes: bytes) -> Dict[str, str]:
    """
    Takes a raw image byte stream representing prescriptions or lab results, 
    encodes it to Base64, and passes it securely to an LLM Vision model.
    Outputs a highly simplified Tamil medical translation optimized for rural audicences.
    """
    base64_image = base64.b64encode(image_bytes).decode("utf-8")
    
    # Initialize the LLM mapped for multimodal vision tasks
    # Using gpt-4o-mini as it is both cost-effective and performs exceptionally on multilingul OCR
    chat = ChatOpenAI(
        model="gpt-4o-mini",
        max_tokens=350,
        temperature=0.2, # Low temp keeps medical extraction grounded
        api_key=os.getenv("OPENAI_API_KEY", "dummy")
    )

    sys_prompt = """You are Akka, a caring AI medical assistant communicating with a rural Tamil woman.
Look at this uploaded medical document (which may be a prescription, scan, or blood test).
Return ONLY valid JSON matching this EXACT structure, skipping markdown wrappers:

{
  "title": "Short Tamil title (e.g. ரத்த பரிசோதனை அறிக்கை)",
  "ocr_text": "Extract brief key English medical findings here for doctor reference max 3 lines.",
  "ai_explanation": "Explain what this document means in 2-3 sentences of ONLY simple colloquial village Tamil. No medical jargon. Do not use complex grammar. Start with 'இது...' (e.g. 'இது உங்க ரத்த டெஸ்ட் ரிப்போர்ட் அக்கா. ரத்தம் குறைவா இருக்கு, கட்டாயம் இரும்பு சத்து மாத்திரை போடுங்க.')"
}

Do NOT wrap the response in markdown blocks like ```json ... ```. Just return raw JSON. 
If the image is blurry or NOT a medical document, politely state that in the ai_explanation.
"""

    try:
        msg = chat.invoke(
            [
                HumanMessage(
                    content=[
                        {"type": "text", "text": sys_prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                                "detail": "high"
                            },
                        },
                    ]
                )
            ]
        )
        
        # Aggressive stripping ensures robust JSON parsing regardless of minor model hallucinations
        clean_json_str = msg.content.strip()
        if clean_json_str.startswith("```json"):
            clean_json_str = clean_json_str[7:]
        if clean_json_str.endswith("```"):
            clean_json_str = clean_json_str[:-3]
            
        data = json.loads(clean_json_str.strip())
        return data
        
    except Exception as e:
        print(f"Vision AI OCR Failure: {str(e)}")
        return {
           "title": "புரிந்துகொள்ள முடியவில்லை",
           "ocr_text": "",
           "ai_explanation": "மன்னிக்கவும், இந்த புகைப்படத்தை என்னால் படிக்க முடியவில்லை. கொஞ்சம் வெளிச்சமான இடத்தில் மீண்டும் போட்டோ எடுக்கவும்."
        }
