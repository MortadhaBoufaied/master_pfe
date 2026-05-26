import asyncio
import sys
from pathlib import Path

import httpx

sys.path.insert(0, str(Path(__file__).parent.parent / "webhooks"))

import service_executor
from service_executor import ServiceExecutor


class TimeoutClient:
    def __init__(self, *args, **kwargs):
        pass

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        return False

    async def post(self, *args, **kwargs):
        raise httpx.TimeoutException("request timed out")


def test_execute_service_maps_httpx_timeout(monkeypatch):
    monkeypatch.setattr(service_executor.httpx, "AsyncClient", TimeoutClient)

    result = asyncio.run(ServiceExecutor().execute_service("get-schedule"))

    assert result["status"] == "error"
    assert result["error_type"] == "timeout"
