"""Security utilities for the chatbot API."""

import logging
import hashlib
import hmac
from typing import Optional
from django.conf import settings
from django.core.cache import cache
from django.http import HttpRequest

logger = logging.getLogger('chatbot')


class RateLimiter:
    """Rate limiting to prevent abuse."""

    @staticmethod
    def is_allowed(identifier: str) -> bool:
        """
        Check if a request from identifier is allowed.
        
        Args:
            identifier: IP address or API key
            
        Returns:
            True if request is allowed, False if rate limit exceeded
        """
        if not settings.RATE_LIMIT_ENABLED:
            return True

        cache_key = f"rate_limit:{identifier}"
        count = cache.get(cache_key, 0)

        if count >= settings.RATE_LIMIT_REQUESTS:
            logger.warning(f"Rate limit exceeded for {identifier}")
            return False

        cache.set(cache_key, count + 1, settings.RATE_LIMIT_PERIOD)
        return True

    @staticmethod
    def get_identifier(request: HttpRequest) -> str:
        """Get unique identifier for rate limiting."""
        # Prefer API key if available
        api_key = request.headers.get('X-API-Key') or request.META.get('HTTP_X_API_KEY')
        if api_key:
            return f"api:{hashlib.md5(api_key.encode()).hexdigest()}"
        
        # Fall back to IP address
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0].strip()
        else:
            ip = request.META.get('REMOTE_ADDR', 'unknown')
        return f"ip:{ip}"


class InputValidator:
    """Validate user input."""

    @staticmethod
    def validate_message(message: Optional[str]) -> tuple[bool, Optional[str]]:
        """
        Validate message input.
        
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not message:
            return False, "Message cannot be empty"

        if not isinstance(message, str):
            return False, "Message must be a string"

        message = message.strip()
        if not message:
            return False, "Message cannot be empty"

        if len(message) > settings.CHATBOT_MAX_MESSAGE_LENGTH:
            return False, f"Message too long (max {settings.CHATBOT_MAX_MESSAGE_LENGTH} characters)"

        # Check for suspicious patterns
        if _contains_injection_attempt(message):
            logger.warning(f"Potential injection attempt detected: {message[:50]}")
            return False, "Invalid message content"

        return True, None

    @staticmethod
    def validate_sender_id(sender_id: Optional[str]) -> tuple[bool, Optional[str]]:
        """Validate optional sender_id parameter."""
        if not sender_id:
            return True, None

        if not isinstance(sender_id, str):
            return False, "sender_id must be a string"

        if len(sender_id) > 255:
            return False, "sender_id too long (max 255 characters)"

        return True, None


def _contains_injection_attempt(text: str) -> bool:
    """Check for SQL injection, script injection, etc."""
    dangerous_patterns = [
        "'; DROP",
        "<script",
        "javascript:",
        "onclick=",
        "onerror=",
        "__import__",
        "eval(",
        "exec(",
    ]
    text_upper = text.upper()
    return any(pattern in text_upper for pattern in dangerous_patterns)


def hash_api_key(key: str) -> str:
    """Hash an API key for secure comparison."""
    return hashlib.sha256(key.encode()).hexdigest()


def constant_time_compare(a: str, b: str) -> bool:
    """Compare strings in constant time (prevent timing attacks)."""
    return hmac.compare_digest(a, b)
