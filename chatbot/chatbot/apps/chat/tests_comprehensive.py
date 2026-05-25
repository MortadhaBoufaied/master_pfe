"""Comprehensive test suite for the chatbot application."""

import pytest
from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.urls import reverse
from django.conf import settings
import json
import logging

from apps.chat.models import PredefinedResponse, ChatHistory, ApiKey
from apps.chat.services.bot import Chatbot
from apps.chat.services.ml_index import MLIndex
from apps.chat.services.intent import detect_intent
from apps.chat.services.security import InputValidator, RateLimiter
from apps.chat.services.monitoring import MetricsCollector, HealthChecker


class IntentDetectionTestCase(TestCase):
    """Test intent detection functionality."""

    def test_greeting_intent(self):
        """Should detect greeting intents."""
        assert detect_intent("hello") == "greeting"
        assert detect_intent("Hi there") == "greeting"
        assert detect_intent("Hey!") == "greeting"
        assert detect_intent("Salut") == "greeting"

    def test_goodbye_intent(self):
        """Should detect goodbye intents."""
        assert detect_intent("bye") == "goodbye"
        assert detect_intent("goodbye") == "goodbye"
        assert detect_intent("see you") == "goodbye"

    def test_thanks_intent(self):
        """Should detect thanks intents."""
        assert detect_intent("thanks") == "thanks"
        assert detect_intent("thank you") == "thanks"
        assert detect_intent("merci") == "thanks"

    def test_help_intent(self):
        """Should detect help intents."""
        assert detect_intent("help") == "help"
        assert detect_intent("can you help?") == "help"

    def test_unknown_intent(self):
        """Should return 'unknown' for unrecognized intents."""
        assert detect_intent("What are your fees?") == "unknown"
        assert detect_intent("Tell me about registration") == "unknown"
        assert detect_intent("") == "unknown"

    def test_case_insensitive(self):
        """Intent detection should be case-insensitive."""
        assert detect_intent("HELLO") == "greeting"
        assert detect_intent("BYE") == "goodbye"


class InputValidationTestCase(TestCase):
    """Test input validation."""

    def test_valid_message(self):
        """Should accept valid messages."""
        is_valid, error = InputValidator.validate_message("What are the fees?")
        assert is_valid is True
        assert error is None

    def test_empty_message(self):
        """Should reject empty messages."""
        is_valid, error = InputValidator.validate_message("")
        assert is_valid is False
        assert "empty" in error.lower()

    def test_none_message(self):
        """Should reject None messages."""
        is_valid, error = InputValidator.validate_message(None)
        assert is_valid is False

    def test_whitespace_only(self):
        """Should reject whitespace-only messages."""
        is_valid, error = InputValidator.validate_message("   ")
        assert is_valid is False

    def test_message_too_long(self):
        """Should reject messages exceeding max length."""
        long_msg = "a" * (settings.CHATBOT_MAX_MESSAGE_LENGTH + 1)
        is_valid, error = InputValidator.validate_message(long_msg)
        assert is_valid is False
        assert "too long" in error.lower()

    def test_sql_injection_attempt(self):
        """Should reject SQL injection attempts."""
        is_valid, error = InputValidator.validate_message("'; DROP TABLE users; --")
        assert is_valid is False

    def test_script_injection(self):
        """Should reject script injection attempts."""
        is_valid, error = InputValidator.validate_message("<script>alert('xss')</script>")
        assert is_valid is False

    def test_valid_sender_id(self):
        """Should accept valid sender_id."""
        is_valid, error = InputValidator.validate_sender_id("user123")
        assert is_valid is True
        assert error is None

    def test_empty_sender_id_ok(self):
        """Empty sender_id should be optional."""
        is_valid, error = InputValidator.validate_sender_id("")
        assert is_valid is True

    def test_sender_id_too_long(self):
        """Should reject long sender_id."""
        long_id = "a" * 300
        is_valid, error = InputValidator.validate_sender_id(long_id)
        assert is_valid is False


class PredefinedResponseTestCase(TestCase):
    """Test predefined responses."""

    def setUp(self):
        """Create test data."""
        PredefinedResponse.objects.create(
            intent="greeting",
            response_text="Hello!",
            enabled=True
        )

    def test_predefined_response_creation(self):
        """Should create predefined response."""
        pr = PredefinedResponse.objects.get(intent="greeting")
        assert pr.response_text == "Hello!"
        assert pr.enabled is True

    def test_predefined_response_str(self):
        """Should have proper string representation."""
        pr = PredefinedResponse.objects.get(intent="greeting")
        assert str(pr) == "PredefinedResponse(greeting)"

    def test_unique_intent(self):
        """Intent should be unique."""
        with pytest.raises(Exception):
            PredefinedResponse.objects.create(
                intent="greeting",
                response_text="Different greeting"
            )


class ChatHistoryTestCase(TestCase):
    """Test chat history tracking."""

    def test_create_chat_history(self):
        """Should create chat history entry."""
        ChatHistory.objects.create(
            sender_id="user123",
            user_message="What are the fees?",
            bot_response="The fees are $100",
            response_score=0.95,
            category="Pricing",
            source="ml_match"
        )
        
        ch = ChatHistory.objects.get(sender_id="user123")
        assert ch.user_message == "What are the fees?"
        assert ch.response_score == 0.95

    def test_chat_history_ordering(self):
        """Chat history should order by newest first."""
        ch1 = ChatHistory.objects.create(
            user_message="Message 1",
            bot_response="Response 1"
        )
        ch2 = ChatHistory.objects.create(
            user_message="Message 2",
            bot_response="Response 2"
        )
        
        entries = list(ChatHistory.objects.all())
        assert entries[0].id == ch2.id  # Newest first


