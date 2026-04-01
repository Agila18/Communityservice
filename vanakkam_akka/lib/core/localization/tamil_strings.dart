/// Complete Tamil language strings organized by feature for the Vanakkam Akka app.
class TamilStrings {
  TamilStrings._();

  // App basics
  static const String appName = "வணக்கம் அக்கா";
  static const String appTagline = "உங்கள் ஆரோக்கியப் பாதுகாவலர்";
  static const String welcome = "வணக்கம்";
  static const String welcomeMessage = "உங்கள் ஆரோக்கியத்தைக் கவனிக்க நாங்கள் இங்கே உள்ளோம்";

  // Feature names
  static const String screening = "ஆரோக்கிய பரிசோதனை";
  static const String cycleTracker = "மாதவிடாய் கண்காணிப்பு";
  static const String healthNotebook = "ஆரோக்கியக் குறிப்பேடு";
  static const String teleconsult = "மருத்துவர் ஆலோசனை";
  static const String reminders = "நினைவூட்டல்கள்";
  static const String nutrition = "ஊட்டச்சத்து";
  static const String vhnMode = "VHN பயன்முறை";
  static const String home = "முகப்பு";
  static const String healthTips = "ஆரோக்கிய குறிப்புகள்";

  // 1. Greetings
  static const String greetingAkka = "வணக்கம் அக்கா";
  static const String greetingHowAreYou = "இன்னைக்கு எப்படி இருக்கீங்க?";

  // 2. Navigation labels
  static const String navHome = "முகப்பு";
  static const String navHealthCheck = "பரிசோதனை";
  static const String navRecords = "மருத்துவ குறிப்பேடு";
  static const String navReminders = "நினைவூட்டல்கள்";
  static const String navConsult = "மருத்துவர் ஆலோசனை";

  // 3. Onboarding
  static const String onboardLanguageSelect = "உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்";
  static const String onboardNameEntry = "உங்கள் பெயர் என்ன?";
  static const String onboardAge = "உங்கள் வயது என்ன?";
  static const String onboardLocation = "நீங்கள் எந்த ஊரிலிருந்து வருகிறீர்கள்?";

  // 4. Screening Categories & Risk Levels
  static const String categoryMaternal = "கர்ப்பகால ஆரோக்கியம்";
  static const String categoryMenstrual = "மாதவிடாய் நலம்";
  static const String categoryNutrition = "ஊட்டச்சத்து";
  static const String categoryGeneral = "பொதுவான அறிகுறிகள்";
  static const String categoryMental = "மனநலம்";
  static const String categoryReproductive = "இனப்பெருக்க ஆரோக்கியம்";

  static const String riskLabelGreen = "பாதுகாப்பான நிலை";
  static const String riskLabelYellow = "கவனம் தேவை";
  static const String riskLabelRed = "அவசரம்";

  // 5. Risk messages
  static const String messageRiskGreen = "நீங்கள் நலமாக இருக்கீங்க";
  static const String messageRiskYellow = "கவனிக்க வேண்டும்";
  static const String messageRiskRed = "உடனடியாக மருத்துவமனை போங்க";

  // 6. Cycle tracker & Pregnancy tracking
  static const String logPeriodStart = "மாதவிடாய் தொடங்கிய தேதி";
  static const String logPeriodEnd = "மாதவிடாய் முடிந்த தேதி";
  static const String logFlowLevel = "ரத்தப்போக்கின் அளவு";
  static const String logSymptoms = "அறிகுறிகளைச் சேர்க்கவும்";

