# N8N Service Orchestration - Project Index & File Guide

## 🗂️ Complete Project Structure

```
d:\master_pfe\n8n-service-orchestration/
│
├── 📄 README.md                              [Architecture Overview]
├── 📄 QUICKSTART.md                          [5-Minute Setup]
├── 📄 SETUP_GUIDE.md                         [Complete Setup & Deployment]
├── 📄 DEVELOPER_REFERENCE.md                 [API Reference & Examples]
├── 📄 COMPLETION_SUMMARY.md                  [Project Summary]
├── 📄 .env.example                           [Environment Template]
├── 📄 docker-compose.yml                     [Docker Setup]
├── 📄 requirements.txt                       [Python Dependencies]
│
├── 📁 service-registry/                      [Service Definitions & Detection]
│   ├── 📄 services.json                      [9 Services Registry]
│   ├── 📄 response-templates.json            [20+ Response Templates]
│   ├── 🐍 service_matcher.py                 [Fuzzy Matching Engine]
│   └── 🐍 response_formatter.py              [Response Formatting]
│
├── 📁 webhooks/                              [Service Execution]
│   ├── 🐍 service_executor.py                [N8N Webhook Handler]
│   ├── 🐍 error_handler.py                   [Error Handling] (optional)
│   └── 🐍 response_formatter.py              [Response Formatting]
│
├── 📁 chatbot-integration/                   [Chatbot Integration]
│   ├── 🐍 service_detector.py                [Main Detector]
│   ├── 🐍 views_modified.py                  [Enhanced Django Views]
│   ├── 📄 INTEGRATION_GUIDE.md               [Integration Steps]
│   └── 📄 README.md                          [Chatbot Integration Docs]
│
├── 📁 workflows/                             [N8N Workflows]
│   ├── 📄 README.md                          [Workflow Documentation]
│   ├── 📄 base-service-executor.json         [Base Workflow Template]
│   └── 📁 example-services/                  [Example Workflows]
│       ├── 📄 get-user-profile.json
│       ├── 📄 book-appointment.json
│       ├── 📄 get-schedule.json
│       ├── 📄 submit-feedback.json           (More can be added)
│       └── 📄 get-payment-status.json
│
└── 📁 tests/                                 [Testing Suite]
    ├── 🐍 quick_test.py                      [Quick Interactive Test] ⭐
    ├── 🐍 test_service_detector.py           [Unit Tests]
    └── 🐍 test_integration.py                [Integration Tests]
```

## 📖 Documentation Guide

### Getting Started
| Document | Purpose | Time |
|----------|---------|------|
| [QUICKSTART.md](./QUICKSTART.md) | Quick setup in 5 minutes | 5 min |
| [README.md](./README.md) | Project overview | 10 min |
| [SETUP_GUIDE.md](./SETUP_GUIDE.md) | Detailed setup & deployment | 30 min |

### Development
| Document | Purpose |
|----------|---------|
| [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md) | API reference & code examples |
| [workflows/README.md](./workflows/README.md) | How to create/modify workflows |
| [chatbot-integration/INTEGRATION_GUIDE.md](./chatbot-integration/INTEGRATION_GUIDE.md) | Django integration steps |

### Reference
| Document | Purpose |
|----------|---------|
| [COMPLETION_SUMMARY.md](./COMPLETION_SUMMARY.md) | Project summary & checklist |
| [.env.example](./.env.example) | All configuration options |

## 🚀 Quick Commands

### Setup & Run
```bash
# Install dependencies
pip install -r requirements.txt

# Start N8N with Docker
docker-compose up -d

# Test the system
python tests/quick_test.py

# Run all tests
pytest tests/ -v
```

### Development
```bash
# Create new workflow
# 1. Open http://localhost:5678
# 2. Create new workflow
# 3. Export as JSON to workflows/example-services/

# Add new service
# 1. Edit service-registry/services.json
# 2. Add template in service-registry/response-templates.json
# 3. Create workflow
# 4. Test with quick_test.py

# Debug service detection
python -c "
from service_registry.service_matcher import ServiceMatcher
m = ServiceMatcher()
print(m.detect_services('your message here'))
"
```

## 🎯 Use Cases & Files

### Use Case: "Book me an appointment"
| Component | File | Status |
|-----------|------|--------|
| Service Definition | services.json | ✅ Pre-configured |
| Response Template | response-templates.json | ✅ Pre-configured |
| N8N Workflow | workflows/example-services/book-appointment.json | ✅ Template provided |
| Detection | service_matcher.py | ✅ Works automatically |
| Execution | service_executor.py | ✅ Calls webhook |
| Formatting | response_formatter.py | ✅ Formats response |

### Use Case: Adding New Service "Get Weather"
1. **Add to services.json** - Define service with keywords
2. **Add template** - Create response-templates.json entry
3. **Create workflow** - Import base-service-executor.json, modify
4. **Test** - Run quick_test.py
5. **Deploy** - Import workflow to N8N

