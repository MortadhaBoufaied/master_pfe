"""API endpoints for the chatbot service."""

import json
import logging
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.contrib.admin.views.decorators import staff_member_required
from asgiref.sync import async_to_sync

from apps.chat.services.bot import Chatbot
from apps.chat.services.api_auth import require_api_key, ApiAuthError
from apps.chat.services.security import RateLimiter, InputValidator
from apps.chat.services.monitoring import HealthChecker, MetricsCollector
from apps.chat.services.service_auth import get_service_auth_client

logger = logging.getLogger('chatbot')


def chat_page(request):
    """
    Render chatbot UI page.
    
    GET /
    """
    logger.debug("Rendering chat page")
    return render(request, 'chatbot/chatbot.html')


@csrf_exempt
def chat_post(request):
    """
    Handle chat messages from web UI with optional user authentication.
    
    POST / or POST /chat
    
    Request JSON:
        {
            "message": "user message",
            "sender_id": "optional",
            "user_id": "optional - user ID for permission checking"
        }
    
    Response JSON:
        {
            "response": "answer",
            "score": 0.85,
            "category": "Fee Info",
            "source": "Academy Info",
            "services": ["scouting_report", ...],  # Only if services detected
            "authorization": {...}  # Only if authorization info needed
        }
    """
    if request.method != 'POST':
        logger.warning(f"Invalid method: {request.method} (expected POST)")
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    # Rate limiting
    identifier = RateLimiter.get_identifier(request)
    if not RateLimiter.is_allowed(identifier):
        logger.warning(f"Rate limit exceeded for {identifier}")
        return JsonResponse({'error': 'Too many requests'}, status=429)

    try:
        # Parse JSON
        try:
            data = json.loads(request.body or b'{}')
        except json.JSONDecodeError as e:
            logger.warning(f"Invalid JSON received: {e}")
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

        # Get message
        message = (data.get('message') or '').strip()
        
        # Validate message
        is_valid, error = InputValidator.validate_message(message)
        if not is_valid:
            logger.warning(f"Invalid message: {error}")
            return JsonResponse({'error': error}, status=400)

        # Get optional sender_id
        sender_id = data.get('sender_id', '').strip()
        is_valid, error = InputValidator.validate_sender_id(sender_id)
        if not is_valid:
            logger.warning(f"Invalid sender_id: {error}")
            return JsonResponse({'error': error}, status=400)

        # Get optional user_id for authorization
        user_id = data.get('user_id')
        if user_id:
            try:
                user_id = int(user_id)
                logger.debug(f"Chat request from user {user_id}")
            except (TypeError, ValueError):
                logger.warning(f"Invalid user_id: {user_id}")
                user_id = None

        # Get response from chatbot
        bot = Chatbot()
        payload = async_to_sync(bot.respond)(message)
        
        logger.debug(f"Chat response: score={payload.get('score')}, category={payload.get('category')}")
        
        # If services are detected and user_id provided, check authorization
        response_data = {
            'response': payload.get('response', ''),
            'score': payload.get('score', 0.0),
            'category': payload.get('category', ''),
            'source': payload.get('source', ''),
        }

        if payload.get('services') and user_id:
            # Check if user can access the detected services
            service_auth = get_service_auth_client()
            services = payload.get('services', [])
            
            authorization_info = {
                'user_id': user_id,
                'services_detected': services,
                'access_results': {}
            }
            
            for service in services[:3]:  # Check top 3 services
                access_result = async_to_sync(service_auth.check_service_access)(
                    user_id, service
                )
                authorization_info['access_results'][service] = access_result
            
            response_data['authorization'] = authorization_info
            
            # If any service is denied, add explanation
            denied_services = [
                s for s, result in authorization_info['access_results'].items()
                if not result.get('can_access')
            ]
            if denied_services:
                response_data['note'] = (
                    f"Some services in your request require higher permissions. "
                    f"Here's what you can access: {', '.join(authorization_info['access_results'].keys())}"
                )
        
        return JsonResponse(response_data)

    except Exception as e:
        logger.error(f"Error in chat_post: {e}", exc_info=True)
        MetricsCollector.record_error('chat_post_error', str(e))
        return JsonResponse({'error': 'Internal server error'}, status=500)


