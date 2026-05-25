"""URL routing for chatbot application."""

from django.urls import path
from . import views

urlpatterns = [
    # Web UI
    path('', views.chat_page, name='chat_page'),
    path('chat', views.chat_post, name='chat_post'),
    
    # API
    path('api/chat', views.api_chat, name='api_chat'),
    
    # Monitoring & Health
    path('health', views.health_check, name='health_check'),
    path('metrics', views.metrics, name='metrics'),
    path('test-auth', views.test_auth, name='test_auth'),
]
