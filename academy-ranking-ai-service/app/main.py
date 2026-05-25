from fastapi import Depends, FastAPI

from app.core.auth import require_service_token
from app.core.config import get_settings
from app.schemas import AcademyRankingRequest, AcademyRankingResponse
from app.services.ranking_model import rank_academies


app = FastAPI(
    title="Academy Ranking AI Service",
    version=get_settings().model_version,
)


@app.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "ok",
        "service": get_settings().service_name,
        "modelVersion": get_settings().model_version,
    }


@app.post(
    "/api/v1/rankings/academies/score",
    response_model=AcademyRankingResponse,
    dependencies=[Depends(require_service_token)],
)
def score_academies(payload: AcademyRankingRequest) -> AcademyRankingResponse:
    return rank_academies(payload.items, limit=payload.limit)
