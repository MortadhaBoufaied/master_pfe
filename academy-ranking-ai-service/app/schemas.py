from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class AcademyFeatureRow(BaseModel):
    academyId: int
    academyName: str = "Academy"
    sportId: int | None = None
    sportName: str = ""
    city: str = ""
    country: str = ""
    playersCount: int = 0
    trainersCount: int = 0
    divisionsCount: int = 0
    paymentsCount: int = 0
    reportsCount: int = 0
    observationsCount: int = 0
    playerProgressionScore: float = 0.0
    contextAdjustedDevelopmentScore: float = 0.0
    weakAcademyDevelopmentScore: float = 0.0
    availabilityScore: float = 0.0
    injuryManagementScore: float = 0.0
    attendanceReliabilityScore: float = 0.0
    benchmarkCoverageScore: float = 0.0
    dataConfidenceScore: float = 0.0
    overallScore: float = 0.0
    playerDevelopmentScore: float = 0.0
    scoutingScore: float = 0.0
    activityScore: float = 0.0
    paymentHealthScore: float = 0.0
    talentProductionScore: float = 0.0
    confidence: float = 0.0
    rankingPosition: int = 0
    explanation: str = ""
    mainStrengths: str = ""
    mainWeaknesses: str = ""

    model_config = {"extra": "allow"}


class AcademyRankingRequest(BaseModel):
    items: list[AcademyFeatureRow] = Field(default_factory=list)
    limit: int = Field(default=10, ge=1, le=100)


class AcademyRankingItem(BaseModel):
    academyId: int
    academyName: str
    sportId: int | None = None
    sportName: str = ""
    city: str = ""
    country: str = ""
    rank: int
    rankingPosition: int
    overallScore: float
    mlScore: float
    confidence: float
    tier: str
    explanation: str
    mainStrengths: str = ""
    mainWeaknesses: str = ""
    featureContributions: dict[str, float] = Field(default_factory=dict)
    normalizedSignals: dict[str, float] = Field(default_factory=dict)


class AcademyRankingResponse(BaseModel):
    items: list[AcademyRankingItem]
    total: int
    source: str = "academy-ranking-ai-service"
    modelVersion: str
    generatedAt: datetime
    metadata: dict[str, Any] = Field(default_factory=dict)