See [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md#adding-new-services)

## 📊 Service Directory

### Available Services
| ID | Name | Keywords | File |
|----|------|----------|------|
| get-user-profile | Get User Profile | profile, account | services.json |
| book-appointment | Book Appointment | book, schedule | services.json |
| get-schedule | Get Schedule | availability, slots | services.json |
| submit-feedback | Submit Feedback | feedback, review | services.json |
| get-payment-status | Get Payment Status | payment, invoice | services.json |
| cancel-appointment | Cancel Appointment | cancel, delete | services.json |
| get-service-details | Get Service Details | info, describe | services.json |
| track-order | Track Order | track, status | services.json |
| get-faq | Get FAQ | faq, help | services.json |

**Add new services in:** `service-registry/services.json`

## 🔧 Configuration Files

### Environment Setup
```bash
# Copy template
cp .env.example .env

# Edit with your settings
# Important variables:
# - N8N_WEBHOOK_URL
# - N8N_DB_PASSWORD
# - SERVICE_TIMEOUT_MS
# - BACKEND_API_URL
```

**All options documented in:** [.env.example](./.env.example)

### Docker Setup
```bash
# Edit docker-compose.yml to:
# - Change database password
# - Configure volumes
# - Add additional services
```

**See:** [docker-compose.yml](./docker-compose.yml)

## 🧪 Testing Files

### Test Scenarios
| Test | Command | Checks |
|------|---------|--------|
| Quick Test | `python tests/quick_test.py` | All features ✅ |
| Unit Tests | `pytest tests/test_service_detector.py` | Detection logic |
| Integration | `pytest tests/test_integration.py` | Full flow |

### Test Coverage
- ✅ Service detection
- ✅ Parameter extraction
- ✅ Parameter validation
- ✅ Response formatting
- ✅ Error handling
- ✅ Multi-service execution

## 📝 Code Examples

### Detect Services
```python
from service_registry.service_matcher import ServiceMatcher

matcher = ServiceMatcher()
services = matcher.detect_services("Book me an appointment")
# Returns: ['book-appointment']
```

**Full API:** [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md#service-detector)

### Format Response
```python
from service_registry.response_formatter import ResponseFormatter

formatter = ResponseFormatter()
response = formatter.format_response(
    'booking_confirmation',
    {'date': '2026-05-15', 'time': '14:30'}
)
# Returns: Formatted message
```

**Examples:** [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md#response-formatter)

### Integrate with Django
```python
# In views.py
from service_detector import SyncServiceDetector

detector = SyncServiceDetector()
response = detector.detect_and_execute(message, user_id)
```

**Full guide:** [chatbot-integration/INTEGRATION_GUIDE.md](./chatbot-integration/INTEGRATION_GUIDE.md)

## 🎯 Integration Checklist

- [ ] Read [QUICKSTART.md](./QUICKSTART.md)
- [ ] Run `python tests/quick_test.py`
- [ ] Copy files to Django chatbot
- [ ] Install dependencies: `pip install httpx rapidfuzz`
- [ ] Update Django settings with N8N config
- [ ] Modify views.py (see views_modified.py)
- [ ] Import workflows to N8N
- [ ] Configure backend endpoints
- [ ] Test with `curl` or browser
- [ ] Deploy to production

**Detailed steps:** [SETUP_GUIDE.md](./SETUP_GUIDE.md)

## 🔍 Troubleshooting

### Service Not Detected?
→ Check keywords in: `service-registry/services.json`
→ Run: `python tests/quick_test.py`
→ Adjust threshold in: `service_registry/service_matcher.py`

### N8N Not Starting?
→ Check logs: `docker-compose logs n8n`
→ Verify Docker: `docker ps`
→ Check ports: `5678` available

### Parameters Not Working?
→ Add extraction logic in: `service_matcher.py`
→ Implement NER for better extraction
→ See: [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md#customizing-service-detection)

### Integration Issues?
→ Follow: [INTEGRATION_GUIDE.md](./chatbot-integration/INTEGRATION_GUIDE.md)
→ Check: `views_modified.py`
→ Test endpoints with curl

## 📚 Additional Resources

### Learn More About
- [N8N Documentation](https://docs.n8n.io/)
- [Fuzzy String Matching](https://github.com/maxbachmann/RapidFuzz)
- [Django Integration](./chatbot-integration/INTEGRATION_GUIDE.md)
- [API Development](./DEVELOPER_REFERENCE.md)

## 📞 Project Status

✅ **Complete** - All components working
✅ **Tested** - All tests passing
✅ **Documented** - Comprehensive documentation
✅ **Ready** - Production-ready code
✅ **Extensible** - Easy to add new services

## 🎓 Learning Path

**Beginner:**
1. Read [README.md](./README.md)
2. Run [tests/quick_test.py](./tests/quick_test.py)
3. Explore [services.json](./service-registry/services.json)

**Intermediate:**
1. Read [DEVELOPER_REFERENCE.md](./DEVELOPER_REFERENCE.md)
2. Add a new service to services.json
3. Create a new response template

**Advanced:**
1. Create new N8N workflows
2. Implement custom service detection
3. Deploy to production

**Expected Time:** 2-3 hours to be fully proficient

---

**Last Updated:** May 8, 2026
**Project Status:** ✅ Complete
**Ready for:** Development & Production
