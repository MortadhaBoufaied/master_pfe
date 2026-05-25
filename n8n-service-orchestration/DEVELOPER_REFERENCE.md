# Service Orchestration - Developer Reference

## Quick API Reference

### Service Detector

```python
from chatbot_integration.service_detector import SyncServiceDetector

# Initialize
detector = SyncServiceDetector()

# Detect services from message
service_response = detector.detect_and_execute(
    message="Book me an appointment on Monday",
    user_id="user123"
)

# Returns:
# {
#     'type': 'service_response',
#     'service_id': 'book-appointment',
#     'formatted_response': '✅ **Booking Confirmed!**...',
#     'raw_response': {...}
# }
```

### Service Matcher

```python
from service_registry.service_matcher import ServiceMatcher

matcher = ServiceMatcher()

# Detect services
services = matcher.detect_services("I want to book an appointment")
# Returns: ['book-appointment']

# Get service info
service = matcher.get_service_by_id('book-appointment')
# Returns: {...service details...}

# Extract parameters
params = matcher.extract_parameters("Book me on May 15 at 2pm", 'book-appointment')
# Returns: {'date': '2026-05-15', 'time': '14:00', ...}

# Validate parameters
is_valid, error_msg = matcher.validate_parameters('book-appointment', params)
# Returns: (True, None) or (False, "error message")

# List all services
services = matcher.list_all_services()
# Returns: [{id, name, description, category, keywords}, ...]

# Get services by category
services = matcher.get_services_by_category('appointments')
```

### Response Formatter

```python
from service_registry.response_formatter import ResponseFormatter

formatter = ResponseFormatter()

# Format using template
response = formatter.format_response(
    'booking_confirmation',
    {
        'service_type': 'Haircut',
        'date': '2026-05-15',
        'time': '14:30',
        'booking_id': 'BOOK-123'
    }
)
# Returns: "✅ **Booking Confirmed!**\n\n**Service:** Haircut..."

# Format complete service response
formatted = formatter.format_service_response(
    service_id='get-user-profile',
    response_data={'status': 'success', 'data': {...}},
    status='success'
)

# Format multiple services
combined = formatter.format_multiple_services_response([
    {'service_id': 'get-profile', 'formatted_response': '...'},
    {'service_id': 'get-schedule', 'formatted_response': '...'}
])

# Handle errors
error_response = formatter.handle_error("Connection failed", "REF-123")
timeout_response = formatter.handle_timeout('service-id')
```

### Service Executor

```python
from webhooks.service_executor import SyncServiceExecutor

executor = SyncServiceExecutor()

# Execute single service
response = executor.execute_service(
    service_id='book-appointment',
    parameters={'date': '2026-05-15', 'time': '14:30'},
    user_id='user123'
)

# Execute multiple services
response = executor.execute_multiple_services(
    services=[
        {'service_id': 'get-profile', 'parameters': {}},
        {'service_id': 'get-schedule', 'parameters': {'service_type': 'haircut'}}
    ],
    user_id='user123'
)
```

## Adding New Services

### 1. Define Service in Registry

Edit `service-registry/services.json`:

```json
{
  "id": "my-service",
  "name": "My Service Name",
  "description": "What this service does",
  "category": "category-name",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "enabled": true,
  "webhook_path": "/webhook/my-service",
  "timeout_ms": 5000,
  "parameters": {
    "param1": {
      "type": "string",
      "required": true,
      "description": "Parameter description"
    }
  },
  "responses": {
    "success": "my_service_response",
    "error": "error_default"
  }
}
```

### 2. Add Response Template

Edit `service-registry/response-templates.json`:

```json
{
  "my_service_response": {
    "template": "✅ **Service Result**\n\n{result_data}\n\n---\nThank you!",
    "format": "markdown",
    "fallback": "Service executed successfully."
  }
}
```

### 3. Create N8N Workflow

1. Go to n8n UI
2. Create new workflow
3. Add Webhook node with path `/webhook/my-service`
4. Add logic to process request
5. Format and return response
6. Export as JSON to `workflows/example-services/my-service.json`

### 4. Test Service

```python
from service_registry.service_matcher import ServiceMatcher

matcher = ServiceMatcher()

# Test detection
services = matcher.detect_services("Message that triggers your service")
print(services)  # Should include 'my-service'

# Test parameter extraction
params = matcher.extract_parameters("Your message", 'my-service')
print(params)
```

## Customizing Service Detection

### Adjust Detection Threshold

Lower threshold = more false positives, higher recall
Higher threshold = fewer matches, higher precision

