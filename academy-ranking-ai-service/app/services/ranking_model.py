from __future__ import annotations

from datetime import datetime, timezone
from math import log1p

from app.core.config import get_settings
from app.schemas import (
    AcademyFeatureRow,
    AcademyRankingItem,
    AcademyRankingResponse,
)


WEIGHTS = {
    "playerDevelopmentScore": 0.16,
    "scoutingScore": 0.14,
    "talentProductionScore": 0.14,
    "activityScore": 0.10,
    "paymentHealthScore": 0.07,
    "growthScore": 0.06,
    "progressionScore": 0.12,
    "contextDevelopmentScore": 0.10,
    "availabilitySystemScore": 0.06,
    "confidenceScore": 0.05,
}


def rank_academies(
    rows: list[AcademyFeatureRow],
    *,
    limit: int,
) -> AcademyRankingResponse:
    scored = [_score_row(row) for row in rows]
    scored.sort(key=lambda item: (-item.mlScore, item.academyName.lower()))

    items: list[AcademyRankingItem] = []
    for index, item in enumerate(scored[:limit], start=1):
        items.append(item.model_copy(update={"rank": index, "rankingPosition": index}))

    return AcademyRankingResponse(
        items=items,
        total=len(scored),
        modelVersion=get_settings().model_version,
        generatedAt=datetime.now(timezone.utc),
        metadata={
            "inputRows": len(rows),
            "weights": WEIGHTS,
            "notes": "Stateless scoring from backend-provided academy feature rows.",
        },
    )


def _score_row(row: AcademyFeatureRow) -> AcademyRankingItem:
    growth_score = _growth_score(row)
    confidence_score = _confidence_score(row)
    progression_score = _progression_score(row)
    context_development_score = _context_development_score(row)
    availability_system_score = _availability_system_score(row)

    contributions = {
        "playerDevelopmentScore": _clamp(row.playerDevelopmentScore) * WEIGHTS["playerDevelopmentScore"],
        "scoutingScore": _clamp(row.scoutingScore) * WEIGHTS["scoutingScore"],
        "talentProductionScore": _clamp(row.talentProductionScore) * WEIGHTS["talentProductionScore"],
        "activityScore": _clamp(row.activityScore) * WEIGHTS["activityScore"],
        "paymentHealthScore": _clamp(row.paymentHealthScore) * WEIGHTS["paymentHealthScore"],
        "growthScore": growth_score * WEIGHTS["growthScore"],
        "progressionScore": progression_score * WEIGHTS["progressionScore"],
        "contextDevelopmentScore": context_development_score * WEIGHTS["contextDevelopmentScore"],
        "availabilitySystemScore": availability_system_score * WEIGHTS["availabilitySystemScore"],
        "confidenceScore": confidence_score * WEIGHTS["confidenceScore"],
    }

    ml_score = round(sum(contributions.values()), 2)
    confidence = round(max(_confidence_score(row) / 100.0, _coerce_confidence(row.confidence)), 2)

    return AcademyRankingItem(
        academyId=row.academyId,
        academyName=row.academyName,
        sportId=row.sportId,
        sportName=row.sportName,
        city=row.city,
        country=row.country,
        rank=row.rankingPosition,
        rankingPosition=row.rankingPosition,
        overallScore=round(_clamp(row.overallScore), 2),
        mlScore=ml_score,
        confidence=confidence,
        tier=_tier(ml_score),
        explanation=_explanation(row, ml_score),
        mainStrengths=row.mainStrengths,
        mainWeaknesses=row.mainWeaknesses,
        featureContributions={key: round(value, 2) for key, value in contributions.items()},
        normalizedSignals={
            "growthScore": round(growth_score, 2),
            "progressionScore": round(progression_score, 2),
            "contextDevelopmentScore": round(context_development_score, 2),
            "availabilitySystemScore": round(availability_system_score, 2),
            "confidenceScore": round(confidence_score, 2),
        },
    )


def _growth_score(row: AcademyFeatureRow) -> float:
    players = min(_positive(row.playersCount), 120)
    trainers = min(_positive(row.trainersCount), 30)
    divisions = min(_positive(row.divisionsCount), 20)
    reports = min(_positive(row.reportsCount), 100)
    raw = log1p(players) * 24.0 + log1p(trainers) * 15.0 + log1p(divisions) * 12.0 + log1p(reports) * 8.0
    return _clamp(raw)


def _progression_score(row: AcademyFeatureRow) -> float:
    direct = _positive(row.playerProgressionScore)
    if direct > 0:
        return _clamp(direct)
    observations = min(_positive(row.observationsCount), 140)
    reports = min(_positive(row.reportsCount), 80)
    development = _clamp(row.playerDevelopmentScore)
    coverage_boost = min(log1p(observations) * 8.0 + log1p(reports) * 4.0, 28.0)
    return _clamp(development * 0.72 + coverage_boost)


def _context_development_score(row: AcademyFeatureRow) -> float:
    direct = _positive(row.contextAdjustedDevelopmentScore)
    weak_context = _positive(row.weakAcademyDevelopmentScore)
    if direct > 0 or weak_context > 0:
        return _clamp(direct * 0.70 + weak_context * 0.30)
    return _clamp(row.playerDevelopmentScore * 0.70 + row.scoutingScore * 0.30)


def _availability_system_score(row: AcademyFeatureRow) -> float:
    direct = _positive(row.availabilityScore)
    injury = _positive(row.injuryManagementScore)
    attendance = _positive(row.attendanceReliabilityScore)
    if direct > 0 or injury > 0 or attendance > 0:
        values = [value for value in [direct, injury, attendance] if value > 0]
        return _clamp(sum(values) / len(values))
    return _clamp(row.activityScore * 0.65 + row.paymentHealthScore * 0.35)


def _confidence_score(row: AcademyFeatureRow) -> float:
    coverage = 0.0
    coverage += min(_positive(row.playersCount), 50) * 0.7
    coverage += min(_positive(row.reportsCount), 40) * 0.9
    coverage += min(_positive(row.observationsCount), 80) * 0.25
    coverage += min(_positive(row.paymentsCount), 50) * 0.35
    coverage += min(_positive(row.trainersCount), 20) * 0.45
    benchmark = _positive(row.benchmarkCoverageScore)
    data_confidence = _positive(row.dataConfidenceScore)
    explicit_confidence = max(benchmark, data_confidence)
    return _clamp(35.0 + coverage + explicit_confidence * 0.20)


def _explanation(row: AcademyFeatureRow, score: float) -> str:
    strongest = max(
        {
            "player development": row.playerDevelopmentScore,
            "scouting quality": row.scoutingScore,
            "talent production": row.talentProductionScore,
            "activity": row.activityScore,
            "payment health": row.paymentHealthScore,
            "context-adjusted development": _context_development_score(row),
            "availability system": _availability_system_score(row),
        }.items(),
        key=lambda item: item[1],
    )[0]
    return f"Ranked with score {score:.1f}; strongest signal is {strongest}."


def _tier(score: float) -> str:
    if score >= 82:
        return "Elite"
    if score >= 68:
        return "Strong"
    if score >= 52:
        return "Developing"
    return "Needs support"


def _positive(value: int | float | None) -> float:
    try:
        return max(0.0, float(value or 0))
    except (TypeError, ValueError):
        return 0.0


def _clamp(value: int | float | None) -> float:
    return max(0.0, min(100.0, _positive(value)))


def _coerce_confidence(value: float | None) -> float:
    raw = _positive(value)
    if raw > 1.0:
        return min(raw / 100.0, 1.0)
    return min(raw, 1.0)
