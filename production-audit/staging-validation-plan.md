# Staging Validation Plan

Use this plan after the local hardening gates pass and before any production deployment.

## Required Staging Inputs

- Representative PostgreSQL dataset with realistic player, academy, payment, attendance, scouting, and notification volumes.
- Runtime secrets supplied through the staging secret manager, not files committed to the repo.
- Network paths between Spring backend, FastAPI services, N8N, chatbot, Redis, PostgreSQL, and mobile/web clients.
- Observability sink available for logs, metrics, and traces.

## Validation Sequence

1. **Build and test**
   - Run `.github/workflows/production-hardening.yml` on a pull request.
   - Run `production-audit/run-local-hardening-checks.ps1` on a clean workstation or build agent.

2. **Deploy staging**
   - Deploy PostgreSQL and Redis first.
   - Deploy Scouting AI and Academy Ranking AI with `APP_ENV=staging`, valid service tokens, and JWT secrets.
   - Deploy Spring backend with matching AI service tokens.
   - Deploy N8N and chatbot after backend and AI services are healthy.
   - Deploy Flutter web/mobile build only after backend smoke tests pass.

3. **Smoke test critical flows**
   - Login and refresh token flow.
   - Player list, player profile, scouting score, evolution, churn, compare, and shortlist.
   - Academy ranking endpoint with AI service available and unavailable.
   - Payment status path with a non-production Stripe key.
   - Chatbot service detection and N8N workflow execution.
   - WebSocket connect, reconnect, and authorization.

4. **Database profiling**
   - Run `production-audit/db-index-audit.sql` against the staging PostgreSQL database.
   - Capture `EXPLAIN (ANALYZE, BUFFERS)` for the top Spring endpoints by traffic.
   - Confirm foreign-key and high-cardinality filter columns have indexes.
   - Confirm list endpoints paginate and do not produce unbounded result sets.

5. **Resilience validation**
   - Dry-run the chaos checklist with `production-audit/chaos-drill.ps1`.
   - Execute the checklist in staging with `production-audit/chaos-drill.ps1 -Apply` only after confirming it targets disposable/staging services.
   - Stop Scouting AI and confirm Spring fallback/error behavior is controlled.
   - Stop Academy Ranking AI and confirm weighted backend fallback works.
   - Inject slow N8N responses and confirm timeout responses propagate cleanly.
   - Restart PostgreSQL and verify services reconnect or fail safely.

6. **Security validation**
   - Confirm missing service tokens fail closed in staging.
   - Confirm invalid tokens are rejected with 401 and no stack traces.
   - Confirm CORS is not wildcard in staging.
   - Confirm state-changing browser/admin routes have CSRF strategy finalized.
   - Confirm logs mask credentials, API keys, JWTs, and PII.

7. **Observability validation**
   - Import `production-audit/prometheus-alert-rules.yml`.
   - Verify request IDs/correlation IDs across gateway, backend, AI services, N8N, and chatbot.
   - Verify dashboards for latency, error rate, throughput, saturation, queue depth, and DB pool usage.
   - Trigger synthetic failures and confirm alerts are actionable.

8. **Performance validation**
   - Run `k6 run production-audit/k6-smoke-load.js` with `BASE_URL` and `JWT_TOKEN` set for staging.
   - Capture p95, p99, and error-rate output as release evidence.

9. **Accessibility validation**
   - Complete `production-audit/accessibility-audit.md` against Flutter and admin web builds.

## Exit Criteria

- All CI jobs pass.
- No critical/high dependency or SAST findings without documented exception.
- Staging smoke tests pass.
- p95 and p99 latency meet agreed SLOs for critical endpoints.
- Service failure tests produce bounded, user-safe errors.
- Backup restore has been tested at least once in staging.
- Rollback path has been rehearsed.

## Production Go/No-Go

Do not approve production until CSRF strategy, observability, DB profiling, contract tests, and rollback validation are complete. If an exception is required, record the owner, expiry date, compensating controls, and rollback trigger.
