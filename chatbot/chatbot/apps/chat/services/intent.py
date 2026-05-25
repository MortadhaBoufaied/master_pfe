"""Intent detection for conversational patterns."""

import logging
import re

logger = logging.getLogger('chatbot')

# Intent rules: (intent_name, compiled_regex)
RULES = [
    ('greeting', re.compile(r"(hi|hello|hey|salut|salam|bonjour|hola)", re.I)),
    ('goodbye', re.compile(r"(bye|goodbye|au\s+revoir|beslema|adios|farewell)", re.I)),
    ('thanks', re.compile(r"(thanks|thank\s+you|merci|shukran|gracias|tq)", re.I)),
    ('help', re.compile(r"(help|assist|support|need\s+help|can\s+you\s+help)", re.I)),
    ('confused', re.compile(r"(i\s+don\'?t\s+understand|what|confused|explain)", re.I)),
]


def detect_intent(text: str) -> str:
    """
    Detect intent from user text.
    
    Detects common conversational intents like greeting, goodbye, thanks, etc.
    Falls back to 'unknown' if no intent matches.
    
    Args:
        text: User input text
        
    Returns:
        Intent name (e.g., 'greeting', 'goodbye') or 'unknown'
    """
    if not text:
        return 'unknown'
    
    text_stripped = (text or '').strip()
    if not text_stripped:
        return 'unknown'
    
    # Check each rule in order
    for intent, pattern in RULES:
        if pattern.search(text_stripped):
            logger.debug(f"Intent detected: {intent}")
            return intent
    
    logger.debug("No intent detected, returning 'unknown'")
    return 'unknown'


def get_intent_description(intent: str) -> str:
    """Get human-readable description of intent."""
    descriptions = {
        'greeting': 'User greeting',
        'goodbye': 'User farewell',
        'thanks': 'User expressing gratitude',
        'help': 'User requesting help',
        'confused': 'User expressing confusion',
        'unknown': 'No specific intent detected',
    }
    return descriptions.get(intent, 'Unknown intent')
