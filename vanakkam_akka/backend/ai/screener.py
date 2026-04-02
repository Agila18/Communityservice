import os
import re
from typing import Dict, List
from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

from ai.triage_engine import classify_risk

async def process_screening_message(user_message: str, conversation_history: List[Dict[str, str]], user_profile: dict) -> dict:
    """
    Drives the conversational AI logic utilizing LangChain and ChatGPT,
    specifically prompting for simple colloquival Tamil suitable for rural users.
    """
    
    # Safely extract profile elements to inform the LLM context
    name = user_profile.get("name", "அக்கா")
    
    sys_prompt = f"""You are Akka, a caring Tamil-speaking AI health assistant for rural women in Tamil Nadu, India. 
You speak ONLY in simple, colloquial Tamil (not formal Tamil). 
You address the user warmly as '{name}'. 
You ask ONE follow-up question at a time. Do absolutely not overwhelm the user with multiple questions.
You understand rural Tamil expressions perfectly:
- 'தலை சுத்துது' = dizziness
- 'வயிறு வலிக்குது' = stomach pain  
- 'மாதம் வரல' or 'அந்த நேரம்' = missed period
- 'உடம்பு சோர்வா இருக்கு' = fatigue
- 'வாந்தி மாதிரி' = nausea
- 'கால் வீக்கம்' = leg swelling

After 4-6 messages, conclude the screening and output ONLY: RISK:GREEN, RISK:YELLOW, or RISK:RED followed by a brief Tamil explanation.
Never diagnose. Use phrases like 'இருக்கலாம்' (might be), not 'இருக்கு' (is).
"""
    
    messages = [SystemMessage(content=sys_prompt)]
    
    # Inject active conversation memory
    for msg in conversation_history:
        if msg["role"] == "user":
            messages.append(HumanMessage(content=msg["content"]))
        else:
            messages.append(AIMessage(content=msg["content"]))
            
    # Append the incoming message block
    messages.append(HumanMessage(content=user_message))
    
    # Instantiate LLM matching the environment key definitions
    llm = ChatOpenAI(
        model="gpt-4o-mini", 
        temperature=0.3, # Low temperature ensures medical coherence and stops hallucinations
        api_key=os.getenv("OPENAI_API_KEY", "dummy_key")
    )
    
    # Force conclusion if the conversation runs too deep
    if len(messages) >= 10:
        messages.append(SystemMessage(content="You have reached the maximum turns. Conclude now by outputting RISK:GREEN, RISK:YELLOW, or RISK:RED with the explanation."))
        
    ai_response = llm.invoke(messages).content
    
    is_complete = False
    risk_level = ""
    clean_response = ai_response
    
    # Parse final risk tokens from the explicit LLM schema instructions
    match = re.search(r'RISK:(GREEN|YELLOW|RED)', ai_response)
    if match:
        is_complete = True
        risk_level = match.group(1)
        # Strip the parser tag so the UX cleanly speaks only the Tamil reasoning
        clean_response = ai_response.replace(match.group(0), "").strip()
        
        # Cross-reference the LLM risk output with our hard-coded Triage Algorithm Engine
        all_user_text = " ".join([m["content"] for m in conversation_history if m["role"] == "user"]) + " " + user_message
        is_pregnant = user_profile.get("is_pregnant", False)
        preg_week = user_profile.get("pregnancy_week", 0)
        
        rule_based_risk = classify_risk(all_user_text, is_pregnant=is_pregnant, pregnancy_week=preg_week)
        
        # Deterministic Risk Priority Precedence override (Algorithm > LLM)
        risk_precedence = {"RED": 3, "YELLOW": 2, "GREEN": 1, "": 0}
        if risk_precedence.get(rule_based_risk, 0) > risk_precedence.get(risk_level, 0):
            risk_level = rule_based_risk
            
    return {
        "ai_response": clean_response,
        "is_complete": is_complete,
        "risk_level": risk_level
    }
