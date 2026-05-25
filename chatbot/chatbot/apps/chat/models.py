"""Database models for the chatbot application."""

from django.db import models
from django.utils import timezone


class PredefinedResponse(models.Model):
    """Custom predefined responses for intents."""
    
    intent = models.CharField(
        max_length=100,
        unique=True,
        help_text="Intent name (e.g., 'greeting', 'help')"
    )
    response_text = models.TextField(
        help_text="Response text for this intent"
    )
    enabled = models.BooleanField(
        default=True,
        help_text="Whether this response is active"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this response was created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When this response was last updated"
    )
    
    class Meta:
        verbose_name_plural = "Predefined Responses"
        ordering = ['intent']
        indexes = [
            models.Index(fields=['intent']),
            models.Index(fields=['enabled']),
        ]

    def __str__(self):
        return f"PredefinedResponse({self.intent})"
    
    def __repr__(self):
        return f"<PredefinedResponse intent='{self.intent}' enabled={self.enabled}>"


class ChatHistory(models.Model):
    """Track chat messages for analytics and debugging."""
    
    sender_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text="Optional user/session identifier"
    )
    user_message = models.TextField(
        help_text="User's input message"
    )
    bot_response = models.TextField(
        help_text="Bot's response"
    )
    response_score = models.FloatField(
        default=0.0,
        help_text="Confidence score of the response"
    )
    matched_question = models.TextField(
        blank=True,
        null=True,
        help_text="The original question that was matched"
    )
    category = models.CharField(
        max_length=100,
        blank=True,
        help_text="Category of the response"
    )
    source = models.CharField(
        max_length=100,
        blank=True,
        help_text="Source of the response (intent, ML match, etc.)"
    )
    processing_time_ms = models.FloatField(
        default=0.0,
        help_text="Time to generate response in milliseconds"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this interaction occurred"
    )
    
    class Meta:
        verbose_name_plural = "Chat History"
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['sender_id', '-created_at']),
            models.Index(fields=['source']),
            models.Index(fields=['-created_at']),
        ]
    
    def __str__(self):
        msg_preview = self.user_message[:50]
        return f"Chat({msg_preview}... -> score={self.response_score:.2f})"
    
    def __repr__(self):
        return f"<ChatHistory sender_id='{self.sender_id}' source='{self.source}'>"


class ApiKey(models.Model):
    """API keys for authenticated access."""
    
    name = models.CharField(
        max_length=100,
        unique=True,
        help_text="Name/description of this API key"
    )
    key = models.CharField(
        max_length=255,
        unique=True,
        help_text="The actual API key (keep secret)"
    )
    enabled = models.BooleanField(
        default=True,
        help_text="Whether this key is active"
    )
    created_at = models.DateTimeField(
        auto_now_add=True
    )
    updated_at = models.DateTimeField(
        auto_now=True
    )
    last_used_at = models.DateTimeField(
        blank=True,
        null=True,
        help_text="When this key was last used"
    )
    rate_limit_per_minute = models.IntegerField(
        default=100,
        help_text="Maximum requests per minute"
    )
    
    class Meta:
        verbose_name_plural = "API Keys"
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['key']),
            models.Index(fields=['enabled']),
        ]
    
    def __str__(self):
        return f"ApiKey({self.name})"
    
    def __repr__(self):
        return f"<ApiKey name='{self.name}' enabled={self.enabled}>"
    
    def update_last_used(self):
        """Update last_used_at timestamp."""
        self.last_used_at = timezone.now()
        self.save(update_fields=['last_used_at'])
