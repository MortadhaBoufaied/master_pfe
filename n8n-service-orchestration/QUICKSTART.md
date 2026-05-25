# Quick Start Guide - 5 Minutes to Working Service Orchestration

## Prerequisites

- Python 3.9+
- Docker & Docker Compose
- 5 minutes of time

## Step 1: Install Dependencies (1 min)

```bash
cd d:\master_pfe\n8n-service-orchestration
pip install -r requirements.txt
```

## Step 2: Start N8N (1 min)

```bash
# Copy environment file
cp .env.example .env

# Start services with Docker
docker-compose up -d

# Wait for services to be ready (about 30 seconds)
# Access n8n at http://localhost:5678
```

## Step 3: Test Service Detection (1 min)

```bash
# Run quick test
python tests/quick_test.py

# Output shows:
# ✅ Available services detected
# ✅ Response formatting working
# ✅ Example messages matched to services
```

## Step 4: Import First Workflow to N8N (2 min)

1. Open n8n at `http://localhost:5678`
2. Click "New" → "Import from JSON"
3. Select `workflows/example-services/get-user-profile.json`
4. Click "Import"
5. In the workflow, update the HTTP node URL to point to your backend
6. Click "Activate" to enable the workflow

## Step 5: Integrate with Chatbot (Optional)

1. Copy `chatbot-integration/views_modified.py` to `chatbot/apps/chat/views.py`
2. Copy service-registry folder to chatbot
3. Install dependencies: `pip install httpx`
4. Restart chatbot

## 🎉 Done!

You now have:
- ✅ Service detection system running
- ✅ N8N ready for workflows
- ✅ Response formatting templates
- ✅ Chatbot integration ready

## Next Steps

1. Import all workflows from `workflows/example-services/`
2. Configure backend API endpoints
3. Customize service keywords and responses
4. Test with real user messages
5. Deploy to production

## Quick Troubleshooting

**N8N not starting?**
```bash
docker-compose logs n8n
```

**Service detection not working?**
```bash
# Edit services.json to add/modify keywords
# Re-run quick_test.py
```

**Backend connection error?**
```bash
# Check backend URL in workflows
# Verify backend is running
# Check firewall/networking
```

## Get Help

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed documentation
