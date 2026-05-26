# API Contract Gate

This document captures the local contract checks added during iterations 101-150. These checks are intentionally lightweight: they run without live infrastructure and protect the highest-risk service boundaries from accidental route/schema drift.

## Scouting AI Service

Contract test: `scouting-ai-service/tests/test_openapi_contract.py`

Required routes:

| Method | Path | Contract Requirement |
|---|---|---|
| `GET` | `/health` | Health endpoint remains exposed. |
| `POST` | `/api/v1/ml/potential/compute` | Response schema remains a JSON `$ref`. |
| `POST` | `/api/v1/ml/evolution/compute` | Response schema remains a JSON `$ref`. |
| `POST` | `/api/v1/ml/churn/compute` | Response schema remains a JSON `$ref`. |
| `POST` | `/api/v1/scouter/players/search/compute` | Response schema remains a JSON `$ref`. |
| `POST` | `/api/v1/scouter/players/compare/compute` | Response schema remains a JSON `$ref`. |
| `POST` | `/api/v1/scouter/shortlists/compute` | Response schema remains a JSON `$ref`. |

## Academy Ranking AI Service

Contract test: `academy-ranking-ai-service/tests/test_openapi_contract.py`

Required routes:

| Method | Path | Contract Requirement |
|---|---|---|
| `GET` | `/health` | Health endpoint remains exposed. |
| `POST` | `/api/v1/rankings/academies/score` | Request schema remains `AcademyRankingRequest`; response schema remains `AcademyRankingResponse`. |

## N8N Registry Contract

Contract test: `n8n-service-orchestration/tests/test_service_registry_contract.py`

Required registry invariants:

- Enabled service IDs are unique.
- Enabled services include all required fields: `id`, `name`, `description`, `category`, `keywords`, `enabled`, `workflow_id`, `webhook_path`, `timeout_ms`, `response_type`, `requires_authentication`, `parameters`, and `responses`.
- Webhook paths start with `/webhook/`.
- Timeouts are bounded between 500 ms and 30,000 ms.
- Response types are constrained to `direct`, `chatbot`, or `hybrid`.
- Core academy/chatbot service IDs remain registered.

## Chatbot Service Detection Contract

Contract test: `chatbot/chatbot/apps/chat/tests/test_service_integration.py`

The chatbot detector now fails tests when service routing returns extra workflows. The detector suppresses overly generic keywords and requires stronger fuzzy matches to avoid routing a single user intent to unrelated N8N services.

## CI Usage

The Python test matrix in `.github/workflows/production-hardening.yml` runs these contract tests automatically because they live inside each service's normal test path. A pull request that removes or renames a protected route must update the tests and this document in the same change.