  // Pregnancy week-by-week messages (Weeks 1 to 40)
  static const Map<int, String> pregnancyWeeks = {
    1: "கர்ப்பம் தொடங்கும் வாரம்",
    2: "கருப்பையில் முட்டை உருவாகிறது",
    3: "கருவுறுதல் நிகழ்கிறது",
    4: "நீங்கள் கர்ப்பமாக உள்ளீர்கள்",
    5: "குழந்தையின் இதயம் துடிக்க ஆரம்பிக்கிறது",
    6: "மூளை மற்றும் நரம்பு மண்டலம் வளர்கிறது",
    7: "கைகள் மற்றும் கால்கள் தோன்றுகின்றன",
    8: "உடல் உறுப்புகள் வளரத் தொடங்குகின்றன",
    9: "குழந்தையின் முகம் உருவாக ஆரம்பிக்கிறது",
    10: "கர்ப்பப்பை விரிவடைகிறது, பசி கூடும்",
    11: "பற்கள் மற்றும் நகங்கள் வளர்கின்றன",
    12: "முதல் மூன்று மாத காலகட்டம் முடிகிறது",
    13: "சோர்வு நீங்கி புத்துணர்ச்சி கிடைக்கும்",
    14: "குழந்தையின் முகம் முழுமை அடைகிறது",
    15: "குழந்தையின் அசைவுகளை உணர முடியும்",
    16: "குழந்தை ஒலிகளை கேட்கத் தொடங்கும்",
    17: "தொப்புள்கொடி தடிமனாகிறது",
    18: "குழந்தையின் அசைவுகள் நன்றாகத் தெரியும்",
    19: "குழந்தை கை சூப்பத் தொடங்கும்",
    20: "கர்ப்பத்தின் பாதி காலம் முடிந்தது",
    21: "குழந்தையின் செரிமான மண்டலம் வேலை செய்யும்",
    22: "பார்வை மற்றும் கேட்கும் திறன் மேம்படும்",
    23: "குழந்தையின் எடை கூடுகிறது",
    24: "நுரையீரல் வளரத் தொடங்குகிறது",
    25: "குழந்தையின் முடி வளர்கிறது",
    26: "கண்கள் திறக்கத் தொடங்கும்",
    27: "கர்ப்பத்தின் இறுதி மூன்று மாதங்கள் துவக்கம்",
    28: "மூளை வேகமாக வளர்கிறது",
    29: "குழந்தையின் எலும்புகள் வலுவடைகின்றன",
    30: "குழந்தை சுழன்று திரும்பும்",
    31: "குழந்தையின் உடல் கொழுப்பு கூடுகிறது",
    32: "குழந்தை தலைக்கீழாக திரும்பும்",
    33: "குழந்தையின் நோயெதிர்ப்பு சக்தி வளர்கிறது",
    34: "நுரையீரல் கிட்டத்தட்ட முழு வளர்ச்சியடையும்",
    35: "குழந்தை பிறக்க தயாராகிறது",
    36: "கர்ப்பப்பை கீழே இறங்கும்",
    37: "எப்போது வேண்டுமானாலும் பிறக்கலாம்",
    38: "குழந்தையின் மூளை மற்றும் நுரையீரல் முழு வளர்ச்சி",
    39: "பிரசவ வலி எப்போது வேண்டுமானாலும் வரலாம்",
    40: "பிறப்புக்கான தருணம், குழந்தையை வரவேற்கலாம்",
  };

  // 7. Reminders
  static const String reminderIronTablet = "இரும்புச்சத்து மாத்திரை போட மறந்துடாதீங்க";
  static const String reminderCalcium = "கால்சியம் மாத்திரை உட்கொள்ளவும்";
  static const String reminderWater = "தண்ணீர் நிறைய குடிக்கவும்";
  static const String reminderAncCheckup = "கர்ப்பகால பரிசோதனைக்கு (ANC) செல்லவும்";
  static const String reminderPhcVisit = "ஆரம்ப சுகாதார நிலையத்திற்கு (PHC) செல்லவும்";

  // 8. Health Notebook
  static const String notebookUpload = "பதிவேற்றுக";
  static const String notebookView = "பார்க்க";
  static const String notebookShare = "பகிர்க";

  // 9. VHN Mode (Village Health Nurse)
  static const String vhnPatientList = "நோயாளிகள் பட்டியல்";
  static const String vhnVisitNotes = "பார்வை குறிப்புகள்";
  static const String vhnEscalate = "அவசர சிகிச்சைக்காக பரிந்துரைக்க";

  // 10. Common AI-recognized Symptom Phrases
  static const String symptomDizziness = "தலை சுத்துது";
  static const String symptomStomachAche = "வயிறு வலிக்குது";
  static const String symptomFatigue = "உடம்பு சோர்வா இருக்கு";
  static const String symptomNausea = "வாந்தி மாதிரி இருக்கு";
  static const String symptomLegSwelling = "கால் வீக்கம்";
  static const String symptomMissedPeriod = "மாதம் வரல";
  static const String symptomPregnancy = "குழந்தை இருக்கு";
  static const String symptomHeadache = "தலை வலிக்குது";
  static const String symptomBlurryVision = "கண் மங்கலா இருக்கு";
}
