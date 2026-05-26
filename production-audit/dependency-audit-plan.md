# Dependency Audit Plan

## Automated Gates Added

- GitHub Actions `dependency-audit` job runs `pip-audit` for Python requirement files.
- GitHub Actions `dependency-audit` job runs Maven dependency tree as a backend dependency-resolution smoke check.
- Dependabot is configured for GitHub Actions, Maven, Python services, Django chatbot, and Flutter pub packages.

## Still Needed

- Add OWASP Dependency-Check or Snyk for Java CVE reporting once CI runtime cost is accepted.
- Add a Flutter/Dart vulnerability audit when the selected CI image supports `dart pub outdated --json` parsing or a dedicated audit tool.
- Add a policy for severity thresholds: fail on critical/high, warn on medium, document accepted risk with owner and expiry.
- Generate dependency SBOMs for release artifacts.

## Recommended Release Gate

1. No critical or high CVEs without an approved exception.
2. All direct dependencies pinned or constrained with intentional ranges.
3. Dependabot PRs reviewed weekly.
4. Dependency exception records expire within 30 days unless renewed.
