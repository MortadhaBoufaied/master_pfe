# Chatbot N8N Service Integration Guide

## Overview

The chatbot now includes automatic service detection for n8n-orchestrated services. When a user message matches service keywords, the chatbot detects the requested service(s) and routes the task to the n8n project for execution.

## Architecture

```
User Message
    ↓
[Chatbot] Intent Detection
    ↓
[Chatbot] Service Detection (keyword matching)
    ↓
IF service detected:
    ├→ [N8N Webhook] Execute Service
    └→ Return formatted response
    
IF no service detected:
    ├→ [ML Index] Semantic search
    └→ Return answer or fallback
```

## Available Services

The chatbot can detect and route the following services:

### Academy Services
- **Get Player Statistics** (`get-player-stats`): View player performance metrics
  - Keywords: stats, statistics, performance, rating, progress

- **Get Team Information** (`get-team-info`): Get team and division info
  - Keywords: team, division, squad, my team, team members

- **Get Upcoming Events** (`get-events`): List matches and training sessions
  - Keywords: event, match, training, upcoming, next match

- **Get Academy Information** (`get-academy-info`): General academy info
  - Keywords: academy, about academy, programs, divisions

### User Management Services
- **Get User Profile** (`get-user-profile`): Retrieve user profile information
  - Keywords: profile, my account, user info, show my profile

### Appointment Services
- **Book Appointment** (`book-appointment`): Schedule classes or training
  - Keywords: book, schedule, register, enroll, book training

- **Get Schedule** (`get-schedule`): Check available time slots
  - Keywords: availability, when, schedule, timetable, what time

- **Cancel Appointment** (`cancel-appointment`): Cancel bookings
  - Keywords: cancel, delete, unregister, withdraw

### Financial Services
- **Get Payment Status** (`get-payment-status`): Check payment and billing info
  - Keywords: payment, invoice, fees, billing, cost

### Feedback Services
- **Submit Feedback** (`submit-feedback`): Submit complaints or reviews
  - Keywords: feedback, review, complaint, suggestion, problem

### Scouting Services
- **Submit Scouting Report** (`submit-scouting-report`): Evaluate players
  - Keywords: scouting, scout, report, evaluate, talent

## How It Works

### 1. Service Detection (service_detection.py)
The `ServiceDetector` class:
- Loads services from `n8n-service-orchestration/service-registry/services.json`
- Uses fuzzy string matching (rapidfuzz) to detect services
- Matches user keywords against service registry keywords
- Returns detected service IDs with confidence scores (threshold: 70%)

### 2. Integration with Chatbot (bot.py)
The `Chatbot` class now includes a new response tier:
- Tier 1: Intent detection (greetings, thanks, help)
- Tier 2: **Service detection (NEW)** ← You are here
- Tier 3: ML-based semantic search
- Tier 4: Fallback response

### 3. Service Execution (n8n_service_executor.py)
The `N8NServiceExecutor` class:
- Receives detected services with parameters
- Routes them to n8n webhooks
- Handles execution, timeouts, and errors
- Returns formatted responses

## Configuration

### Django Settings (chatbot/settings.py)

Add n8n configuration:

```python
# N8N Service Integration
N8N_BASE_URL = os.getenv('N8N_BASE_URL', 'http://localhost:5678')
N8N_TIMEOUT = int(os.getenv('N8N_TIMEOUT', '10'))  # seconds

# Service Detection Threshold
SERVICE_DETECTION_THRESHOLD = 70.0  # 0-100, percentage confidence
```

### Environment Variables (.env)

```
N8N_BASE_URL=http://localhost:5678
N8N_TIMEOUT=10
```

## Usage Examples

### Example 1: Player Stats Request
```
User: "Show me my player statistics"
→ Service detected: get-player-stats
→ Confidence: 95%
→ N8N executes: GET /webhook/get-player-stats
→ Response: Player performance card with stats
```

### Example 2: Multiple Services
```
User: "Book me a training session and show available times"
→ Services detected: book-appointment, get-schedule
→ Both services executed concurrently
→ Combined response with schedule and booking form
```

### Example 3: Intent Detection (Still Works)
```
User: "Hello there!"
→ Intent detected: greeting
→ Predefined response returned
→ (Service detection skipped)
```

### Example 4: Fallback Handling
```
User: "What's 2+2?"
→ No service detected
→ ML search executed
→ If no match found: Fallback message with service hints
```

## API Response Format

When a service is detected, the chatbot returns:

```json
{
  "response": "I can help you with: Get Player Statistics. Let me route your request to the appropriate service...",
  "score": 0.85,
  "category": "service_detection",
  "source": "n8n_services",
  "matched_question": null,
  "services": ["get-player-stats"],
  "service_details": [
    {
      "id": "get-player-stats",
      "name": "Get Player Statistics",
      "description": "Retrieve player performance statistics and analytics",
      "category": "academy",
      "requires_authentication": true
    }
  ]
}
```

## Error Handling

The system handles various error scenarios:

1. **Service not found**: Logs warning, continues to ML search
2. **N8N timeout**: Returns error message, suggests retrying
3. **Connection error**: Returns service unavailable message
4. **Invalid parameters**: Returns error with hint for valid parameters

## Adding New Services

To add new services:

1. **Update services.json** in `n8n-service-orchestration/service-registry/`:
```json
{
  "id": "new-service-id",
  "name": "New Service Name",
  "description": "Description of what the service does",
  "category": "academy",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "enabled": true,
  "webhook_path": "/webhook/new-service-id",
  ...
}
```

2. **Create n8n workflow** at `/workflows/new-service-id.json`

3. **Deploy to n8n** and create webhook

4. **Restart chatbot** to reload service registry

## Monitoring and Logging

The system logs all service detections and executions:

```python
# View service detection logs
python manage.py runserver --log-level DEBUG

# Search logs
grep "Services detected" logs/chatbot.log
grep "Service.*executed" logs/chatbot.log
```

## Performance Considerations

- Service detection: ~5-10ms (fuzzy matching)
- N8N execution: Configurable timeout (default: 10s)
- Service registry: Loaded once at startup, cached in memory

## Troubleshooting

### Services not being detected
- Check service keywords in `services.json`
- Verify fuzzy match threshold (default 70%)
- Check logs: `grep "SERVICE" logs/chatbot.log`

### N8N webhooks not responding
- Verify N8N is running: `curl http://localhost:5678`
- Check N8N_BASE_URL in settings
- Verify webhook paths in services.json match n8n workflows

### False positives (wrong service detected)
- Adjust keywords in services.json
- Lower SERVICE_DETECTION_THRESHOLD if too high
- Add conflicting keywords to prevent false matches

## Related Files

- **Service Detection**: `apps/chat/services/service_detection.py`
- **Chatbot Core**: `apps/chat/services/bot.py`
- **N8N Executor**: `apps/chat/services/n8n_service_executor.py`
- **Service Registry**: `../../n8n-service-orchestration/service-registry/services.json`
- **Test Suite**: `apps/chat/tests/test_service_detection.py`
