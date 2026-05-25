"""Metrics and monitoring for the chatbot service."""

import logging
import time
from contextlib import contextmanager
from typing import Any, Dict, Optional
from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta
from django.core.cache import cache

logger = logging.getLogger('chatbot')


@dataclass
class QueryMetrics:
    """Metrics for a single query."""
    message: str
    response_score: float
    category: str
    source: str
    processing_time_ms: float
    matched: bool
    timestamp: datetime = field(default_factory=datetime.now)
    model_version: str = "1.0"


class MetricsCollector:
    """Collect and track chatbot metrics."""

    METRICS_KEY = "chatbot:metrics"
    QUERIES_KEY = "chatbot:queries"
    ERRORS_KEY = "chatbot:errors"
    MAX_HISTORY = 1000

    @classmethod
    def record_query(cls, metrics: QueryMetrics) -> None:
        """Record a query metric."""
        if not metrics or not hasattr(metrics, '__dict__'):
            return

        try:
            # Add to history
            history = cache.get(cls.QUERIES_KEY, [])
            history.append(asdict(metrics))
            
            # Keep only recent history
            if len(history) > cls.MAX_HISTORY:
                history = history[-cls.MAX_HISTORY:]
            
            cache.set(cls.QUERIES_KEY, history, timeout=None)
            logger.debug(f"Recorded query metric: score={metrics.response_score}, time={metrics.processing_time_ms}ms")
        except Exception as e:
            logger.error(f"Failed to record query metrics: {e}")

    @classmethod
    def record_error(cls, error_type: str, message: str, context: Optional[Dict] = None) -> None:
        """Record an error."""
        try:
            error_record = {
                'error_type': error_type,
                'message': message,
                'context': context or {},
                'timestamp': datetime.now().isoformat(),
            }
            
            errors = cache.get(cls.ERRORS_KEY, [])
            errors.append(error_record)
            
            if len(errors) > cls.MAX_HISTORY:
                errors = errors[-cls.MAX_HISTORY:]
            
            cache.set(cls.ERRORS_KEY, errors, timeout=None)
            logger.error(f"Error recorded: {error_type} - {message}")
        except Exception as e:
            logger.error(f"Failed to record error: {e}")

    @classmethod
    def get_stats(cls) -> Dict[str, Any]:
        """Get current statistics."""
        try:
            queries = cache.get(cls.QUERIES_KEY, [])
            errors = cache.get(cls.ERRORS_KEY, [])

            if not queries:
                return {
                    'total_queries': 0,
                    'avg_response_time_ms': 0,
                    'matched_count': 0,
                    'matched_rate': 0.0,
                    'avg_score': 0.0,
                    'error_count': 0,
                    'error_rate': 0.0,
                    'uptime_hours': 0,
                    'categories': {},
                }

            matched = sum(1 for q in queries if q.get('matched'))
            avg_time = sum(q.get('processing_time_ms', 0) for q in queries) / len(queries)
            avg_score = sum(q.get('response_score', 0) for q in queries) / len(queries)
            
            categories = {}
            for q in queries:
                cat = q.get('category', 'unknown')
                if cat not in categories:
                    categories[cat] = 0
                categories[cat] += 1

            return {
                'total_queries': len(queries),
                'avg_response_time_ms': round(avg_time, 2),
                'matched_count': matched,
                'matched_rate': round(matched / len(queries), 4),
                'avg_score': round(avg_score, 4),
                'error_count': len(errors),
                'error_rate': round(len(errors) / (len(queries) + len(errors)), 4) if (len(queries) + len(errors)) > 0 else 0,
                'categories': categories,
            }
        except Exception as e:
            logger.error(f"Failed to get stats: {e}")
            return {}

    @classmethod
    def reset(cls) -> None:
        """Reset all metrics (for testing)."""
        cache.delete(cls.QUERIES_KEY)
        cache.delete(cls.ERRORS_KEY)
        logger.info("Metrics reset")


@contextmanager
def measure_time(name: str = "operation"):
    """Context manager to measure operation time."""
    start = time.time()
    try:
        yield
    finally:
        elapsed_ms = (time.time() - start) * 1000
        logger.debug(f"Operation '{name}' took {elapsed_ms:.2f}ms")


class HealthChecker:
    """Check system health."""

    @staticmethod
    def check_health() -> Dict[str, Any]:
        """Perform health check."""
        try:
            from apps.chat.services.bot import Chatbot
            
            status = {
                'status': 'healthy',
                'timestamp': datetime.now().isoformat(),
                'components': {
                    'database': _check_database(),
                    'cache': _check_cache(),
                    'ml_index': _check_ml_index(),
                },
                'stats': MetricsCollector.get_stats(),
            }
            return status
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return {
                'status': 'unhealthy',
                'error': str(e),
                'timestamp': datetime.now().isoformat(),
            }


def _check_database() -> Dict[str, Any]:
    """Check database connectivity."""
    try:
        from django.db import connection
        connection.ensure_connection()
        return {'status': 'ok', 'type': 'sqlite3'}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}


def _check_cache() -> Dict[str, Any]:
    """Check cache connectivity."""
    try:
        cache.set('health_check', 'ok', 10)
        result = cache.get('health_check')
        if result == 'ok':
            return {'status': 'ok', 'type': cache.__class__.__name__}
        return {'status': 'error', 'message': 'Cache test failed'}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}


def _check_ml_index() -> Dict[str, Any]:
    """Check ML index availability."""
    try:
        from apps.chat.services.ml_index import MLIndex
        from django.conf import settings
        
        index = MLIndex(settings.QA_CSV)
        index.load()
        return {
            'status': 'ok',
            'questions_loaded': len(index.df) if index.df is not None else 0,
        }
    except Exception as e:
        return {'status': 'error', 'message': str(e)}
