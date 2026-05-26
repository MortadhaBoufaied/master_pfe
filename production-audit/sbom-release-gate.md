# SBOM And Dependency Release Gate

## Implemented CI Direction

- Python direct requirement audits run with `pip-audit`.
- Maven dependency resolution runs in CI.
- Dependabot is configured for GitHub Actions, Maven, pip, and Flutter pub.

## Required For Release Certification

1. Generate SBOMs for Spring, Python services, and Flutter.
2. Store SBOMs as CI artifacts for every release candidate.
3. Fail release on critical/high CVEs unless an exception is approved.
4. Exceptions must include owner, expiry date, package/version, affected service, and compensating control.
5. Rebuild SBOMs after dependency updates and before production deployment.

## Recommended Commands

Spring:

```powershell
cd sports_management_project
mvn -q -DskipTests org.cyclonedx:cyclonedx-maven-plugin:2.8.0:makeAggregateBom
```

Python direct requirements:

```powershell
python -m pip_audit --no-deps -r scouting-ai-service/requirements.txt -f cyclonedx-json -o production-audit/sbom-scouting-ai.json
python -m pip_audit --no-deps -r academy-ranking-ai-service/requirements.txt -f cyclonedx-json -o production-audit/sbom-academy-ranking-ai.json
python -m pip_audit --no-deps -r n8n-service-orchestration/requirements.txt -f cyclonedx-json -o production-audit/sbom-n8n-support.json
python -m pip_audit --no-deps -r chatbot/chatbot/requirements.txt -f cyclonedx-json -o production-audit/sbom-chatbot.json
```

Flutter:

```powershell
cd sports-app
dart pub outdated --json > ../production-audit/flutter-pub-outdated.json
```

## Remaining Gap

Release-grade Python SBOMs should use locked, hashed transitive dependencies. The current direct audits are useful but are not a substitute for fully reproducible release lockfiles.

