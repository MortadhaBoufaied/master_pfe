# Master Findings Report

| ID | Severity | Area | Finding | Evidence | Recommended Fix |
|---|---|---|---|---|---|
| FIND-001 | Critical | Security | Hardcoded Spring JWT/Stripe secrets | `sports_management_project/src/main/resources/application.properties:52`, `sports_management_project/src/main/resources/application.properties:58` | Move to mandatory env vars and rotate exposed values. |
| FIND-002 | Critical | Security | FastAPI service-token auth fails open when token env var is empty | `scouting-ai-service/app/core/service_auth.py:9`, `academy-ranking-ai-service/app/core/auth.py:7` | Fail closed in prod; allow bypass only in explicit dev mode. |
| FIND-003 | Critical | Data/Security | Packaged seed data contains known `admin` passwords and PII-like records | `sports_management_project/src/main/resources/Files/Data/data.json:1` | Exclude from production artifact; move seeds to non-runtime demo folder. |
| FIND-004 | Critical | Web Security | CSRF disabled while web admin flow uses cookies | `sports_management_project/src/main/java/com/footballacademy/config/jwt/SecurityConfig.java:41` | Split API/web security chains or enable CSRF for cookie-auth routes. |
| FIND-005 | High | Testing | Python tests cannot run because pytest is missing | `python -m pytest tests -v` | Add test bootstrap scripts/CI venv setup. |
| FIND-006 | High | Mobile Testing | Flutter test is stale and failing | `sports-app/test/widget_test.dart:13` | Replace counter-template test with real auth/navigation smoke test. |
| FIND-007 | High | Quality Gates | Static analysis not usable as production gate | Checkstyle 23,034 findings; Flutter analyzer 808 findings | Establish incremental lint baselines and enforce only actionable gates first. |
| FIND-008 | High | Resilience | HTTP clients lack shared retry/circuit breaker/correlation policy | `ScoutingAiService`, `AcademyRankingAgentClient`, `WebhookService`, `service_executor.py` | Add shared clients with timeouts, bounded retries, circuit breakers and correlation IDs. |
| FIND-009 | High | Observability | No complete metrics/tracing/logging standard | No Spring actuator dependency; no Prometheus/OpenTelemetry config found | Add structured JSON logs, metrics endpoints and trace propagation. |
| FIND-010 | High | Contracts | API contracts are not enforced between services | 499 Spring mappings; FastAPI routes not contract-tested | Generate specs in CI and add service-boundary contract tests. |

## Immediate Risk Burn-Down Plan
1. Fix hardcoded secrets and production seed packaging.
2. Make AI service auth fail closed in production.
3. Restore reliable test execution for Flutter and Python services.
4. Add a minimal CI workflow: compile, unit tests, Flutter analyze/test, Python compile/test.
5. Add correlation IDs and standard service-client timeouts before deeper performance work.

## Iteration 2 Status Update

| ID | Status | Resolution / Current State |
|---|---|---|
| FIND-001 | Fixed | Spring `jwt.secret` and `stripe.secret.key` now resolve from `JWT_SECRET` and `STRIPE_SECRET_KEY`; `JwtService` fails fast when `JWT_SECRET` is missing or undersized. Rotate any value previously exposed in repository history. |
| FIND-002 | Fixed | Scouting AI and Academy Ranking AI now allow missing service tokens only in `dev`, `local`, and `test`; production-like environments return HTTP 503 if the token is missing and HTTP 401 if it is wrong. |
| FIND-003 | Fixed for artifact packaging | `Files/Data/data.json` remains in the workspace as a demo seed, but Maven now excludes it from backend runtime resources. Clean build verified `target/classes/Files/Data/data.json` is absent. |
| FIND-004 | Open | CSRF remains globally disabled; split API and admin web security chains are still required. |
| FIND-005 | Fixed for current local run | Local audit dependencies enabled Python pytest execution; Scouting AI, Academy Ranking AI, and N8N support tests now pass. CI still needs a permanent test bootstrap. |
| FIND-006 | Fixed | Flutter counter-template smoke test replaced; `flutter test` passes. |
| FIND-007 | Partial | `.gitignore` now excludes generated test/runtime artifacts and Bandit reports zero Python findings; broader checkstyle/Flutter analyzer burn-down remains open. |
| FIND-008 | Open | Retry/circuit breaker/correlation policy still needs shared client work. |
| FIND-009 | Open | Metrics, tracing, structured logging, and dashboards still need implementation. |
| FIND-010 | Open | Contract tests and generated API compatibility checks still need CI integration. |
| FIND-011 | Fixed | N8N false-positive service detection fixed by boundary-aware exact keyword matching and short-keyword fuzzy suppression. |
| FIND-012 | Fixed | Mobile smoke test now validates the real unauthenticated app shell. |

