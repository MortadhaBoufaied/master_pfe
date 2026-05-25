# N8N Service Orchestration - Complete Setup Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Deployment](#deployment)
6. [Integration with Chatbot](#integration-with-chatbot)
7. [Testing](#testing)
8. [Production Deployment](#production-deployment)
9. [Troubleshooting](#troubleshooting)

## Overview

This n8n service orchestration system provides:

- **Service Detection**: Automatically detects when users ask for specific services
- **Service Execution**: Executes services through n8n workflows
- **Response Formatting**: Formats service responses for direct user consumption
- **Multi-Service Handling**: Executes multiple services in one request
- **Fallback to AI**: If no service matches, chatbot uses AI

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Message                             │
└─────────────┬───────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Django Chatbot                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Service Detector                                         │   │
│  │ - Detects service IDs from user message                │   │
│  │ - Extracts parameters                                   │   │
│  │ - Validates parameters                                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────┬───────────────────────────────────────────────────┘
              │ (Service Request)
              ▼
┌─────────────────────────────────────────────────────────────────┐
│              N8N Service Orchestration                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Service Executor                                         │   │
│  │ - Calls N8N webhooks                                     │   │
│  │ - Handles timeouts                                       │   │
│  │ - Manages multiple services                             │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────┬───────────────────────────────────────────────────┘
              │
              ├──────────────────────────┐
              │                          │
              ▼                          ▼
        ┌──────────────┐        ┌──────────────┐
        │ N8N Workflows│        │ N8N Workflows│
        │    Service 1 │        │    Service 2 │
        └──────┬───────┘        └──────┬───────┘
               │                       │
               ▼                       ▼
        ┌──────────────┐        ┌──────────────┐
        │ Backend API  │        │ Backend API  │
        │   Endpoint 1 │        │   Endpoint 2 │
        └──────┬───────┘        └──────┬───────┘
               │                       │
               └───────────┬───────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│           Response Formatter                                    │
│  - Formats responses using templates                           │
│  - Handles multiple service responses                          │
│  - Error handling                                              │
└─────────────┬───────────────────────────────────────────────────┘
              │ (Formatted Response)
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    User Response                                │
│  Returns directly without passing to chatbot AI                │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Python 3.9+
- Docker & Docker Compose (for easy n8n setup)
- Node.js 18+ (if running n8n locally)
- PostgreSQL 12+ (for n8n database)
- Django 4.0+ (for chatbot)

## Installation

### Step 1: Clone/Download Project

```bash
cd d:\master_pfe\n8n-service-orchestration
```

### Step 2: Install Python Dependencies

```bash
# Install required packages
pip install -r requirements.txt

# Or minimal installation (without optional ML packages)
pip install rapidfuzz python-dotenv httpx
```

### Step 3: Setup N8N with Docker

```bash
# Copy environment file
cp .env.example .env

# Edit .env with your configuration
# Important: Change N8N_ENCRYPTION_KEY, N8N_DB_PASSWORD

# Start n8n and database
docker-compose up -d

# Wait for services to be ready (30 seconds)
docker-compose logs -f n8n

# Access n8n at http://localhost:5678
```

### Step 4: Import Workflows to N8N

1. Open n8n UI at `http://localhost:5678`
2. Click "New" → "Import from JSON"
3. Select a workflow from `workflows/example-services/`
4. Configure the webhook URL (should match service ID)
5. Update backend API endpoints
6. Activate the workflow

Repeat for all services in `workflows/example-services/`:
- `get-user-profile.json`
- `book-appointment.json`
- `get-schedule.json`
- `submit-feedback.json`
- `get-payment-status.json`
- `cancel-appointment.json`
- `get-service-details.json`
- `track-order.json`
- `get-faq.json`

## Configuration

### .env Configuration

```bash
# N8N
N8N_WEBHOOK_URL=http://localhost:5678/webhook
N8N_PORT=5678

# Service Configuration
SERVICE_TIMEOUT_MS=5000
ENABLE_SERVICE_CACHING=true

# Backend
BACKEND_API_URL=http://localhost:8080/api

# Environment
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=info
```

### Service Registry

Edit `service-registry/services.json` to:
- Add new services
- Modify keywords
- Update webhook paths
- Configure parameters

### Response Templates

Edit `service-registry/response-templates.json` to:
- Customize response messages
- Add new templates
- Modify formatting

## Integration with Chatbot

### Step 1: Copy Files to Chatbot

```bash
# From n8n-service-orchestration directory
copy-item service-registry chatbot\apps\chat\services\n8n_registry
copy-item chatbot-integration chatbot\n8n_integration
copy-item webhooks chatbot\n8n_integration
```

### Step 2: Update Django Settings

Add to `chatbot/settings.py`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

# N8N Configuration
N8N_WEBHOOK_URL = os.getenv('N8N_WEBHOOK_URL', 'http://localhost:5678/webhook')
SERVICE_TIMEOUT_MS = int(os.getenv('SERVICE_TIMEOUT_MS', '5000'))
ENABLE_N8N_SERVICES = os.getenv('ENABLE_N8N_SERVICES', 'true').lower() == 'true'
```

### Step 3: Update Chatbot Views

Modify `chatbot/apps/chat/views.py` with the enhanced version from `chatbot-integration/views_modified.py`:

The key changes:
1. Import ServiceDetector
2. Check for services before calling chatbot AI
3. Return service response directly if matched
4. Fall back to chatbot AI if no service

### Step 4: Install Chatbot Dependencies

Add to `requirements.txt`:

```
httpx>=0.24.0
rapidfuzz>=3.0.0
python-dotenv>=1.0.0
```

Then:

```bash
pip install -r requirements.txt
```

## Testing

### Manual Testing

```bash
# Test service detection
python tests/quick_test.py

# Run unit tests
python -m pytest tests/test_service_detector.py -v

# Run integration tests
python -m pytest tests/test_integration.py -v
```

### API Testing

```bash
# Test webhook directly
curl -X POST http://localhost:5678/webhook/get-user-profile \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": "get-user-profile",
    "parameters": {"user_id": "123"},
    "timestamp": "2026-05-08T10:00:00Z"
  }'

# Test through chatbot
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{"message": "Show me my profile"}'
```

### Browser Testing

1. Open chatbot web UI at `http://localhost:8000`
2. Send messages that should trigger services:
   - "Book me an appointment"
   - "What times are available?"
   - "Show my profile"
   - etc.
3. Check that responses are formatted correctly

## Deployment

### Development Deployment

```bash
# Start chatbot
cd chatbot
python manage.py runserver 0.0.0.0:8000

# Start n8n (in another terminal)
cd ../n8n-service-orchestration
docker-compose up

# Test the full flow
python tests/quick_test.py
```

### Production Deployment

#### 1. Security Configuration

```bash
# Generate strong encryption key
python -c "import secrets; print(secrets.token_hex(32))"

# Update .env with production values
N8N_ENCRYPTION_KEY=your_generated_key
N8N_DB_PASSWORD=strong_password
DEBUG=false
LOG_LEVEL=warning
```

#### 2. Database Setup

```bash
# Use external PostgreSQL (recommended for production)
# Update docker-compose.yml to connect to external DB

# Or use hosted database service (AWS RDS, Google Cloud SQL, etc.)
```

#### 3. Deploy N8N

Option A: Docker Swarm
```bash
docker stack deploy -c docker-compose.yml n8n-services
```

Option B: Kubernetes
```bash
# Create Helm chart or use existing n8n Helm chart
helm install n8n n8n-community/n8n -f values.yaml
```

Option C: N8N Cloud
```bash
# Use managed n8n.cloud service
# No deployment needed, just configure webhooks
```

#### 4. Configure Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl;
    server_name n8n.your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

#### 5. Enable Monitoring

```bash
# Monitor n8n logs
docker logs -f n8n

# Monitor chatbot logs
tail -f chatbot/logs/chatbot.log

# Set up alerting for errors
```

## Troubleshooting

### Service Not Detected

**Problem**: User message doesn't match any service

**Solution**:
1. Check keywords in `services.json`
2. Increase threshold in `service_matcher.py`
3. Test with `quick_test.py`

```python
# In views.py
services = detector.match_services(message, threshold=60)  # Lower threshold
```

### N8N Webhook Timeout

**Problem**: "Service execution timeout" error

**Solution**:
1. Increase timeout in `.env`
```bash
SERVICE_TIMEOUT_MS=10000  # Increase to 10 seconds
```

2. Check n8n workflow performance
3. Optimize backend API calls

### Parameters Not Extracted

**Problem**: Service executes but parameters are missing

**Solution**:
1. Implement custom extraction in `extract_parameter_value()`
2. Use NER (Named Entity Recognition):

```python
import spacy
nlp = spacy.load('en_core_web_sm')
# Use NER to extract entities
```

### Database Connection Error

**Problem**: PostgreSQL connection failed

**Solution**:
1. Check database is running: `docker ps`
2. Verify credentials in `.env`
3. Check database logs: `docker logs n8n-postgres`

### CORS Errors

**Problem**: Webhook calls blocked by CORS

**Solution**:
1. Configure CORS in n8n settings
2. Use proper headers in webhook calls
3. Test with curl first

## Monitoring & Maintenance

### Health Checks

```bash
# Check n8n status
curl http://localhost:5678/healthz

# Check chatbot status
curl http://localhost:8000/health
```

### Performance Monitoring

Monitor key metrics:
- Service detection accuracy
- Execution time per service
- Error rate
- Response time
- Database query performance

### Backup & Recovery

```bash
# Backup n8n data
docker-compose exec postgres pg_dump -U n8n n8n > backup.sql

# Restore from backup
docker-compose exec -T postgres psql -U n8n n8n < backup.sql

# Backup service registry
cp service-registry/services.json service-registry/services.json.bak
```

## Next Steps

1. ✅ Test the system locally
2. ✅ Customize services for your needs
3. ✅ Deploy to staging environment
4. ✅ Performance testing and optimization
5. ✅ Deploy to production
6. ✅ Monitor and maintain

## Support & Resources

- [N8N Documentation](https://docs.n8n.io/)
- [N8N Community](https://community.n8n.io/)
- [Project README](./README.md)
- [Integration Guide](./chatbot-integration/INTEGRATION_GUIDE.md)
- [Workflow Documentation](./workflows/README.md)

## License

[Your License Here]

## Contact

For questions or issues, please contact the development team.
