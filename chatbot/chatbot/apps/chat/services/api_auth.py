"""API authentication and authorization."""

import logging
from django.conf import settings
from apps.chat.services.security import constant_time_compare

logger = logging.getLogger('chatbot')


class ApiAuthError(Exception):
    """Raised when API authentication fails."""
    pass


def require_api_key(request) -> None:
    """
    Verify API key from request.
    
    Args:
        request: Django request object
        
    Raises:
        ApiAuthError: If API key is invalid or missing when required
    """
    required_key = getattr(settings, 'CHATBOT_API_KEY', '')
    
    # If no key configured, authentication is optional
    if not required_key:
        logger.debug("API key check skipped (not configured)")
        return
    
    # Get provided key from headers
    provided_key = request.headers.get('X-API-Key') or request.META.get('HTTP_X_API_KEY')
    
    # Validate using constant-time comparison (prevent timing attacks)
    if not provided_key:
        logger.warning(f"API request without key from {request.META.get('REMOTE_ADDR')}")
        raise ApiAuthError('Missing API key')
    
    if not constant_time_compare(provided_key, required_key):
        logger.warning(f"API request with invalid key from {request.META.get('REMOTE_ADDR')}")
        raise ApiAuthError('Invalid API key')
    
    logger.debug("API authentication successful")