## Iterations 3-100 Bundled Status Update

| ID | Severity | Area | Status | Resolution / Current State |
|---|---|---|---|---|
| FIND-013 | High | CI/CD | Fixed locally | Added `.github/workflows/production-hardening.yml` with Spring, Python, Flutter, Bandit, pip-audit, and Maven dependency gates. Needs first GitHub Actions run to validate hosted-runner parity. |
| FIND-014 | High | Dependencies | Fixed for audited direct Python requirements | Updated vulnerable direct Python requirements and regenerated `pip-audit-*.json`; current direct audits report 0 known vulnerabilities. Full lockfile/SBOM and transitive release scans remain open. |
| FIND-015 | High | Security | Fixed | Scouting AI JWT helpers now use PyJWT with timezone-aware claims and local/test-only fallback secrets. |
| FIND-016 | Medium | N8N Resilience | Fixed | `service_executor.py` now classifies `httpx.TimeoutException` as a timeout, with regression coverage. |
| FIND-017 | Medium | Correctness | Fixed | Touched Python services now use timezone-aware UTC timestamps instead of deprecated naive UTC calls. |
| FIND-018 | High | Python SAST | Fixed for scanned directories | Bandit report now has 0 findings for scanned Python service/app directories after SHA-256, HTTPS validation, revision controls, and logging fixes. |
| FIND-019 | Medium | Release Reproducibility | Fixed locally | Added `production-audit/run-local-hardening-checks.ps1` to rerun the local hardening gate set. |

## Current Top Remaining Risks

1. **Spring CSRF/security split:** CSRF remains globally disabled and still needs separate stateless API and cookie/web-admin chains.
2. **Observability:** Metrics, tracing, structured logs, dashboards, and alert rules are still not production complete.
3. **Database validation:** Indexing and slow-query findings cannot be closed without a staging-like PostgreSQL dataset and representative traffic.
4. **Contracts:** API specs exist in pieces, but compatibility is not yet enforced across Spring, FastAPI, N8N, chatbot, and mobile clients.
5. **Resilience:** Service clients still need standardized correlation IDs, retries, circuit breakers, and bulkheads across all outbound calls.
6. **Load and chaos testing:** No production-like load, spike, soak, or failure-injection pass has been executed yet.
7. **Accessibility and Flutter analyzer debt:** The mobile smoke test passes, but full WCAG/accessibility review and analyzer burn-down remain open.
8. **Release security:** Python direct audits are clean, but Java/Flutter transitive CVE scans, SBOM generation, and exception workflow remain open.

## Iterations 101-150 Bundled Status Update

| ID | Severity | Area | Status | Resolution / Current State |
|---|---|---|---|---|
| FIND-020 | High | Contract Testing | Fixed locally | Added Scouting AI OpenAPI contract tests, Academy Ranking OpenAPI contract tests, and N8N service-registry contract tests. |
| FIND-021 | High | Chatbot/N8N Routing | Fixed | Chatbot service detection now asserts expected services and no longer silently passes false positives; matcher scoring was tightened in chatbot and N8N. |
| FIND-022 | Medium | Operational Handoff | Fixed as documentation | Added staging validation, disaster recovery/rollback, API contract, and final readiness documents. |

## Final Local Readiness Position

The locally feasible hardening scope is complete through iteration 150. The project is **ready for staging validation**, but remains **no-go for production certification** until CSRF hardening, observability, staging DB profiling, production-like performance/chaos testing, release SBOMs, accessibility audit, and rollback rehearsal are complete.
