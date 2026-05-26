# Production Readiness Checklist

Status key: `done`, `partial`, `open`, `blocked`.

| Area | Status | Evidence | Next Action |
|---|---|---|---|
| Backend tests | done | `mvn -q clean test -DskipITs` passed | Keep as required CI gate |
| Scouting AI tests | done | 11/11 pytest passing | Add coverage report |
| Academy Ranking AI tests | done | 6/6 pytest passing | Add coverage report |
| N8N support tests | done | 24/24 pytest passing | Add webhook-level integration tests |
| Flutter smoke test | done | `flutter test` passed | Expand route/auth tests |
| Python SAST | done | `bandit-python-services.json` has zero findings for scanned app/service directories | Keep Bandit in CI and review nosec exceptions |
| Hardcoded Spring JWT/Stripe secrets | done | Env-backed config in `application.properties` | Rotate any exposed values |
| FastAPI service auth fail-open | done | Missing token fails closed outside dev/local/test | Set env tokens in staging/prod |
| Packaged demo seed data | done | `target/classes/Files/Data/data.json` absent after clean build | Move seed to external demo fixture |
| Generated artifacts in gitignore | done | `.gitignore` ignores pycache, pyc, pytest cache, audit deps | Remove tracked bytecode in a dedicated cleanup PR |
| CI/CD | partial | `.github/workflows/production-hardening.yml` added | Run on GitHub hosted runners and tune any environment-only failures |
| Dependabot | done | `.github/dependabot.yml` covers Actions, Maven, pip, and pub ecosystems | Triage update PRs weekly |
| Python dependency scanning | done for direct requirements | `pip-audit-*.json` reports 0 known direct requirement vulnerabilities after updates | Add lockfile/SBOM and transitive release artifact scans |
| JWT library hardening | done | Scouting AI moved from `python-jose` to `PyJWT`; regression tests pass | Add issuer/audience standard across services |
| N8N timeout handling | done | Timeout-specific regression test passes | Add delayed-service integration test |
| Timezone-aware Python timestamps | done | Touched services use `datetime.now(timezone.utc)` | Add shared timestamp/logging helper |
| FastAPI contract tests | done | Scouting AI and Academy Ranking AI OpenAPI route/schema tests pass | Export OpenAPI artifacts in CI |
| N8N registry contract tests | done | Enabled service IDs, fields, timeouts, webhook paths, response types, and core services are tested | Add workflow artifact validation when real n8n workflows are finalized |
| Chatbot workflow routing | done | Service-detection test now asserts exact expected services; false positives fixed | Build a shared matcher corpus for chatbot and N8N |
| Staging validation plan | done | `production-audit/staging-validation-plan.md` added | Execute against staging |
| Disaster recovery and rollback plan | done | `production-audit/disaster-recovery-and-rollback.md` added | Rehearse restore and rollback in staging |
| Spring CSRF strategy | done | API/admin/default filter chains split; admin/MVC CSRF enabled; `/api/**` no longer authenticates from JWT cookies | Validate admin forms in staging browser smoke test |
| Java/Flutter dependency scanning | partial | SBOM workflow steps and Flutter dependency freshness report added | Add a production CVE provider such as OWASP Dependency-Check/Snyk with org-approved thresholds |
| API contracts | partial | Critical FastAPI/N8N contracts now tested; Spring/mobile generated compatibility still missing | Generate Spring OpenAPI specs and validate mobile clients in CI |
| Observability | partial | Spring Actuator/Prometheus enabled; FastAPI metrics endpoints added; outbound correlation headers propagated; alert rules added | Deploy Prometheus/Grafana/OpenTelemetry in staging and verify traces/dashboards |
| Rate limiting | partial | Chatbot has documented rate limiting only | Add backend/FastAPI quotas |
| Database indexing/profiling | blocked | `db-index-audit.sql` added, but no live PostgreSQL fixture available locally | Run EXPLAIN plans against staging-like data |
| Resilience/circuit breakers | partial | Timeouts exist in some clients | Centralize retries, backoff, circuit breakers |
| Flutter accessibility | partial | Accessibility audit checklist added; Flutter smoke test passes | Run device/browser WCAG audit and fix blockers |
| Load testing | partial | k6 smoke-load script added | Run against staging and capture p95/p99/error-rate baselines |
| Chaos testing | partial | Dry-run chaos drill script added | Execute in staging and document recovery evidence |
| Prometheus alerting | partial | Alert rules added for backend and AI services | Import into monitoring stack and verify alert routing |
| Runbooks | partial | Deployment, troubleshooting, on-call, staging, contract, and rollback docs added | Validate against staging deploy and incident drill |

## Go/No-Go

Current recommendation: **staging-ready, no-go for production certification** until the GitHub Actions workflow passes on hosted runners, monitoring is deployed and verified, staging DB profiling is complete, load/chaos/accessibility evidence is captured, and release SBOM/CVE reports are archived. The remaining work now depends on staging infrastructure rather than missing local implementation.
