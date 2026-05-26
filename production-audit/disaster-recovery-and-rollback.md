# Disaster Recovery And Rollback Runbook

This runbook defines the minimum operational path for restoring service after a failed deployment, data incident, or dependency outage.

## Recovery Targets

Set these values with product and operations leadership before production launch:

| Target | Initial Recommendation |
|---|---|
| Spring backend RTO | 30 minutes |
| FastAPI AI services RTO | 30 minutes |
| Chatbot/N8N RTO | 60 minutes |
| PostgreSQL RPO | 15 minutes or better |
| Redis RPO | Best effort unless used for durable queues |

## Backup Requirements

- PostgreSQL point-in-time recovery enabled.
- Daily full backup plus continuous WAL archiving.
- Backup restore tested monthly in staging.
- Seed/demo files excluded from production artifacts.
- Object/file storage backups enabled if uploads are enabled.
- Configuration and secret versions tracked in the secret manager.

## Restore Procedure

1. Freeze writes if data corruption is suspected.
2. Identify last known-good timestamp.
3. Restore PostgreSQL to an isolated staging environment first.
4. Run data consistency checks for users, players, academies, payments, scouting reports, and rankings.
5. Promote restored database only after validation.
6. Redeploy services with the matching application version and configuration set.
7. Run smoke tests from `production-audit/staging-validation-plan.md`.
8. Re-enable traffic gradually and monitor error rate, latency, and data anomalies.

## Application Rollback

1. Stop rollout or disable auto-merge/deploy automation.
2. Identify the last known-good image/tag/commit for each service.
3. Roll back stateless services first: FastAPI services, N8N support code, chatbot, Spring backend.
4. Roll back mobile/web clients only if the API contract changed or user-impacting regressions are client-side.
5. Do not roll back database migrations blindly. If a migration changed data shape, use the migration rollback plan written for that release.

## Service-Specific Fallbacks

- **Scouting AI down:** Spring should return controlled errors or cached/fallback scores where implemented.
- **Academy Ranking AI down:** Spring weighted fallback ranking should remain available.
- **N8N down:** Chatbot should fall back to AI conversation mode or return a service-unavailable response.
- **Chatbot down:** Core Spring/mobile workflows should remain available.
- **Redis down:** Cache-backed features should degrade; durable workflows must not rely on Redis-only state unless explicitly designed.

## Incident Checklist

- Declare incident severity and owner.
- Capture start time, impacted services, affected users, and suspected trigger.
- Preserve logs and deployment metadata.
- Apply rollback or restore.
- Confirm recovery with synthetic and real-user checks.
- Publish internal incident summary.
- Create follow-up issues for root cause, regression tests, and monitoring gaps.

