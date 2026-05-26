# Troubleshooting Guide

## Backend Fails at Startup

Symptom: `JWT_SECRET must be configured with at least 256 bits of key material`.

Resolution: set `JWT_SECRET` in the backend environment. Use a generated secret with at least 32 random bytes encoded as base64 or hex.

## AI Service Returns 503

Symptom: `Scouting service token is not configured` or `Academy ranking service token is not configured`.

Resolution: set `APP_ENV` correctly and provide the matching service-token env var. Missing tokens are allowed only for `dev`, `local`, and `test`.

## AI Service Returns 401

Symptom: `Invalid scouting service token` or `Invalid service token`.

Resolution: compare the Spring service-token property/env value with the FastAPI service env value. Rotate both together if either value leaked.

## N8N Routes General Chat to a Service

Symptom: unrelated prompts invoke `submit-feedback` or another service.

Resolution: inspect the service keywords and run `python -m pytest tests/test_service_detector.py -v` in `n8n-service-orchestration`. Short keywords should rely on exact boundary matches.

## Flutter Test Hangs Locally

Symptom: `flutter test` or `flutter --version` times out in a sandbox.

Resolution: allow Flutter SDK/cache access, then rerun `flutter test` from `sports-app`.

## Demo Seed Appears in Runtime Artifact

Symptom: `target/classes/Files/Data/data.json` exists after a clean backend build.

Resolution: rerun `mvn -q clean test -DskipITs` and verify the Maven resource exclusion in `sports_management_project/pom.xml` remains present.
