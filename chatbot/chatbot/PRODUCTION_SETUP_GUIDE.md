# Complete Production Setup Guide

**Chatbot v2.0 - Production Ready**

## Table of Contents
1. [Quick Start (5 minutes)](#quick-start)
2. [Full Setup (30 minutes)](#full-setup)
3. [Database Migrations](#database-migrations)
4. [Configuration](#configuration)
5. [Running Tests](#running-tests)
6. [Deployment](#deployment)
7. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Quick Start

```bash
# 1. Navigate to project
cd d:\master_pfe\chatbot\chatbot

# 2. Create virtual environment
python -m venv env_py10
.\env_py10\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run migrations
python manage.py migrate

# 5. Create admin user
python manage.py createsuperuser

# 6. Start server
python manage.py runserver 127.0.0.1:8000

# 7. Access
# - Web UI: http://localhost:8000/
# - Admin: http://localhost:8000/admin/
# - Health: http://localhost:8000/health
```

---

## Full Setup

### 1. Environment Setup

```bash
# Create virtual environment
python -m venv env_py10

# Activate (Windows PowerShell)
.\env_py10\Scripts\Activate.ps1

# Activate (Windows CMD)
env_py10\Scripts\activate.bat

# Activate (Linux/Mac)
source env_py10/bin/activate
```

### 2. Install Dependencies

```bash
# Upgrade pip
python -m pip install --upgrade pip

# Install all requirements
pip install -r requirements.txt

# Verify installation
pip list | grep -E "Django|pandas|scikit|pytest"
```

### 3. Create Configuration File

Create `.env` in project root:

```bash
# Django Settings
DJANGO_SECRET_KEY=your-very-secure-random-key-here
DJANGO_DEBUG=0
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,yourdomain.com
DJANGO_SETTINGS_MODULE=chatbot.settings

# Database
DATABASE_URL=sqlite:///db.sqlite3

# API Security
CHATBOT_API_KEY=your-secret-api-key-here

# CSV Data Path
QA_CSV=apps/chat/training_models/data/data.csv

# ML Tuning
MIN_SIM=0.18
FUZZY_MIN=90

# Security & Rate Limiting
RATE_LIMIT_ENABLED=1
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_PERIOD=60
CHATBOT_MAX_MESSAGE_LENGTH=1000

# Monitoring
CHATBOT_ENABLE_METRICS=1

# SSL/TLS (Production)
SECURE_SSL_REDIRECT=0
SESSION_COOKIE_SECURE=0
CSRF_COOKIE_SECURE=0
SECURE_HSTS_SECONDS=0
```

### 4. Database Migrations

```bash
# Show pending migrations
python manage.py showmigrations

# Run all migrations
python manage.py migrate

# Create superuser (admin)
python manage.py createsuperuser

# Verify database
python manage.py dbshell
sqlite> .tables
sqlite> .exit

# Create logs directory
mkdir logs
```

### 5. Load Initial Data (Optional)

```bash
# Create initial predefined responses
python manage.py shell << EOF
from apps.chat.models import PredefinedResponse

responses = [
    ('greeting', "Hello! 👋 How can I help you today?"),
    ('goodbye', "Goodbye! Have a great day! 👋"),
    ('thanks', "You're welcome! 😊"),
    ('help', "I'm here to help. What would you like to know?"),
    ('confused', "I'm not sure I understood. Could you rephrase?"),
]

for intent, text in responses:
    PredefinedResponse.objects.get_or_create(
        intent=intent,
        defaults={'response_text': text, 'enabled': True}
    )

print("Initial responses loaded!")
EOF
```

### 6. Test Setup

```bash
# Run migrations for test database
python manage.py migrate --database=test

# Run tests
pytest

# View coverage
pytest --cov=apps.chat --cov-report=html
open htmlcov/index.html
```

---

## Configuration

### Development Settings

```bash
# .env for development
DJANGO_DEBUG=1
DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost
RATE_LIMIT_ENABLED=0
```

### Production Settings

```bash
# .env for production
DJANGO_DEBUG=0
DJANGO_SECRET_KEY=generate-strong-random-key
DJANGO_ALLOWED_HOSTS=yourdomain.com,api.yourdomain.com
CHATBOT_API_KEY=generate-strong-random-key
SECURE_SSL_REDIRECT=1
SESSION_COOKIE_SECURE=1
CSRF_COOKIE_SECURE=1
SECURE_HSTS_SECONDS=31536000
RATE_LIMIT_ENABLED=1
RATE_LIMIT_REQUESTS=100
```

### ML Tuning

Adjust matching behavior:

```bash
# More strict matching
MIN_SIM=0.25
FUZZY_MIN=95

# More lenient matching
MIN_SIM=0.10
FUZZY_MIN=80
```

---

## Running Tests

### Unit Tests

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest apps/chat/tests_comprehensive.py

# Run specific test class
pytest apps/chat/tests_comprehensive.py::IntentDetectionTestCase

# Run specific test
pytest apps/chat/tests_comprehensive.py::IntentDetectionTestCase::test_greeting_intent
```

### Test Coverage

```bash
# Generate coverage report
pytest --cov=apps.chat --cov-report=html --cov-report=term

# View report
open htmlcov/index.html  # or: start htmlcov/index.html
```

### Integration Tests

```bash
# Run only integration tests
pytest -k "Integration"

# Run chat flow tests
pytest -k "flow"
```

---

## Deployment

### Local Development

```bash
# Start development server
python manage.py runserver 127.0.0.1:8000

# With debug toolbar
pip install django-debug-toolbar
python manage.py runserver
```

### Production with Gunicorn

```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn chatbot.wsgi \
  --workers=4 \
  --worker-class=gthread \
  --threads=2 \
  --bind=0.0.0.0:8000 \
  --access-logfile=logs/access.log \
  --error-logfile=logs/error.log \
  --log-level=info \
  --timeout=30
```

### Docker Deployment

**Dockerfile:**
```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create logs directory
RUN mkdir -p logs

# Run migrations and start server
CMD ["sh", "-c", "python manage.py migrate && gunicorn chatbot.wsgi --workers=4 --bind=0.0.0.0:8000"]
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: chatbot
      POSTGRES_USER: chatbot
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    command: gunicorn chatbot.wsgi --workers=4 --bind=0.0.0.0:8000
    ports:
      - "8000:8000"
    environment:
      DJANGO_DEBUG: 0
      DATABASE_URL: postgresql://chatbot:secure_password@db:5432/chatbot
    depends_on:
      - db
    volumes:
      - ./logs:/app/logs

volumes:
  postgres_data:
```

**Deploy with Docker:**
```bash
docker-compose up -d
docker-compose logs -f web
```

---

## Monitoring & Maintenance

### Health Monitoring

```bash
# Check system health
curl http://localhost:8000/health

# Check metrics (admin required)
curl -H "Cookie: sessionid=..." http://localhost:8000/metrics
```

### Viewing Logs

```bash
# View chatbot log (real-time)
tail -f logs/chatbot.log

# View error log
tail -f logs/errors.log

# View with filtering
grep "ERROR" logs/chatbot.log
grep "api_chat" logs/chatbot.log
```

### Database Maintenance

```bash
# Backup database
python manage.py dumpdata > backup.json

# Restore database
python manage.py loaddata backup.json

# Clean up old chat history
python manage.py shell << EOF
from apps.chat.models import ChatHistory
from datetime import datetime, timedelta

# Delete entries older than 30 days
cutoff = datetime.now() - timedelta(days=30)
deleted, _ = ChatHistory.objects.filter(created_at__lt=cutoff).delete()
print(f"Deleted {deleted} old chat records")
EOF
```

### Admin Panel

Access admin at: `http://localhost:8000/admin/`

**Manage:**
- Predefined Responses
- Chat History
- API Keys
- Users & Permissions

### Performance Optimization

```bash
# Analyze slow queries
python manage.py shell << EOF
from django.db import connection
from django.test.utils import CaptureQueriesContext

with CaptureQueriesContext(connection) as context:
    # Run your code
    pass

for query in context.captured_queries:
    print(f"Time: {query['time']} - {query['sql']}")
EOF
```

### Scaling Considerations

For production:
1. Use PostgreSQL instead of SQLite
2. Enable Redis caching
3. Run multiple Gunicorn workers
4. Use load balancer (nginx, HAProxy)
5. Monitor with tools like Prometheus/Grafana
6. Set up alerts on key metrics

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill process
taskkill /PID <PID> /F

# Or use different port
python manage.py runserver 127.0.0.1:8001
```

### Database Errors

```bash
# Reset database (development only!)
rm db.sqlite3
python manage.py migrate

# Check migrations
python manage.py showmigrations

# Create migration
python manage.py makemigrations
```

### Import Errors

```bash
# Reinstall packages
pip install --upgrade --force-reinstall -r requirements.txt

# Check Python version
python --version  # Should be 3.10+
```

### ML Index Not Loading

```bash
# Check CSV file
ls apps/chat/training_models/data/data.csv

# Verify format
head -2 apps/chat/training_models/data/data.csv
# Should have: Question;Answer;Category;Source

# Check in Python
python manage.py shell << EOF
from apps.chat.services.ml_index import MLIndex
from django.conf import settings

index = MLIndex(settings.QA_CSV)
index.load()
print(f"Loaded {len(index.df)} questions")
EOF
```

---

## Quick Commands Reference

```bash
# Development
python manage.py runserver
python manage.py migrate
python manage.py createsuperuser
python manage.py shell
python manage.py dbshell

# Testing
pytest
pytest --cov
pytest -v -s

# Production
gunicorn chatbot.wsgi
python manage.py collectstatic
python manage.py compress

# Data Management
python manage.py dumpdata > backup.json
python manage.py loaddata backup.json
python manage.py clearsessions

# Utilities
python manage.py check
python manage.py makemigrations
python manage.py showmigrations
```

---

## Support

For issues:
1. Check logs in `logs/` directory
2. Check health: `GET /health`
3. Check metrics: `GET /metrics`
4. Run tests: `pytest -v`
5. Enable debug: `DJANGO_DEBUG=1`

**Happy deploying!** 🚀
