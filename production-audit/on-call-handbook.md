# On-Call Handbook

## Critical Alerts To Add

- Backend startup failure caused by missing `JWT_SECRET`.
- AI service 503 rate above 1% for 5 minutes.
- AI service 401 rate above 1% for 5 minutes.
- Backend-to-AI latency p95 above 2 seconds for 10 minutes.
- Backend 5xx rate above 1% for 5 minutes.
- PostgreSQL connection pool saturation above 85% for 10 minutes.
- Payment endpoint failures above 1% for 5 minutes.

## First Response Checklist

1. Identify affected service and recent deployment/config change.
2. Check token/JWT env vars before restarting services.
3. Check backend logs for AI client 401/503 responses.
4. Verify the AI service `/health` endpoints.
5. If auth/config is confirmed broken, roll back to last known-good config and redeploy.

## Escalation

- Security incident: leaked token, leaked JWT secret, unexpected valid auth bypass.
- Data incident: seed/demo data imported into production database.
- Availability incident: backend or AI compute unavailable for more than 15 minutes.
- Payment incident: Stripe failures or inconsistent payment transaction state.

## Post-Incident Actions

- Rotate any exposed secret or service token.
- Add or tighten a regression test for the failure mode.
- Update this handbook with the exact symptom and resolution.
- Add an alert if detection required manual discovery.
