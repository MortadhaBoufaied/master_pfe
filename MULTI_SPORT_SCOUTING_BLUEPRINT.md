# Multi-Sport Scouting Blueprint

## Goal

Build scouting around generic observations, metric definitions, context, and derived features. New sports should require configuration first: sport roles, metric catalog, event catalog, benchmark curves, scoring weights, and report templates. Backend classes and database tables should only change when the platform needs a new generic concept.

## Research Basis

Sport-science talent identification research repeatedly treats talent as multidimensional, longitudinal, and context dependent:

- Talent ID should combine physical, technical, tactical, psychological, perceptual-cognitive, social, and environmental factors.
- Youth evaluation should account for relative age and biological maturation because early-maturing athletes can look better today while late-maturing athletes may have stronger upside.
- Raw match stats need context: opponent strength, team strength, role, minutes, competition level, match state, and pressure.
- Injury burden, training attendance, workload, and availability affect both development probability and scouting risk.
- Academy strength should be measured by player development over time, not only current player quality.

Useful starting sources:

- https://pubmed.ncbi.nlm.nih.gov/29082463/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC4880304/
- https://www.mdpi.com/2075-4663/10/6/81
- https://link.springer.com/article/10.1007/s40279-014-0248-9
- https://www.mdpi.com/1660-4601/18/1/328
- https://pubmed.ncbi.nlm.nih.gov/34767492/
- https://arxiv.org/abs/2412.05911
- https://arxiv.org/abs/2402.06815
- https://arxiv.org/abs/1706.04336
- https://pmc.ncbi.nlm.nih.gov/articles/PMC9968720/

## Scouting Types

- Talent detection: broad athletic potential before deep specialization.
- Talent identification: high-potential athletes inside a specific sport.
- Recruitment scouting: shortlist, trial, sign, monitor, or reject decisions.
- Development scouting: strengths, weaknesses, training needs, and improvement path.
- Match scouting: competition performance with minutes, role, result, and opponent context.
- Video/event scouting: tagged actions, decisions, success rate, location, and pressure.
- Medical scouting: injury burden, recurrence, recovery, and availability.
- Behavioral scouting: attendance, punctuality, responsibility, coachability, discipline.
- Tactical/role scouting: decision-making, role fit, style fit, tactical adaptability.
- Academy scouting: academy strength, training quality, player development output.
- Opposition/team scouting: opponent quality, style, matchup difficulty, competition level.

## Minimal Generic Database

### Identity and Configuration

- `sports`: sport code, name, active flag, metadata.
- `sport_roles`: sport, code, name, role group, role profile metadata.
- `metric_definitions`: sport, role optional, code, category, data type, unit, direction, weight, min/max normalization, active flag.
- `event_definitions`: sport, code, category, success model, location model, active flag.
- `scoring_profiles`: sport, role optional, model version, scoring weights, active period.
- `benchmark_curves`: sport, role, age band, sex/category, maturity band, academy level, metric, percentile values.

### Athlete and Participation

- `athlete_profiles`: player identity, academy, sport, primary role, birth date, sex/category, height, weight, maturity fields.
- `sessions`: training, match, test, video review, medical check, competition, manual report.
- `participations`: athlete, session, role played, minutes/attempts, starter flag, own team strength, opponent strength, competition level, pressure, result.
- `performance_observations`: athlete, sport, role, session/source type, observed at, confidence, summary rating, notes.
- `observation_metric_values`: observation, metric definition, raw value, normalized value, text value, confidence.
- `event_observations`: participation or video asset, event definition, athlete, timestamp, location, success, pressure, metadata.

### Health, Behavior, and Reports

- `injury_events`: athlete, injury type, body area, severity, start/end, lost training days, lost match days, recurrence flag.
- `attendance_records`: athlete, session, status, absence reason, punctuality, effort/RPE, staff note.
- `workload_records`: athlete, session, minutes, load, fatigue, recovery, optional GPS/wearable payload.
- `scouting_reports`: athlete, scout, sport, role, report type, recommendation, confidence, notes, status.
- `report_dimension_scores`: report, dimension code, score, weight, explanation.
- `derived_player_features`: athlete, sport, role, period, feature JSON, model version, confidence, created at.
- `player_scores`: athlete, sport, role, score type, value, level, explanation JSON, model version, created at.

