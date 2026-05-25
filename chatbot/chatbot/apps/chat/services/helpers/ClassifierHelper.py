from typing import Tuple, List, Dict
from .intent_rules import RULES

class ClassifierHelper:
    async def classify_intent_and_extract_entities(self, prompt: str) -> Tuple[str, List[Dict]]:
        txt = (prompt or '').strip()
        for intent, pat in RULES:
            if pat.search(txt):
                return intent, []
        return 'unknown', []
