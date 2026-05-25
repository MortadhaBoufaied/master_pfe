# Academy Ranking AI Service

Stateless FastAPI service for ranking academies from feature rows assembled by
the Spring backend. It does not own a database.

## Responsibility

- Spring backend owns academy data, RBAC, persistence, and feature assembly.
- This service receives backend-provided academy metrics and returns ranked
  scores, tiers, confidence, and explanations.
- Ranking now rewards context-adjusted development, weak-academy improvement signals, availability, injury management, attendance reliability, benchmark coverage, and data confidence when the backend provides them.
- The Flutter app should call the backend endpoint:
  `GET /api/academy-rankings/top`.

## Environment

- `ACADEMY_RANKING_AI_SERVICE_TOKEN`: optional shared token expected in
  `X-Service-Token`.
- `ACADEMY_RANKING_MODEL_VERSION`: optional model version label.

Backend config:

- `ACADEMY_RANKING_AI_BASE_URL=http://localhost:8020`
- `ACADEMY_RANKING_AI_SERVICE_TOKEN=<same token>`
- `ACADEMY_RANKING_AI_TIMEOUT_MS=8000`

## Run Locally

```bash
python -m venv .venv
. .venv/Scripts/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8020 --reload
```

Example request:

```bash
curl -X POST http://localhost:8020/api/v1/rankings/academies/score \
  -H "Content-Type: application/json" \
  -d '{"limit":3,"items":[{"academyId":1,"academyName":"Academy A","playerDevelopmentScore":80,"scoutingScore":70,"talentProductionScore":75,"activityScore":65,"paymentHealthScore":90,"contextAdjustedDevelopmentScore":84,"weakAcademyDevelopmentScore":78,"availabilityScore":88,"injuryManagementScore":82,"attendanceReliabilityScore":91,"benchmarkCoverageScore":76,"dataConfidenceScore":80,"playersCount":40,"trainersCount":5,"divisionsCount":3,"reportsCount":18,"confidence":0.8}]}'
```

## Verify

```bash
python -m compileall app tests
python -m pytest
```
