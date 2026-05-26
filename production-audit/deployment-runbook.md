# Deployment Runbook

## Required Environment

- `JWT_SECRET`: at least 256 bits of key material, base64 or hex accepted by `JwtService`.
- `JWT_SECRET_KEY`: Scouting AI application JWT secret; required outside `dev`, `local`, and `test`.
- `ADMIN_JWT_SECRET`: Scouting admin-platform JWT secret; required outside `dev`, `local`, and `test`.
- `STRIPE_SECRET_KEY`: Stripe secret key; required before payment endpoints are used.
- `SCOUTING_SERVICE_TOKEN`: shared service token used by Spring when calling Scouting AI.
- `ACADEMY_RANKING_AI_SERVICE_TOKEN`: shared service token used by Spring when calling Academy Ranking AI.
- `APP_ENV`: set to `prod` or `staging` for non-local FastAPI deployments.
- `HF_BASE_MODEL_REVISION`: pinned Hugging Face model revision for chatbot training/inference jobs.
- `HF_DATASET_REVISION`: pinned Hugging Face dataset revision for chatbot training jobs.

## Pre-Deploy Verification

1. Run backend tests: `mvn -q clean test -DskipITs`.
2. Run Scouting AI tests: `python -m pytest tests -v`.
3. Run Academy Ranking AI tests: `python -m pytest tests -v`.
4. Run N8N support tests: `python -m pytest tests -v`.
5. Run Flutter smoke tests: `flutter test`.
6. Run Python SAST: `python -m bandit -r scouting-ai-service/app scouting-ai-service/adminplatform academy-ranking-ai-service/app n8n-service-orchestration/service-registry n8n-service-orchestration/webhooks chatbot/chatbot/apps -x chatbot/chatbot/apps/chat/tests_comprehensive.py`.
7. Run direct Python dependency audits with `pip-audit --no-deps -r <requirements.txt>` for each Python service.
8. Confirm backend artifact excludes the demo seed: `Test-Path sports_management_project/target/classes/Files/Data/data.json` should return `False`.
9. Review API contract status in `production-audit/api-contracts.md`.
10. Review observability rules in `production-audit/prometheus-alert-rules.yml`.
11. Optional local shortcut: run `production-audit/run-local-hardening-checks.ps1` from the repository root.

## Rollout

1. Deploy FastAPI services with `APP_ENV=staging`, valid service tokens, and service-specific JWT secrets.
2. Deploy Spring backend with matching service tokens and `JWT_SECRET`.
3. Smoke-test backend auth, scouting compute, academy rankings, and payment config.
4. Deploy mobile/web clients after backend smoke tests pass.
5. Monitor 401/503 rates from AI services for token misconfiguration.
6. Verify `/actuator/health`, `/actuator/prometheus`, Scouting AI `/metrics`, and Academy Ranking AI `/metrics` are scraped.

## Rollback

- If backend fails to start with `JWT_SECRET must be configured`, restore the previous deployment and set a valid `JWT_SECRET` before retrying.
- If FastAPI compute calls return 503, verify service-token env vars are present in the service runtime.
- If AI calls return 401, verify Spring-side token values match the FastAPI service token values.
- If Scouting AI or admin auth fails after deployment, verify `JWT_SECRET_KEY`, `ADMIN_JWT_SECRET`, and `APP_ENV` are present in the service runtime.
- Do not re-enable committed fallback secrets; fix runtime configuration instead.
