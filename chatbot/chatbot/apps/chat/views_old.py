import json
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

from apps.chat.services.bot import Chatbot
from apps.chat.services.api_auth import require_api_key, ApiAuthError


def chat_page(request):
    return render(request, 'chatbot/chatbot.html')


@csrf_exempt
def chat_post(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    try:
        data = json.loads(request.body or b'{}')
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    message = (data.get('message') or '').strip()
    if not message:
        return JsonResponse({'error': 'Message cannot be empty'}, status=400)

    bot = Chatbot()
    payload = __import__('asgiref').sync.async_to_sync(bot.respond)(message)
    return JsonResponse({'response': payload.get('response', '')})


@csrf_exempt
def api_chat(request):
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

    bot = Chatbot()
    payload = __import__('asgiref').sync.async_to_sync(bot.respond)(message)

    # Keep response stable for other apps
    return JsonResponse({
        'response': payload.get('response', ''),
        'score': payload.get('score', 0.0),
        'category': payload.get('category', ''),
        'source': payload.get('source', ''),
        'matched_question': payload.get('matched_question', ''),
    })
