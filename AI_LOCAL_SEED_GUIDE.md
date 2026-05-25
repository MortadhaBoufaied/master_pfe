# AI Local Seed Guide

This seed is a compact demo dataset for the Spring backend and the local AI services.
It keeps the backend database as the source of truth while giving the AI projects local
export files for fast historical/player-development experiments.

## Generated Files

- `sports_management_project/seed.prepared.json`
- `sports_management_project/src/main/resources/Files/Data/data.json`
- `ressources/files/Data/data.json`
- `scouting-ai-service/data/exports/player_snapshot_training_dataset.jsonl`
- `scouting-ai-service/data/exports/player_snapshot_training_dataset.csv`
- `academy-ranking-ai-service/data/exports/academy_snapshot_training_dataset.jsonl`

## Stable Join Keys

The database seed and local AI files share these keys:

- `playerEmail`
- `academySlug`
- `sportCode`
- `divisionKey`

The AI export files are support/history files only. Live scouting and academy ranking
should still request current feature snapshots from the Spring backend.

## AI-Relevant Seed Fields

Player scouting:

- `sportStatistics`
- `playerAttributeSnapshots`
- `playerProgressions`
- `playerPerformanceObservations`
- `talentScores`
- `scoutingReports`
- `scouterWatchedPlayers`

Academy ranking:

- `academyPerformanceScores`
- `activities`
- `academyPayments`
- `payments`
- `playerProgressions`
- `playerPerformanceObservations`

Communication and UX demo:

- `conversations`
- `messages`
- `messageReads`
- `notifications`

## Regenerate

```powershell
python tmp/generate_ai_local_seed.py
```

## Validate Counts

```powershell
.\tmp\count_seed_arrays.ps1
.\tmp\count_seed_arrays_ressources.ps1
```

## Backend Import

The backend importer reads `src/main/resources/Files/Data/data.json` when full seed import
is enabled:

```powershell
cd sports_management_project
mvn spring-boot:run
```

For one-shot seeding, use your configured PostgreSQL connection and add:

```powershell
-Dspring-boot.run.arguments="--app.seed.full-json=true --app.seed.exit-after-run=true"
```
