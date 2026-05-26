from secrets import compare_digest

from fastapi import Header, HTTPException, status

from app.core.config import get_settings


DEV_ENVS = {"dev", "local", "test"}


def require_service_token(x_service_token: str | None = Header(default=None)) -> None:
    settings = get_settings()
    expected = settings.service_token
    if not expected:
        if settings.app_env in DEV_ENVS:
            return
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Academy ranking service token is not configured",
        )
    if not x_service_token or not compare_digest(x_service_token, expected):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid service token",
        )
