"""Predefined responses for common intents."""

import logging
from asgiref.sync import sync_to_async
from apps.chat.models import PredefinedResponse

logger = logging.getLogger('chatbot')

# Built-in responses for common intents
BUILTIN = {
    'greeting': "Hello! 👋 Ask me anything about the academy (fees, schedule, registration, policies...).",
    'goodbye': "Goodbye! 👋",
    'thanks': "You're welcome! 😊",
    'help': "I'm here to help! You can ask me about:\n- Fees and pricing\n- Class schedule\n- Registration process\n- Academy policies\nWhat would you like to know?",
    'confused': "I understand this is confusing. Could you try rephrasing your question? Feel free to ask about fees, schedule, registration, or policies.",
}


@sync_to_async
def get_predefined(intent: str) -> str | None:
    """
    Get predefined response for an intent.
    
    First checks built-in responses, then queries database for custom responses.
    
    Args:
        intent: Intent name (e.g., 'greeting', 'goodbye')
        
    Returns:
        Response text or None if no predefined response found
    """
    if not intent:
        return None
    
    # Check built-in responses first (fast)
    if intent in BUILTIN:
        logger.debug(f"Using built-in response for intent: {intent}")
        return BUILTIN[intent]
    
    # Check database for custom responses
    try:
        response = PredefinedResponse.objects.get(intent=intent)
        logger.debug(f"Using database response for intent: {intent}")
        return response.response_text
    except PredefinedResponse.DoesNotExist:
        logger.debug(f"No predefined response found for intent: {intent}")
        return None
    except Exception as e:
        logger.error(f"Error retrieving predefined response: {e}")
        return None
