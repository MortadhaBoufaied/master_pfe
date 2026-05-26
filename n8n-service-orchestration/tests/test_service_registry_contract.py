import json
from pathlib import Path


REGISTRY_PATH = Path(__file__).resolve().parents[1] / "service-registry" / "services.json"
REQUIRED_SERVICE_FIELDS = {
    "id",
    "name",
    "description",
    "category",
    "keywords",
    "enabled",
    "workflow_id",
    "webhook_path",
    "timeout_ms",
    "response_type",
    "requires_authentication",
    "parameters",
    "responses",
}


def _load_registry() -> dict:
    return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))


def test_service_registry_contract_has_unique_enabled_service_ids() -> None:
    registry = _load_registry()
    enabled_services = [service for service in registry["services"] if service.get("enabled")]
    service_ids = [service["id"] for service in enabled_services]

    assert enabled_services
    assert len(service_ids) == len(set(service_ids))


def test_enabled_services_have_required_contract_fields() -> None:
    registry = _load_registry()

    for service in registry["services"]:
        if not service.get("enabled"):
            continue

        missing = REQUIRED_SERVICE_FIELDS - service.keys()
        assert not missing, f"{service.get('id', '<missing id>')} missing {sorted(missing)}"
        assert service["id"].strip()
        assert service["workflow_id"].strip()
        assert service["webhook_path"].startswith("/webhook/")
        assert 500 <= int(service["timeout_ms"]) <= 30000
        assert service["response_type"] in {"direct", "chatbot", "hybrid"}
        assert isinstance(service["keywords"], list)
        assert service["keywords"]
        assert "success" in service["responses"]
        assert "error" in service["responses"]


def test_required_academy_chatbot_services_remain_registered() -> None:
    registry = _load_registry()
    service_ids = {service["id"] for service in registry["services"] if service.get("enabled")}

    expected = {
        "get-user-profile",
        "book-appointment",
        "get-schedule",
        "get-payment-status",
        "get-player-stats",
        "get-events",
        "submit-scouting-report",
        "submit-feedback",
    }

    assert expected <= service_ids

