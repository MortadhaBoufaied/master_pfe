from app.main import app
from fastapi.testclient import TestClient


def test_openapi_contract_exposes_ranking_endpoint() -> None:
    schema = app.openapi()
    paths = schema["paths"]

    assert "/health" in paths
    assert "get" in paths["/health"]
    assert "/api/v1/rankings/academies/score" in paths
    assert "post" in paths["/api/v1/rankings/academies/score"]


def test_ranking_endpoint_has_request_and_response_schemas() -> None:
    schema = app.openapi()
    operation = schema["paths"]["/api/v1/rankings/academies/score"]["post"]

    request_schema = operation["requestBody"]["content"]["application/json"]["schema"]
    response_schema = operation["responses"]["200"]["content"]["application/json"]["schema"]

    assert request_schema["$ref"].endswith("/AcademyRankingRequest")
    assert response_schema["$ref"].endswith("/AcademyRankingResponse")


def test_metrics_endpoint_exposes_prometheus_text() -> None:
    client = TestClient(app)

    response = client.get("/metrics", headers={"X-Request-ID": "test-request-id"})

    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert "academy_ranking_ai_http_requests_total" in response.text
    assert response.headers["X-Request-ID"] == "test-request-id"