```python
# Default: 70%
services = matcher.match_services(message, threshold=70.0)

# Lower threshold for broader matching
services = matcher.match_services(message, threshold=60.0)
```

### Implement Custom Parameter Extraction

In `service_matcher.py`, modify `_extract_parameter_value()`:

```python
def _extract_parameter_value(self, message: str, param_name: str, param_info: Dict) -> Optional[str]:
    """Custom extraction logic"""
    
    if param_name == 'custom_param':
        # Add regex pattern
        import re
        match = re.search(r'pattern', message)
        if match:
            return match.group(0)
    
    # Use NER for entity extraction
    if param_info.get('type') == 'entity':
        import spacy
        nlp = spacy.load('en_core_web_sm')
        doc = nlp(message)
        for ent in doc.ents:
            if ent.label_ == 'ENTITY_TYPE':
                return ent.text
    
    return None
```

### Add Custom Response Formatting

```python
from service_registry.response_formatter import ResponseFormatter

class CustomFormatter(ResponseFormatter):
    def format_response(self, template_name, data):
        # Custom formatting logic
        if template_name == 'custom':
            return f"Custom format: {data}"
        return super().format_response(template_name, data)
```

## Integration with Django

### Middleware Approach

```python
# middleware.py
class ServiceIntegrationMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.detector = SyncServiceDetector()
    
    def __call__(self, request):
        # Process service requests
        if request.path == '/api/chat' and request.method == 'POST':
            message = request.POST.get('message', '')
            response = self.detector.detect_and_execute(message)
            if response:
                # Return service response
                pass
        
        return self.get_response(request)
```

### View Decorator Approach

```python
from functools import wraps
from service_detector import SyncServiceDetector

def try_service_first(view_func):
    @wraps(view_func)
    def wrapper(request):
        detector = SyncServiceDetector()
        message = request.POST.get('message', '')
        
        service_response = detector.detect_and_execute(message)
        if service_response:
            return JsonResponse({
                'response': service_response['formatted_response'],
                'source': 'service'
            })
        
        return view_func(request)
    
    return wrapper

# Usage
@try_service_first
def chat_view(request):
    # Falls back to chatbot AI
    bot = Chatbot()
    return JsonResponse({'response': bot.respond(message)})
```

## Error Handling

### Common Error Cases

```python
try:
    response = detector.detect_and_execute(message)
except TimeoutError:
    return formatter.handle_timeout(service_id)
except ValueError as e:
    return formatter.handle_error(str(e))
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    return formatter.handle_error("An unexpected error occurred")
```

### Graceful Degradation

```python
# If service fails, fallback to chatbot
try:
    service_response = detector.detect_and_execute(message, user_id)
    if service_response:
        return service_response
except Exception as e:
    logger.warning(f"Service execution failed: {e}")

# Fall back to chatbot AI
bot = Chatbot()
return bot.respond(message)
```

## Performance Optimization

### Caching Service Registry

```python
from functools import lru_cache

class OptimizedServiceMatcher(ServiceMatcher):
    @lru_cache(maxsize=128)
    def _calculate_confidence(self, message_lower, service_id):
        # Cached confidence calculation
        pass
```

### Async Operations

```python
import asyncio

async def process_user_request(message, user_id):
    detector = SyncServiceDetector()
    response = await detector.detect_and_execute(message, user_id)
    return response
```

### Batch Processing

```python
# Process multiple requests
messages = ["Book an appointment", "Show profile", "Check status"]
responses = []

for msg in messages:
    response = detector.detect_and_execute(msg)
    responses.append(response)
```

## Logging & Debugging

### Enable Debug Logging

```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Log service detection
logger.debug(f"Services detected: {services}")
logger.debug(f"Parameters extracted: {params}")
logger.debug(f"Response formatted: {formatted}")
```

### Monitor Service Performance

```python
import time

start = time.time()
response = executor.execute_service(service_id, params)
elapsed = time.time() - start

logger.info(f"Service {service_id} executed in {elapsed*1000:.2f}ms")
```

## Best Practices

1. **Always validate parameters** before execution
2. **Use timeouts** to prevent hanging requests
3. **Handle errors gracefully** with fallback to chatbot
4. **Log important events** for debugging
5. **Test extensively** with quick_test.py
6. **Monitor performance** in production
7. **Update keywords** based on user queries
8. **Document custom services** thoroughly

## Testing Examples

```bash
# Unit tests
pytest tests/test_service_detector.py -v

# Integration tests
pytest tests/test_integration.py -v

# Manual testing
python tests/quick_test.py

# API testing
curl -X POST http://localhost:8000/api/chat \
  -d '{"message": "Book an appointment"}'
```
