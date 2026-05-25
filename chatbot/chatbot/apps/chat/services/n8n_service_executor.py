"""N8N Service Executor - Routes detected services to n8n webhooks."""

import logging
import requests
import json
from typing import Dict, List, Optional, Any
from django.conf import settings

logger = logging.getLogger('chatbot')


class N8NServiceExecutor:
    """Executes services by routing them to n8n webhooks."""
    
    def __init__(self, n8n_base_url: Optional[str] = None):
        """
        Initialize executor with n8n base URL.
        
        Args:
            n8n_base_url: Base URL for n8n instance (defaults to settings.N8N_BASE_URL or http://localhost:5678)
        """
        if n8n_base_url:
            self.base_url = n8n_base_url
        elif hasattr(settings, 'N8N_BASE_URL'):
            self.base_url = settings.N8N_BASE_URL
        else:
            self.base_url = 'http://localhost:5678'
        
        self.timeout = getattr(settings, 'N8N_TIMEOUT', 10)
    
    def execute_service(
        self,
        service_id: str,
        service_definition: Dict,
        parameters: Optional[Dict] = None,
        user_context: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Execute a service by calling its n8n webhook.
        
        Args:
            service_id: ID of the service to execute
            service_definition: Service definition from registry
            parameters: Parameters extracted from user message
            user_context: User context (user_id, session data, etc.)
        
        Returns:
            Response from n8n webhook
        """
        try:
            webhook_path = service_definition.get('webhook_path', f'/webhook/{service_id}')
            webhook_url = self.base_url + webhook_path
            
            # Prepare payload
            payload = {
                'service_id': service_id,
                'service_name': service_definition.get('name'),
                'parameters': parameters or {},
                'user_context': user_context or {},
                'timestamp': __import__('datetime').datetime.now().isoformat(),
            }
            
            logger.info(f"Executing service {service_id} via webhook: {webhook_url}")
            
            # Make request to n8n webhook
            response = requests.post(
                webhook_url,
                json=payload,
                timeout=self.timeout,
                headers={'Content-Type': 'application/json'}
            )
            
            response.raise_for_status()
            
            result = response.json()
            logger.info(f"Service {service_id} executed successfully")
            
            return {
                'status': 'success',
                'service_id': service_id,
                'data': result,
                'webhook_url': webhook_url,
            }
        
        except requests.exceptions.Timeout:
            logger.error(f"Service {service_id} execution timeout")
            return {
                'status': 'error',
                'service_id': service_id,
                'error': 'Service execution timeout',
                'error_type': 'timeout'
            }
        
        except requests.exceptions.ConnectionError as e:
            logger.error(f"Connection error executing service {service_id}: {e}")
            return {
                'status': 'error',
                'service_id': service_id,
                'error': 'Could not connect to service',
                'error_type': 'connection_error'
            }
        
        except Exception as e:
            logger.error(f"Error executing service {service_id}: {e}")
            return {
                'status': 'error',
                'service_id': service_id,
                'error': str(e),
                'error_type': 'execution_error'
            }
    
    def execute_multiple_services(
        self,
        services: List[Dict],
        user_context: Optional[Dict] = None
    ) -> List[Dict[str, Any]]:
        """
        Execute multiple services.
        
        Args:
            services: List of dicts with 'service_id', 'service_definition', and 'parameters'
            user_context: User context
        
        Returns:
            List of execution results
        """
        results = []
        
        for service_def in services:
            result = self.execute_service(
                service_def['service_id'],
                service_def['service_definition'],
                service_def.get('parameters'),
                user_context
            )
            results.append(result)
        
        return results


# Singleton instance
_executor_instance = None


def get_n8n_executor() -> N8NServiceExecutor:
    """Get or create singleton N8NServiceExecutor instance."""
    global _executor_instance
    if _executor_instance is None:
        _executor_instance = N8NServiceExecutor()
    return _executor_instance
