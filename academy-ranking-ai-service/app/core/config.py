from functools import lru_cache
from os import getenv

from pydantic import BaseModel


class Settings(BaseModel):
    service_name: str = "academy-ranking-ai-service"
    app_env: str = getenv("APP_ENV", "dev").strip().lower()
    service_token: str = getenv("ACADEMY_RANKING_AI_SERVICE_TOKEN", "").strip()
    model_version: str = getenv("ACADEMY_RANKING_MODEL_VERSION", "academy-ranking-v1")


@lru_cache
def get_settings() -> Settings:
    return Settings()
