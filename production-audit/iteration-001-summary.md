# Iteration 1 Summary: Discovery and Baseline

**Focus Area:** Repository inventory, baseline tests, static checks, security scan.

**What passed**
- Spring backend compiles and active unit tests pass: `mvn -q test -DskipITs` ran 3/3 passing tests.
- Python services passed syntax compilation via `python -m compileall` for scouting AI, academy ranking AI, N8N support code and Django chatbot.
- Service inventory is now mapped across Spring, Flutter, FastAPI, Django and N8N support folders.

**Top issues found**
- Critical secrets/config risk: fixed `jwt.secret` and `stripe.secret.key` are versioned in Spring config.
- Critical service-auth risk: FastAPI shared-token auth is skipped if token env vars are empty.
- Critical seed risk: packaged `data.json` contains known demo accounts with password `admin`.
- High testing gap: Python test runner is missing and Flutter’s only test is stale/failing.
- High quality-gate gap: Spring checkstyle reports 23,034 findings; Flutter analyze reports 808 findings.

**Test status**
- `sports_management_project`: passed, 3/3 tests.
- `sports-app`: failed, 0/1 tests; stale counter-template test at `sports-app/test/widget_test.dart`.
- Python services: blocked for pytest, but compile checks pass.

**Artifacts**
- Machine report: `production-audit/iteration-001-report.json`
- Architecture map: `production-audit/architecture-map.md`
- Findings tracker: `production-audit/master-findings.md`
- Raw Flutter analyzer output: `production-audit/flutter-analyze.txt`
- Secret scan baseline: `production-audit/secret-scan-baseline.txt`

**Recommended next iteration**
- Start with config security: move Spring JWT/Stripe secrets to mandatory env vars, exclude demo seeds from production artifacts, then make FastAPI service auth fail closed outside dev.
