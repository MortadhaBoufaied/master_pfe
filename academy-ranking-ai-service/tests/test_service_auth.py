from types import SimpleNamespace

import pytest
from fastapi import HTTPException, status

from app.core import auth


def test_missing_token_is_allowed_only_in_dev(monkeypatch) -> None:
    monkeypatch.setattr(
        auth,
        "get_settings",
        lambda: SimpleNamespace(app_env="dev", service_token=""),
    )

    auth.require_service_token(None)


def test_missing_token_fails_closed_in_prod(monkeypatch) -> None:
    monkeypatch.setattr(
        auth,
        "get_settings",
        lambda: SimpleNamespace(app_env="prod", service_token=""),
    )

    with pytest.raises(HTTPException) as exc_info:
        auth.require_service_token(None)

    assert exc_info.value.status_code == status.HTTP_503_SERVICE_UNAVAILABLE


def test_invalid_token_is_rejected(monkeypatch) -> None:
    monkeypatch.setattr(
        auth,
        "get_settings",
        lambda: SimpleNamespace(app_env="prod", service_token="expected"),
    )

    with pytest.raises(HTTPException) as exc_info:
        auth.require_service_token("wrong")

    assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED


def test_valid_token_is_accepted(monkeypatch) -> None:
    monkeypatch.setattr(
        auth,
        "get_settings",
        lambda: SimpleNamespace(app_env="prod", service_token="expected"),
    )

    auth.require_service_token("expected")
