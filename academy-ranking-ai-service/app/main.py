import time
from collections import Counter
from threading import Lock
from uuid import uuid4

from fastapi import Depends, FastAPI
from fastapi.responses import PlainTextResponse

from app.core.auth import require_service_token
from app.core.config import get_settings
from app.schemas import AcademyRankingRequest, AcademyRankingResponse
from app.services.ranking_model import rank_academies


app = FastAPI(
    title="Academy Ranking AI Service",
    version=get_settings().model_version,
)
metrics_lock = Lock()
metrics = Counter()


@app.middleware("http")
async def request_observability_middleware(request, call_next):
    start = time.perf_counter()
    request_id = request.headers.get("X-Request-ID") or request.headers.get("X-Trace-ID") or str(uuid4())
    try:
        response = await call_next(request)
        return response
    finally:
        duration = time.perf_counter() - start
        status_code = getattr(locals().get("response", None), "status_code", 500)
        with metrics_lock:
            metrics["http_requests_total"] += 1
            metrics[f"http_responses_status_{status_code}_total"] += 1
            metrics["http_request_duration_seconds_sum"] += duration
        if "response" in locals():
            response.headers.setdefault("X-Request-ID", request_id)
            response.headers.setdefault("X-Trace-ID", request_id)


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


@app.get("/metrics", include_in_schema=False)
def prometheus_metrics() -> PlainTextResponse:
    with metrics_lock:
        snapshot = dict(metrics)
    total = float(snapshot.get("http_requests_total", 0))
    duration_sum = float(snapshot.get("http_request_duration_seconds_sum", 0))
    lines = [
        "# HELP academy_ranking_ai_http_requests_total Total HTTP requests handled by academy-ranking-ai-service.",
        "# TYPE academy_ranking_ai_http_requests_total counter",
        f"academy_ranking_ai_http_requests_total {total}",
        "# HELP academy_ranking_ai_http_request_duration_seconds_sum Total HTTP request duration in seconds.",
        "# TYPE academy_ranking_ai_http_request_duration_seconds_sum counter",
        f"academy_ranking_ai_http_request_duration_seconds_sum {duration_sum}",
    ]
    for key, value in sorted(snapshot.items()):
        if key.startswith("http_responses_status_"):
            status = key.removeprefix("http_responses_status_").removesuffix("_total")
            lines.append(f'academy_ranking_ai_http_responses_total{{status="{status}"}} {float(value)}')
    return PlainTextResponse("\n".join(lines) + "\n", media_type="text/plain; version=0.0.4")