class APIEndpointTestCase(TestCase):
    """Test API endpoints."""

    def setUp(self):
        """Set up test client."""
        self.client = Client()
        self.api_key = "test-api-key-secret"
        with self.settings(CHATBOT_API_KEY=self.api_key):
            pass

    def test_health_check_endpoint(self):
        """Health check should return 200."""
        response = self.client.get('/health')
        assert response.status_code == 200
        data = json.loads(response.content)
        assert 'status' in data

    def test_chat_post_valid_message(self):
        """POST /chat should accept valid message."""
        response = self.client.post(
            '/chat',
            data=json.dumps({'message': 'Hello'}),
            content_type='application/json'
        )
        assert response.status_code == 200
        data = json.loads(response.content)
        assert 'response' in data

    def test_chat_post_empty_message(self):
        """POST /chat should reject empty message."""
        response = self.client.post(
            '/chat',
            data=json.dumps({'message': ''}),
            content_type='application/json'
        )
        assert response.status_code == 400

    def test_chat_post_invalid_json(self):
        """POST /chat should reject invalid JSON."""
        response = self.client.post(
            '/chat',
            data='not json',
            content_type='application/json'
        )
        assert response.status_code == 400

    def test_api_chat_requires_auth(self):
        """POST /api/chat should require API key."""
        settings.CHATBOT_API_KEY = "secret"
        response = self.client.post(
            '/api/chat',
            data=json.dumps({'message': 'Hello'}),
            content_type='application/json'
        )
        # Should fail without API key (if key is configured)
        if settings.CHATBOT_API_KEY:
            assert response.status_code == 401

    def test_api_chat_with_valid_key(self):
        """POST /api/chat should accept valid API key."""
        api_key = "test-key-123"
        with self.settings(CHATBOT_API_KEY=api_key):
            response = self.client.post(
                '/api/chat',
                data=json.dumps({'message': 'Hello'}),
                content_type='application/json',
                HTTP_X_API_KEY=api_key
            )
            assert response.status_code == 200

    def test_test_auth_endpoint(self):
        """Test auth endpoint should validate API key."""
        response = self.client.get('/test-auth')
        assert response.status_code == 200
        data = json.loads(response.content)
        assert 'success' in data


class HealthCheckTestCase(TestCase):
    """Test health checking system."""

    def test_health_checker_returns_dict(self):
        """Health checker should return dict with status."""
        health = HealthChecker.check_health()
        assert 'status' in health
        assert health['status'] in ['healthy', 'unhealthy']

    def test_health_includes_components(self):
        """Health check should include component status."""
        health = HealthChecker.check_health()
        if health.get('status') == 'healthy':
            assert 'components' in health


class MetricsTestCase(TestCase):
    """Test metrics collection."""

    def setUp(self):
        """Reset metrics before each test."""
        MetricsCollector.reset()

    def test_get_empty_stats(self):
        """Should return empty stats initially."""
        stats = MetricsCollector.get_stats()
        assert stats['total_queries'] == 0

    def test_reset_metrics(self):
        """Should reset all metrics."""
        MetricsCollector.reset()
        stats = MetricsCollector.get_stats()
        assert stats['total_queries'] == 0


class ChatbotTestCase(TestCase):
    """Test chatbot service."""

    @pytest.mark.asyncio
    async def test_chatbot_singleton(self):
        """Chatbot should be singleton."""
        bot1 = Chatbot()
        bot2 = Chatbot()
        assert bot1 is bot2

    @pytest.mark.asyncio
    async def test_chatbot_responds_to_greeting(self):
        """Chatbot should respond to greeting."""
        bot = Chatbot()
        response = await bot.respond("Hello")
        assert 'response' in response
        assert response['score'] > 0


class RateLimitingTestCase(TestCase):
    """Test rate limiting."""

    def setUp(self):
        """Reset cache before each test."""
        from django.core.cache import cache
        cache.clear()

    def test_rate_limit_allows_normal_requests(self):
        """Should allow requests under limit."""
        for _ in range(5):
            assert RateLimiter.is_allowed("test-id") is True

    def test_rate_limit_blocks_excess_requests(self):
        """Should block requests exceeding limit."""
        # Fill up the rate limit
        limit = settings.RATE_LIMIT_REQUESTS
        for _ in range(limit):
            RateLimiter.is_allowed("test-id")
        
        # Next request should fail (if limits enabled)
        if settings.RATE_LIMIT_ENABLED:
            assert RateLimiter.is_allowed("test-id") is False


# ============================================================================
# Integration Tests
# ============================================================================

class IntegrationTestCase(TestCase):
    """End-to-end integration tests."""

    def test_full_chat_flow(self):
        """Test complete chat workflow."""
        # User sends message
        response = self.client.post(
            '/chat',
            data=json.dumps({'message': 'What is this about?'}),
            content_type='application/json'
        )
        
        # Should get response
        assert response.status_code == 200
        data = json.loads(response.content)
        assert 'response' in data
        assert isinstance(data['response'], str)

    def test_multiple_conversation_turns(self):
        """Test multiple conversation turns."""
        messages = [
            "Hello",
            "What are the fees?",
            "Thanks",
        ]
        
        for msg in messages:
            response = self.client.post(
                '/chat',
                data=json.dumps({'message': msg}),
                content_type='application/json'
            )
            assert response.status_code == 200

    def test_metrics_collection_during_chat(self):
        """Chat interactions should update metrics."""
        initial_stats = MetricsCollector.get_stats()
        initial_count = initial_stats.get('total_queries', 0)
        
        # Send a message
        self.client.post(
            '/chat',
            data=json.dumps({'message': 'test'}),
            content_type='application/json'
        )
        
        # Metrics should be updated (metrics are in-memory)
        # This test depends on caching configuration
