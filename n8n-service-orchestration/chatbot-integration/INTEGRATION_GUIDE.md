"""
Installation and Integration Guide for n8n Service Orchestration
"""

# ============================================================================
# STEP 1: INSTALL DEPENDENCIES
# ============================================================================

# Add to requirements.txt:
"""
httpx>=0.24.0  # For async HTTP requests
rapidfuzz>=3.0.0  # For fuzzy matching
python-dotenv>=1.0.0  # For environment variables
"""

# Install:
# pip install -r requirements.txt


# ============================================================================
# STEP 2: COPY FILES TO CHATBOT
# ============================================================================

# Copy these directories to your chatbot project:
# - n8n-service-orchestration/service-registry/ -> chatbot/apps/chat/services/n8n/
# - n8n-service-orchestration/chatbot-integration/ -> chatbot/n8n_integration/
# - n8n-service-orchestration/webhooks/ -> chatbot/n8n_integration/


# ============================================================================
# STEP 3: UPDATE CHATBOT SETTINGS
# ============================================================================

# Add to chatbot/settings.py:
"""
import os
from dotenv import load_dotenv

load_dotenv()

# N8N Configuration
N8N_WEBHOOK_URL = os.getenv('N8N_WEBHOOK_URL', 'http://localhost:5678/webhook')
N8N_API_KEY = os.getenv('N8N_API_KEY', '')
SERVICE_TIMEOUT_MS = int(os.getenv('SERVICE_TIMEOUT_MS', '5000'))
ENABLE_N8N_SERVICES = os.getenv('ENABLE_N8N_SERVICES', 'true').lower() == 'true'
"""


# ============================================================================
# STEP 4: UPDATE VIEWS
# ============================================================================

# Modify chatbot/apps/chat/views.py:
# See views_modified.py for the complete updated views.py


# ============================================================================
# STEP 5: CREATE ENVIRONMENT FILE
# ============================================================================

# Copy .env.example to .env and configure:
# cd chatbot
# cp ../.env.example .env
# Edit .env with your configuration


# ============================================================================
# STEP 6: SETUP N8N
# ============================================================================

# Option A: Docker (Recommended)
# cd n8n-service-orchestration
# docker-compose up -d
# Access at http://localhost:5678

# Option B: Local Installation
# npm install -g n8n
# n8n start


# ============================================================================
# STEP 7: IMPORT WORKFLOWS TO N8N
# ============================================================================

# 1. Open n8n UI (http://localhost:5678)
# 2. Click "+" to create new workflow
# 3. Click "Import from JSON"
# 4. Select workflow files from workflows/example-services/
# 5. Configure webhook endpoints
# 6. Test each workflow


# ============================================================================
# STEP 8: TEST INTEGRATION
# ============================================================================

# Test service detection:
# python test_service_detector.py

# Test chatbot with services:
# curl -X POST http://localhost:8000/api/chat \
#   -H "Content-Type: application/json" \
#   -H "X-API-Key: your-api-key" \
#   -d '{"message": "Can I book an appointment?"}'


# ============================================================================
# TROUBLESHOOTING
# ============================================================================

# Issue: Services not being detected
# Solution: Check service keywords in services.json

# Issue: N8N webhook timeout
# Solution: Increase timeout in .env (SERVICE_TIMEOUT_MS)

# Issue: Parameters not extracted
# Solution: Implement custom extraction in extract_parameter_value()

# Issue: CORS errors
# Solution: Configure CORS in n8n (N8N_WEBHOOK_URL)
