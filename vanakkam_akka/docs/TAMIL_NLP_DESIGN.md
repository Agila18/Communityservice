# Tamil NLP Design & Cultural Calibration

## 1. Rural Tamil Dialect Variations
Standard medical translation algorithms systematically fail rural Indian women because they map toward pure textbook linguistics ("சுத்த தமிழ்" / Formal Tamil) which nobody speaks in daily agricultural labor. *Vanakkam Akka* is explicitly tuned to gracefully bridge informal regional boundaries.

- **Villupuram / Northern:** Heavy incorporation of local shorthand (e.g., "கிறு கிறுத்து வருது" commonly used instead of "தலைசுற்றல்" for Dizziness).
- **Tirunelveli / Southern:** Adapts to dense phonological shifts recognizing specific inflectional verb maps safely bypassing hard "illiteracy" barriers natively. 
- **Dharmapuri / Western:** Handles uniquely inflected tribal colloquialisms mapping native rural descriptors mapping to modern clinical codes logically.

## 2. Symptom Phrase Dictionary (Clinical Mapping)

We developed a 50+ phrase mapping directory bridging rural expressions perfectly matching clinical equivalents bypassing pure literal translations completely. 

* *வயிறு முறுக்குது (Stomach twisting)* ➡️ Cramping / Dysmenorrhea
* *வெள்ளை படுது (White discharge)* ➡️ Leucorrhea / Yeast Infection
* *ரத்தம் உதிரமா போகுது (Blood going loosely)* ➡️ Heavy Menstrual Bleeding
* *கண்ணு இருட்டிக்கிட்டு வருது (Eyes getting dark)* ➡️ Syncope / Severe Anemia
* *உடம்பு வெல வெல-னு இருக்கு (Body feels weak/shaky)* ➡️ Hypoglycemia / Lethargy
* *கால் மரத்து போகுது (Leg feels like wood)* ➡️ Numbness / Neuropathy
* *மூச்சு வாங்குது (Buying breath)* ➡️ Dyspnea / Shortness of breath
* *மசக்கை (Masakkai)* ➡️ Morning Sickness (Pregnancy Specific)

*(This internal dictionary is rigorously mapped driving the GPT-4o-mini custom system prompts natively).*

## 3. Cultural Calibration Decisions

### A. Why "அக்கா" (Akka), not "நீங்கள்" (Neengal) or "நீ" (Nee)?
Standard apps default to the formal "நீங்கள்" - translating to a cold, sterile, clinical vibe indistinguishable from a hospital waiting room (which rural women actively avoid due to anxiety).
The term "அக்கா" (Older Sister) or "கண்ணு" (Endearing subset) immediately drops psychological barriers. It repositions the AI from a strict doctor dictating orders, into a warm, knowledgeable older village woman offering care natively, significantly improving retention and diagnostic honesty globally.

### B. Empathy over Interrogation
The AI is instructed never to interrogate. If a woman misses 5 reminders, a standard app says: *"You missed your tracking goal."* 
*Vanakkam Akka* approaches it through compassion: *"அக்கா, மாத்திரை சாப்பிட கஷ்டமா இருக்கா? (Sister, is it difficult to eat the pills?)"* inherently transforming a non-adherence warning into an empathetic, community-driven dialogue natively drawing massive agricultural adoption.
