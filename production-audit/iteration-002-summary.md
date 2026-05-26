# Iteration 2 Summary: Critical Security Burn-Down

**Focus Area:** Secrets, service-token auth, packaged seed data, N8N intent correctness, and test reproducibility.

**Fixes applied**
- Removed committed Spring JWT and Stripe fallback secrets; backend now reads `JWT_SECRET` and `STRIPE_SECRET_KEY` from the runtime environment.
- Added JWT fail-fast validation so the backend refuses to start with a missing or undersized signing secret.
- Made Scouting AI and Academy Ranking AI service-token checks fail closed outside `dev`, `local`, and `test`.
- Switched service-token validation to constant-time comparison.
- Excluded `Files/Data/data.json` from the backend runtime artifact; clean Maven build confirms it is not copied into `target/classes`.
- Fixed N8N false-positive intent detection where `Tell me a joke` matched `submit-feedback`.
- Replaced the stale Flutter counter test with a real unauthenticated app-shell smoke test.
- Added generated artifact ignores and a Bandit Python SAST report with zero findings.

**Test status**
- `sports_management_project`: `mvn -q clean test -DskipITs` passed.
- `scouting-ai-service`: `python -m pytest tests -v` passed, 9/9.
- `academy-ranking-ai-service`: `python -m pytest tests -v` passed, 6/6.
- `n8n-service-orchestration`: `python -m pytest tests -v` passed, 23/23 with 2 existing `datetime.utcnow()` deprecation warnings.
- `sports-app`: `flutter test` passed, 1/1.
- Python Bandit SAST: zero findings in scanned FastAPI/N8N service code.

**Remaining high-risk items**
- Spring CSRF is still globally disabled and needs split API/web security handling.
- CI/CD is still missing as an enforced quality gate.
- Dependency CVE scanning and Flutter analyzer burn-down remain open.
- Observability is still incomplete: no standardized correlation IDs, metrics, tracing, dashboards, or alerts across all services.
- Database/query-plan profiling needs a live PostgreSQL fixture.

**Operational note**
- Production/staging must provide `JWT_SECRET`, `SCOUTING_SERVICE_TOKEN`, `ACADEMY_RANKING_AI_SERVICE_TOKEN`, and `STRIPE_SECRET_KEY` before rollout.
