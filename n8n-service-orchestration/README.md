# N8N Service Orchestration for Chatbot

A comprehensive service orchestration system using n8n that extends the Django chatbot with dynamic service execution capabilities. This system detects user intent for specific services and executes them through n8n workflows, returning formatted responses directly without additional chatbot processing.

## Architecture Overview

```
User Message
    ↓
[Chatbot] Detects Intent & Service IDs
    ↓
[Service Detection] Matches to Registered Services
    ↓
[N8N Webhook] Receives Service Request(s)
    ↓
[N8N Workflow] Executes Service(s)
    ↓
[Response Formatter] Formats Results
    ↓
[Direct Response] Returns to User (Bypasses Chatbot AI)
```

## Features

- **Dynamic Service Registry**: Centralized management of available services with IDs
- **Intent Detection**: Identifies when users request specific services
- **Multi-Service Handling**: Executes multiple services in a single request
- **Workflow Orchestration**: n8n workflows for each service
- **Direct Response**: Formatted responses bypass chatbot AI for efficiency
- **Fallback to AI**: If no service matches, chatbot uses AI algorithms
- **API Integration**: REST API for chatbot-n8n communication

## Directory Structure

```
n8n-service-orchestration/
├── README.md
├── docker-compose.yml          # N8N with PostgreSQL setup
├── .env.example                # Environment variables
│
├── service-registry/
│   ├── services.json           # Master service registry
│   ├── service-definitions.json # Service metadata
│   ├── response-templates.json  # Response templates for each service
│   └── service-matcher.py      # Service matching logic
│
├── webhooks/
│   ├── service-executor.py     # Webhook handler for service execution
│   ├── response-formatter.py   # Format service responses
│   └── error-handler.py        # Error handling
│
├── workflows/
│   ├── base-service-executor.json   # Base workflow template (import to N8N)
│   ├── example-services/
│   │   ├── get-user-profile.json
│   │   ├── book-appointment.json
│   │   ├── get-schedule.json
│   │   ├── submit-feedback.json
│   │   └── get-payment-status.json
│   └── README.md                     # Workflow documentation
│
├── chatbot-integration/
│   ├── service_detector.py     # Integration with chatbot
│   ├── n8n_client.py           # N8N API client
│   └── response_handler.py     # Response handling
│
└── tests/
    ├── test_service_registry.py
    ├── test_service_matcher.py
    ├── test_webhook_handler.py
    └── test_integration.py
```

## Quick Start

### 1. Docker Setup
```bash
cd n8n-service-orchestration
docker-compose up -d
```

### 2. Configure N8N
- Access n8n at http://localhost:5678
- Import workflows from `workflows/example-services/`
- Create webhook URLs for each service

### 3. Register Services
Edit `service-registry/services.json` with your services

### 4. Update Chatbot
Copy `chatbot-integration/` files to your Django chatbot
Add service detection to the chatbot pipeline

## Service Registry

Each service has:
- `id`: Unique identifier
- `name`: Human-readable name
- `keywords`: List of user intent triggers
- `workflow_id`: n8n workflow ID
- `webhook_url`: n8n webhook endpoint
- `response_type`: "direct" or "formatted"
- `parameters`: Expected input parameters
- `responses`: Template responses

## Chatbot Integration Flow

1. User sends message to chatbot
2. Chatbot detects intent and service IDs
3. If service detected:
   - Extract service parameters
   - Call n8n webhook with service ID + parameters
   - Format response
   - Return directly to user
4. If no service:
   - Chatbot uses AI algorithms on database
   - Return AI-based response

## Configuration

See `.env.example` for all configuration options:
- N8N_WEBHOOK_URL: Base webhook URL
- CHATBOT_API_URL: Chatbot API endpoint
- SERVICE_TIMEOUT: Service execution timeout
- LOG_LEVEL: Logging level

## Service Response Format

```json
{
  "service_id": "get-user-profile",
  "status": "success",
  "data": {...},
  "formatted_response": "Your profile information...",
  "execution_time_ms": 234
}
```

## Error Handling

- Service timeout → Fallback to chatbot AI
- Service error → Error message with suggestion
- Invalid service ID → Handled gracefully
- Multiple services: One fails → Other continues, report partial result

## Multi-Service Requests

If user asks for multiple services:
```json
{
  "services": [
    {"id": "get-schedule", "parameters": {}},
    {"id": "get-payment-status", "parameters": {"user_id": "123"}}
  ]
}
```

Response includes results from all services in one formatted message.

## Deployment

### Production Deployment
1. Configure database (PostgreSQL recommended)
2. Set up reverse proxy (nginx)
3. Enable HTTPS for webhooks
4. Configure service timeouts
5. Set up monitoring and logging

### Cloud Options
- **n8n Cloud**: Use n8n managed service
- **Self-hosted**: Docker on your server
- **Kubernetes**: For large scale deployments

## Security

- API Key authentication for webhooks
- Request validation
- Rate limiting
- Service ID whitelisting
- Parameter sanitization

## Monitoring & Logging

- Workflow execution logs in n8n
- Service metrics dashboard
- Performance tracking
- Error alerts

## Example Services

### Get User Profile
Fetches user information from backend
- **Keywords**: "my profile", "user info", "account"
- **Parameters**: user_id (optional, from session)
- **Response**: Formatted user profile card

### Book Appointment
Schedule appointments with services
- **Keywords**: "book", "schedule", "appointment"
- **Parameters**: service_type, date, time
- **Response**: Confirmation with booking details

### Get Schedule
Retrieve available time slots
- **Keywords**: "availability", "when", "schedule"
- **Parameters**: service_type, duration
- **Response**: List of available slots

### Submit Feedback
Send user feedback
- **Keywords**: "feedback", "review", "complaint"
- **Parameters**: message, rating (optional)
- **Response**: Confirmation message

## Next Steps

1. Define all services in `services.json`
2. Create response templates in `response-templates.json`
3. Build n8n workflows for each service
4. Test service detection and execution
5. Integrate with chatbot
6. Deploy and monitor

## Support

For issues or questions, refer to:
- [n8n Documentation](https://docs.n8n.io/)
- [N8N Workflows Best Practices](./workflows/README.md)
- [Chatbot Integration Guide](./chatbot-integration/README.md)
