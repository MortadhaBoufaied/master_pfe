from app.schemas import AcademyFeatureRow
from app.services.ranking_model import rank_academies


def test_rank_academies_orders_by_ml_score():
    payload = [
        AcademyFeatureRow(
            academyId=1,
            academyName="Baseline Academy",
            playerDevelopmentScore=50,
            scoutingScore=50,
            talentProductionScore=50,
            activityScore=50,
            paymentHealthScore=50,
            playersCount=10,
            trainersCount=2,
            divisionsCount=1,
            reportsCount=2,
            confidence=0.5,
        ),
        AcademyFeatureRow(
            academyId=2,
            academyName="High Signal Academy",
            playerDevelopmentScore=88,
            scoutingScore=84,
            talentProductionScore=90,
            activityScore=78,
            paymentHealthScore=86,
            playersCount=55,
            trainersCount=8,
            divisionsCount=4,
            reportsCount=25,
            confidence=0.9,
        ),
    ]

    result = rank_academies(payload, limit=2)

    assert result.items[0].academyId == 2
    assert result.items[0].rank == 1
    assert result.items[0].mlScore > result.items[1].mlScore


def test_context_and_availability_raise_academy_signal():
    payload = [
        AcademyFeatureRow(
            academyId=1,
            academyName="Raw Strength Academy",
            playerDevelopmentScore=72,
            scoutingScore=70,
            talentProductionScore=72,
            activityScore=75,
            paymentHealthScore=78,
            playersCount=30,
            reportsCount=10,
            observationsCount=20,
            confidence=0.7,
        ),
        AcademyFeatureRow(
            academyId=2,
            academyName="Development Context Academy",
            playerDevelopmentScore=68,
            scoutingScore=74,
            talentProductionScore=70,
            activityScore=74,
            paymentHealthScore=74,
            playersCount=30,
            reportsCount=10,
            observationsCount=20,
            contextAdjustedDevelopmentScore=92,
            weakAcademyDevelopmentScore=88,
            availabilityScore=90,
            injuryManagementScore=84,
            attendanceReliabilityScore=94,
            benchmarkCoverageScore=80,
            dataConfidenceScore=82,
            confidence=0.7,
        ),
    ]

    result = rank_academies(payload, limit=2)

    assert result.items[0].academyId == 2
    assert result.items[0].normalizedSignals["contextDevelopmentScore"] > 80
    assert result.items[0].normalizedSignals["availabilitySystemScore"] > 80
