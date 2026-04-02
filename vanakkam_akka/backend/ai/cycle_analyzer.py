from typing import List, Dict, Any
from datetime import date

def analyze_cycle_pattern(entries: List[Any]) -> Dict[str, Any]:
    """
    Analyzes historical CycleEntry models sequentially to heuristically classify 
    menstrual risks, extracting core markers for rural Tamil dissemination.
    """
    try:
        if not entries or len(entries) < 2:
            return {
                "avg_cycle_length": 0,
                "irregularity_flag": False,
                "pregnancy_probability": False,
                "recommendation_tamil": "மேலும் சில மாதவிடாய் தேதிகளை பதிவு செய்யவும். (Log more dates for accurate analysis.)"
            }
            
        cycle_lengths = []
        heavy_flow_count = 0
        short_cycles = 0
        
        # Calculate interval variance across recorded models
        for i in range(1, len(entries)):
            prev = entries[i-1]
            curr = entries[i]
            
            # Safe date calculation with error handling
            try:
                if hasattr(prev, 'start_date') and hasattr(curr, 'start_date'):
                    diff = (curr.start_date - prev.start_date).days
                    cycle_lengths.append(diff)
                else:
                    continue
            except (AttributeError, TypeError):
                continue
            
            # Check flow severity safely
            flow = getattr(prev, 'flow_level', None)
            if flow and hasattr(flow, 'name') and flow.name.upper() == "HEAVY":
                heavy_flow_count += 1
                
            if diff < 21:
                short_cycles += 1

        # Accommodate latest cycle's flow 
        last_flow = getattr(entries[-1], 'flow_level', None)
        if last_flow and hasattr(last_flow, 'name') and last_flow.name.upper() == "HEAVY":
            heavy_flow_count += 1
            
        if not cycle_lengths:
            return {
                "avg_cycle_length": 28,  # Default healthy cycle
                "irregularity_flag": False,
                "pregnancy_probability": False,
                "recommendation_tamil": "சாதாரண சுகாதாரமான மாதவிடாய். தொடர்ந்து கண்காணிக்கவும்."
            }
            
        avg_length = sum(cycle_lengths) / len(cycle_lengths)
        
        irregularity_flag = False
        pcos_pattern = False
        
        # Mathematical variance check for irregularity (> 8 days diff between extremes indicates hormonal shifts)
        if len(cycle_lengths) > 1:
            variance = max(cycle_lengths) - min(cycle_lengths)
            if variance >= 8:
                irregularity_flag = True
                
        # PCOS diagnostic heuristic (Sustained > 35 day cycles globally coupled with history of severe outflow)
        if avg_length > 35 and heavy_flow_count > 0:
            irregularity_flag = True
            pcos_pattern = True
            
        # Pregnancy chronological prompt logic
        # Calculate offset against mathematical average + 10 day pad
        try:
            days_since_last = (date.today() - entries[-1].start_date).days
            pregnancy_probability = days_since_last > (avg_length + 10)
        except (AttributeError, TypeError):
            pregnancy_probability = False
        
        # Localize logic into rural-friendly structural suggestions
        recommendation = "உங்கள் cycle சீராக உள்ளது." # Normal/Healthy baseline
        
        if pregnancy_probability:
            recommendation = "உங்கள் மாதவிடாய் 10 நாட்களுக்கு மேல் தள்ளிப்போயுள்ளது. கர்ப்ப பரிசோதனை (Pregnancy check) செய்து கொள்ளவும்."
        elif pcos_pattern:
            recommendation = "உங்கள் cycle சீராக இல்லை (Long cycles + Heavy flow). நீங்கள் VHN அக்காவிடம் பேசுங்கள்."
        elif irregularity_flag:
            recommendation = "உங்கள் cycle சீராக இல்லை — VHN அக்காவிடம் பேசுங்கள்."
        elif short_cycles > 0:
            recommendation = "மாதவிடாய் நாட்கள் மிக குறைவு. ஊட்டச்சத்து குறைபாடாக இருக்கலாம்."
            
        return {
            "avg_cycle_length": round(avg_length),
            "irregularity_flag": irregularity_flag or pcos_pattern,
            "pregnancy_probability": pregnancy_probability,
            "recommendation_tamil": recommendation
        }
    except Exception as e:
        # Fallback safe response
        return {
            "avg_cycle_length": 28,
            "irregularity_flag": False,
            "pregnancy_probability": False,
            "recommendation_tamil": "தரவு பகுப்பாய்வில் பிழை. மீண்டும் முயற்சிக்கவும்."
        }
