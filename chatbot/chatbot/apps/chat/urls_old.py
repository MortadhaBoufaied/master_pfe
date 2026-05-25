from django.urls import path
from . import views

urlpatterns = [
    path('', views.chat_page, name='chat_page'),
    path('chat', views.chat_post, name='chat_post'),
    path('api/chat', views.api_chat, name='api_chat'),
]