@csrf_exempt
def api_chat(request):
    """
    API endpoint for chat with authentication.
    
    POST /api/chat
    Headers:
        X-API-Key: your-secret-key
    
    Request JSON:
        {
            "message": "user message",
            "sender_id": "optional",
            "user_id": "optional - user ID for permission checking"
        }
    
    Response JSON:
        {
            "response": "answer",
            "score": 0.85,
            "category": "Fee Info",
            "source": "Academy Info",
            "matched_question": "How much are fees?",
            "authorization": {...}  # Only if user_id provided
        }
    """
    if request.method != 'POST':
        logger.warning(f"API: Invalid method {request.method}")
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    # Rate limiting
    identifier = RateLimiter.get_identifier(request)
    if not RateLimiter.is_allowed(identifier):
        logger.warning(f"API: Rate limit exceeded for {identifier}")
        return JsonResponse({'error': 'Too many requests'}, status=429)

    # API authentication
    try:
        require_api_key(request)
    except ApiAuthError as e:
        logger.warning(f"API authentication failed: {e}")
        return JsonResponse({'error': 'Unauthorized'}, status=401)

    try:
        # Parse JSON
        try:
            data = json.loads(request.body or b'{}')
        except json.JSONDecodeError as e:
            logger.warning(f"API: Invalid JSON - {e}")
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

        # Get message
        message = (data.get('message') or '').strip()
        
        # Validate message
        is_valid, error = InputValidator.validate_message(message)
        if not is_valid:
            logger.warning(f"API: Invalid message - {error}")
            return JsonResponse({'error': error}, status=400)

        # Get optional sender_id
        sender_id = data.get('sender_id', '').strip()
        is_valid, error = InputValidator.validate_sender_id(sender_id)
        if not is_valid:
            logger.warning(f"API: Invalid sender_id - {error}")
            return JsonResponse({'error': error}, status=400)

        # Get optional user_id for authorization
        user_id = data.get('user_id')
        if user_id:
            try:
                user_id = int(user_id)
                logger.debug(f"API chat request from user {user_id}")
            except (TypeError, ValueError):
                logger.warning(f"API: Invalid user_id: {user_id}")
                user_id = None

        # Get response from chatbot
        bot = Chatbot()
        payload = async_to_sync(bot.respond)(message)
        
        logger.info(f"API response: score={payload.get('score')}, source={payload.get('source')}")

        # Build response
        response_data = {
            'response': payload.get('response', ''),
            'score': payload.get('score', 0.0),
            'category': payload.get('category', ''),
            'source': payload.get('source', ''),
            'matched_question': payload.get('matched_question', ''),
        }

        # If services detected, include them
        if payload.get('services'):
            response_data['services'] = payload.get('services', [])

        # If user_id provided, check authorization
        if user_id:
            service_auth = get_service_auth_client()
            user_info = async_to_sync(service_auth.get_user_info)(user_id)
            if user_info:
                response_data['user_info'] = {
                    'user_id': user_id,
                    'user_role': user_info.get('user_role'),
                    'available_services': user_info.get('available_services', []),
                }

        return JsonResponse(response_data)

    except Exception as e:
        logger.error(f"Error in api_chat: {e}", exc_info=True)
        MetricsCollector.record_error('api_chat_error', str(e))
        return JsonResponse({'error': 'Internal server error'}, status=500)


@csrf_exempt
def health_check(request):
    """
    Health check endpoint.
    
    GET /health
    
    Returns system health status.
    """
    if request.method != 'GET':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    logger.debug("Health check requested")
    health = HealthChecker.check_health()
    
    status_code = 200 if health.get('status') == 'healthy' else 503
    return JsonResponse(health, status=status_code)


@staff_member_required
def metrics(request):
    """
    Metrics endpoint (requires admin authentication).
    
    GET /metrics
    
    Returns service metrics and statistics.
    """
    if request.method != 'GET':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    logger.debug("Metrics requested by admin")
    stats = MetricsCollector.get_stats()
    
    return JsonResponse({
        'success': True,
        'data': stats,
    })


@csrf_exempt
def test_auth(request):
    """
    Test endpoint to verify API key authentication.
    
    GET /test-auth
    
    Useful for debugging authentication issues.
    """
    try:
        require_api_key(request)
        return JsonResponse({'success': True, 'message': 'API key is valid'})
    except ApiAuthError:
        return JsonResponse({'success': False, 'message': 'API key is invalid or missing'}, status=401)
    except Exception as e:
        logger.error(f"Error in test_auth: {e}")
        return JsonResponse({'success': False, 'message': 'Internal error'}, status=500)
