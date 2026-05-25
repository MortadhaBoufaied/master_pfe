"""
Modified Django Chatbot Views with Service Integration
Add this to your chatbot/apps/chat/views.py
"""

# ============================================================================
# ADD THIS IMPORT TO YOUR EXISTING views.py
# ============================================================================
# import sys
# from pathlib import Path
# n8n_path = str(Path(__file__).parent.parent.parent.parent / 'n8n-service-orchestration')
# sys.path.insert(0, n8n_path)
# from chatbot_integration.service_detector import SyncServiceDetector

# ============================================================================
# MODIFY THE chat_post FUNCTION
# ============================================================================

from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
import json
from apps.chat.services.bot import Chatbot
from apps.chat.services.api_auth import require_api_key, ApiAuthError

# Service detector (lazy loaded)
_service_detector = None

def get_service_detector():
    global _service_detector
    if _service_detector is None:
        import sys
        from pathlib import Path
        n8n_path = str(Path(__file__).parent.parent.parent.parent / 'n8n-service-orchestration')
        sys.path.insert(0, n8n_path)
        from chatbot_integration.service_detector import SyncServiceDetector
        _service_detector = SyncServiceDetector()
    return _service_detector


@csrf_exempt
def chat_post(request):
    """
    Enhanced chat endpoint with service detection
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    try:
        data = json.loads(request.body or b'{}')
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    message = (data.get('message') or '').strip()
    if not message:
        return JsonResponse({'error': 'Message cannot be empty'}, status=400)

    user_id = data.get('user_id')
    
    # Try to detect and execute services
    try:
        detector = get_service_detector()
        service_response = detector.detect_and_execute(message, user_id)
        
        if service_response:
            # Service was executed, return formatted response directly
            return JsonResponse({
                'response': service_response['formatted_response'],
                'type': service_response.get('type', 'service_response'),
                'service_id': service_response.get('service_id'),
                'source': 'service'
            })
    except Exception as e:
        # Log error but continue with chatbot
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Service execution error: {str(e)}")
    
    # If no service matched or service failed, use chatbot AI
    bot = Chatbot()
    payload = __import__('asgiref').sync.async_to_sync(bot.respond)(message)
    
    return JsonResponse({
        'response': payload.get('response', ''),
        'type': 'chatbot_response',
        'source': 'chatbot_ai'
    })


@csrf_exempt
def api_chat(request):
    """
    API endpoint with service integration
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    try:
        require_api_key(request)
    except ApiAuthError:
        return JsonResponse({'error': 'Unauthorized'}, status=401)

    try:
        data = json.loads(request.body or b'{}')
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    message = (data.get('message') or '').strip()
    if not message:
        return JsonResponse({'error': 'Message cannot be empty'}, status=400)

    user_id = data.get('user_id')
    
    # Try service execution first
    try:
        detector = get_service_detector()
        service_response = detector.detect_and_execute(message, user_id)
        
        if service_response:
            return JsonResponse({
                'response': service_response['formatted_response'],
                'type': service_response.get('type', 'service_response'),
                'service_id': service_response.get('service_id'),
                'source': 'service',
                'score': 1.0,
                'category': service_response.get('service_id', '').split('-')[0]
            })
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Service execution error: {str(e)}")
    
    # Fallback to chatbot
    bot = Chatbot()
    payload = __import__('asgiref').sync.async_to_sync(bot.respond)(message)

    return JsonResponse({
        'response': payload.get('response', ''),
        'score': payload.get('score', 0.0),
        'category': payload.get('category', ''),
        'source': 'chatbot_ai',
        'matched_question': payload.get('matched_question', ''),
    })


# ============================================================================
# ORIGINAL FUNCTIONS (KEEP UNCHANGED)
# ============================================================================

def chat_page(request):
    return render(request, 'chatbot/chatbot.html')
