from fastapi import Header, HTTPException, status

from app.core.config import get_settings


def require_service_token(x_service_token: str | None = Header(default=None)) -> None:
    expected = get_settings().service_token
    if not expected:
        return
    if x_service_token != expected:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid service token",
        )