## Rule for Avoiding Table Growth

Do not add first-class player columns for sport stats such as `goals`, `assists`, `rebounds`, `takedowns`, `lap_time`, or `aces`.

Use:

- `metric_definitions` for what the metric means.
- `observation_metric_values` for measured values.
- `derived_player_features` for AI-ready aggregates.
- `player_scores` for generated outputs and explanations.

Fixed fields on `athlete_profiles` should only describe identity and long-lived profile facts.

## Common AI Features

- `current_level_score`: current normalized sport/role performance.
- `progression_velocity`: recent improvement rate.
- `progression_vs_cohort`: improvement compared with similar age, role, maturity, sport, and level.
- `context_adjusted_score`: performance adjusted by opponent, team, competition, role, and pressure.
- `weak_team_strong_opponent_signal`: strong performance when own academy/team is weaker than the opponent.
- `attendance_reliability_score`: attendance, punctuality, unexplained absences, responsibility signal.
- `availability_score`: athlete is trainable and selectable across time.
- `injury_burden_score`: injury days, recurrence, severity, and interrupted development.
- `role_fit_score`: fit to sport role profile.
- `maturity_adjusted_potential`: potential adjusted for relative age and biological maturity.
- `late_bloomer_signal`: medium current level with above-cohort improvement.
- `pressure_performance_score`: performance in high-importance or high-difficulty contexts.
- `scout_confidence_score`: volume, recency, source quality, and agreement between observations.
- `academy_development_score`: academy ability to improve athletes over time.
- `data_confidence_score`: benchmark coverage, observation depth, and feature completeness.

## Sport Examples

- Football: metrics include pass success, xG contribution, defensive actions, sprint speed, duels, role fit. Context includes opponent strength, own team strength, match importance, minutes, score state.
- Basketball: metrics include points efficiency, assists, turnovers, rebounds, defensive stops, role usage, pace-adjusted impact.
- Swimming: metrics include race time, split consistency, stroke efficiency, start reaction, turn quality, training attendance, competition level.
- Tennis: metrics include serve percentage, return points won, unforced errors, rally tolerance, opponent ranking, surface, match pressure.
- Combat sports: metrics include takedown success, strike accuracy, defense, endurance, weight class, opponent level, injury risk, decision quality.

## Microservice Ownership

- Spring Boot backend owns canonical history, RBAC, database writes, observations, metric definitions, benchmark curves, feature snapshots, and persisted AI scores.
- `scouting-ai-service` owns scoring interpretation: potential, evolution, churn/risk, search, comparison, shortlist strategies, factor explanations.
- `academy-ranking-ai-service` owns academy ranking interpretation from backend-provided normalized academy feature rows.
- Local AI service files may store exports, caches, training sets, and model artifacts, but they must be rebuildable from the backend database.

## Migration Plan

1. Keep existing football-shaped fields temporarily as legacy cached summaries.
2. Backfill `metric_definitions` for current sports and map old fields into metric codes.
3. Create observations and metric values from existing player stats, reports, match events, attendance, and injuries.
4. Generate weekly `derived_player_features` snapshots from observations and contexts.
5. Point AI payloads to generic derived features while still sending legacy fields for compatibility.
6. Move frontend and reports to read from scores/features instead of fixed player columns.
7. Mark fixed fields like `goals`, `assists`, and `matches` as deprecated caches.
8. Remove or archive redundant local AI data ownership once backend snapshots are reliable.

## Keep, Merge, Remove

- Keep: sports, sport roles/positions, sport statistics/metric definitions, observations, metric values, scouting reports, injuries, attendance, video assets if video is a real product feature.
- Merge: player progression and attribute snapshots into observations plus derived features where possible.
- Convert to cache: player goals, assists, matches, average rating, talent score summaries, ranking summaries.
- Remove later: duplicate local AI tables that try to own canonical player/scouting data.

## Fairness and Explainability

- Store model version and scoring profile version with every generated score.
- Store factor contributions so scouts can understand why a player is ranked.
- Compare athletes against relevant cohorts: sport, role, age band, sex/category, maturity band, competition level.
- Track confidence separately from score so weak data does not look like weak talent.
- Treat injury and attendance as risk/context signals, with human review before strong negative labels.
- Monitor relative age and maturation bias in rankings and shortlist outputs.
