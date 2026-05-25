"""
Service Executor - Webhook handler for n8n service execution
"""
import json
import asyncio
import httpx
from typing import Dict, List, Optional, Any
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ServiceExecutor:
    """Executes services through n8n webhooks"""
    
    def __init__(self, base_webhook_url: str = "http://localhost:5678/webhook"):
        """
        Initialize ServiceExecutor
        
        Args:
            base_webhook_url: Base URL for n8n webhooks
        """
        self.base_webhook_url = base_webhook_url
        self.timeout = 10  # seconds
    
    async def execute_service(self, service_id: str, parameters: Dict[str, Any] = None,
                            user_id: str = None) -> Dict[str, Any]:
        """
        Execute a single service through n8n webhook
        
        Args:
            service_id: ID of the service to execute
            parameters: Service parameters
            user_id: Optional user ID
        
        Returns:
            Service response
        """
        if parameters is None:
            parameters = {}
        
        webhook_path = f"{self.base_webhook_url}/{service_id}"
        
        payload = {
            'service_id': service_id,
            'parameters': parameters,
            'user_id': user_id,
            'timestamp': datetime.utcnow().isoformat(),
            'request_id': self._generate_request_id()
        }
        
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(webhook_path, json=payload)
                
                if response.status_code == 200:
                    return {
                        'status': 'success',
                        'data': response.json(),
                        'execution_time_ms': response.elapsed.total_seconds() * 1000
                    }
                else:
                    return {
                        'status': 'error',
                        'error': f"Service returned status {response.status_code}",
                        'error_details': response.text
                    }
        
        except asyncio.TimeoutError:
            return {
                'status': 'error',
                'error': 'Service execution timeout',
                'error_type': 'timeout'
            }
        except Exception as e:
            logger.error(f"Error executing service {service_id}: {str(e)}")
            return {
                'status': 'error',
                'error': str(e),
                'error_type': 'execution_error'
            }
    
    async def execute_multiple_services(self, services: List[Dict], user_id: str = None) -> Dict[str, Any]:
        """
        Execute multiple services concurrently
        
        Args:
            services: List of dicts with 'service_id' and 'parameters'
            user_id: Optional user ID
        
        Returns:
            Combined results
        """
        tasks = []
        service_ids = []
        
        for service_def in services:
            service_id = service_def.get('service_id')
            parameters = service_def.get('parameters', {})
            service_ids.append(service_id)
            
            task = self.execute_service(service_id, parameters, user_id)
            tasks.append(task)
        
        try:
            results = await asyncio.gather(*tasks)
            
            return {
                'status': 'success',
                'services_executed': service_ids,
                'results': [
                    {
                        'service_id': service_ids[i],
                        **results[i]
                    }
                    for i in range(len(service_ids))
                ],
                'execution_time_ms': sum(
                    r.get('execution_time_ms', 0) for r in results
                )
            }
        except Exception as e:
            logger.error(f"Error executing multiple services: {str(e)}")
            return {
                'status': 'error',
                'error': f"Failed to execute services: {str(e)}",
                'services_attempted': service_ids
            }
    
    def _generate_request_id(self) -> str:
        """Generate unique request ID"""
        import uuid
        return str(uuid.uuid4())[:8]


class ServiceResponse:
    """Wrapper for service execution response"""
    
    def __init__(self, service_id: str, response_data: Dict[str, Any]):
        self.service_id = service_id
        self.data = response_data
        self.status = response_data.get('status', 'unknown')
        self.error = response_data.get('error')
        self.execution_time_ms = response_data.get('execution_time_ms', 0)
    
    def is_success(self) -> bool:
        return self.status == 'success'
    
    def is_error(self) -> bool:
        return self.status == 'error'
    
    def get_data(self) -> Optional[Dict]:
        return self.data.get('data') if self.is_success() else None
    
    def get_error_message(self) -> str:
        return self.error or "Unknown error"
    
    def to_dict(self) -> Dict:
        return {
            'service_id': self.service_id,
            'status': self.status,
            'error': self.error,
            'execution_time_ms': self.execution_time_ms,
            'data': self.data.get('data')
        }


# Synchronous wrapper for Django compatibility
class SyncServiceExecutor:
    """Synchronous wrapper for ServiceExecutor for use in Django views"""
    
    def __init__(self, base_webhook_url: str = "http://localhost:5678/webhook"):
        self.executor = ServiceExecutor(base_webhook_url)
    
    def execute_service(self, service_id: str, parameters: Dict[str, Any] = None,
                       user_id: str = None) -> Dict[str, Any]:
        """Synchronous execute service"""
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(
                self.executor.execute_service(service_id, parameters, user_id)
            )
        finally:
            loop.close()
    
    def execute_multiple_services(self, services: List[Dict], user_id: str = None) -> Dict[str, Any]:
        """Synchronous execute multiple services"""
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(
                self.executor.execute_multiple_services(services, user_id)
            )
        finally:
            loop.close()
