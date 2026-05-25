"""
Service Detector - Integration with Django Chatbot
Detects services from user messages and routes to n8n
"""
import json
import asyncio
from typing import Dict, List, Optional, Any, Tuple
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ServiceDetector:
    """
    Detects services from user messages and integrates with chatbot
    """
    
    def __init__(self, service_matcher=None, response_formatter=None, service_executor=None):
        """
        Initialize ServiceDetector
        
        Args:
            service_matcher: ServiceMatcher instance
            response_formatter: ResponseFormatter instance
            service_executor: ServiceExecutor instance
        """
        # Import here to avoid circular imports
        from service_matcher import ServiceMatcher
        from response_formatter import ResponseFormatter
        from webhooks.service_executor import SyncServiceExecutor
        
        self.matcher = service_matcher or ServiceMatcher()
        self.formatter = response_formatter or ResponseFormatter()
        self.executor = service_executor or SyncServiceExecutor()
    
    async def detect_and_execute(self, message: str, user_id: str = None) -> Optional[Dict[str, Any]]:
        """
        Detect services from message and execute them
        
        Returns:
            Formatted response if service detected, None otherwise
        """
        # Detect services
        service_ids = self.matcher.detect_services(message)
        
        if not service_ids:
            logger.info(f"No services detected in message: {message}")
            return None
        
        logger.info(f"Services detected: {service_ids}")
        
        # Extract parameters for each service
        services_to_execute = []
        for service_id in service_ids:
            parameters = self.matcher.extract_parameters(message, service_id)
            is_valid, error_msg = self.matcher.validate_parameters(service_id, parameters)
            
            if is_valid:
                services_to_execute.append({
                    'service_id': service_id,
                    'parameters': parameters
                })
            else:
                logger.warning(f"Invalid parameters for {service_id}: {error_msg}")
        
        if not services_to_execute:
            logger.info("No valid services to execute")
            return None
        
        # Execute services
        if len(services_to_execute) == 1:
            return await self._execute_and_format_single(
                services_to_execute[0],
                user_id
            )
        else:
            return await self._execute_and_format_multiple(
                services_to_execute,
                user_id
            )
    
    async def _execute_and_format_single(self, service_def: Dict, user_id: str = None) -> Dict[str, Any]:
        """Execute single service and format response"""
        service_id = service_def['service_id']
        parameters = service_def['parameters']
        
        # Execute service
        response = await self._execute_service_async(service_id, parameters, user_id)
        
        # Format response
        formatted = self.formatter.format_service_response(
            service_id,
            response,
            status='success' if response.get('status') == 'success' else 'error'
        )
        
        return {
            'type': 'service_response',
            'service_id': service_id,
            'formatted_response': formatted['formatted_response'],
            'raw_response': response,
            'execution_time_ms': response.get('execution_time_ms', 0)
        }
    
    async def _execute_and_format_multiple(self, services_list: List[Dict], user_id: str = None) -> Dict[str, Any]:
        """Execute multiple services and format combined response"""
        results = []
        
        # Execute all services
        tasks = []
        for service_def in services_list:
            task = self._execute_service_async(
                service_def['service_id'],
                service_def['parameters'],
                user_id
            )
            tasks.append(task)
        
        try:
            responses = await asyncio.gather(*tasks)
        except Exception as e:
            logger.error(f"Error executing services: {str(e)}")
            responses = [{'status': 'error', 'error': str(e)}] * len(services_list)
        
        # Format each response
        for i, service_def in enumerate(services_list):
            service_id = service_def['service_id']
            response = responses[i]
            
            formatted = self.formatter.format_service_response(
                service_id,
                response,
                status='success' if response.get('status') == 'success' else 'error'
            )
            
            results.append(formatted)
        
        # Combine responses
        combined_message = self.formatter.format_multiple_services_response(results)
        
        return {
            'type': 'multiple_service_response',
            'services_executed': [s['service_id'] for s in services_list],
            'formatted_response': combined_message,
            'results': results,
            'total_execution_time_ms': sum(r.get('execution_time_ms', 0) for r in responses)
        }
    
    async def _execute_service_async(self, service_id: str, parameters: Dict, user_id: str = None) -> Dict:
        """Execute service asynchronously"""
        try:
            # In async context, we need to wrap the sync executor
            loop = asyncio.get_event_loop()
            
            response = await loop.run_in_executor(
                None,
                self.executor.execute_service,
                service_id,
                parameters,
                user_id
            )
            
            return response
        except Exception as e:
            logger.error(f"Error executing service {service_id}: {str(e)}")
            return {
                'status': 'error',
                'error': str(e),
                'error_type': 'execution_error'
            }


# Synchronous version for Django views
class SyncServiceDetector:
    """Synchronous version of ServiceDetector for Django"""
    
    def __init__(self, service_matcher=None, response_formatter=None, service_executor=None):
        """Initialize with components"""
        from service_matcher import ServiceMatcher
        from response_formatter import ResponseFormatter
        from webhooks.service_executor import SyncServiceExecutor
        
        self.matcher = service_matcher or ServiceMatcher()
        self.formatter = response_formatter or ResponseFormatter()
        self.executor = service_executor or SyncServiceExecutor()
    
    def detect_and_execute(self, message: str, user_id: str = None) -> Optional[Dict[str, Any]]:
        """
        Synchronous version: Detect services and execute them
        
        Returns:
            Dict with service response or None if no services matched
        """
        # Detect services
        service_ids = self.matcher.detect_services(message)
        
        if not service_ids:
            logger.info(f"No services detected in message: {message}")
            return None
        
        logger.info(f"Services detected: {service_ids}")
        
        # Extract and validate parameters
        services_to_execute = []
        for service_id in service_ids:
            parameters = self.matcher.extract_parameters(message, service_id)
            is_valid, error_msg = self.matcher.validate_parameters(service_id, parameters)
            
            if is_valid:
                services_to_execute.append({
                    'service_id': service_id,
                    'parameters': parameters
                })
            else:
                logger.warning(f"Invalid parameters for {service_id}: {error_msg}")
        
        if not services_to_execute:
            return None
        
        # Execute services
        if len(services_to_execute) == 1:
            service_id = services_to_execute[0]['service_id']
            parameters = services_to_execute[0]['parameters']
            
            response = self.executor.execute_service(service_id, parameters, user_id)
            
            formatted = self.formatter.format_service_response(
                service_id,
                response,
                status='success' if response.get('status') == 'success' else 'error'
            )
            
            return {
                'type': 'service_response',
                'service_id': service_id,
                'formatted_response': formatted['formatted_response'],
                'raw_response': response
            }
        else:
            # Execute multiple services
            services_list = services_to_execute
            results = []
            
            for service_def in services_list:
                response = self.executor.execute_service(
                    service_def['service_id'],
                    service_def['parameters'],
                    user_id
                )
                
                formatted = self.formatter.format_service_response(
                    service_def['service_id'],
                    response,
                    status='success' if response.get('status') == 'success' else 'error'
                )
                
                results.append(formatted)
            
            combined_message = self.formatter.format_multiple_services_response(results)
            
            return {
                'type': 'multiple_service_response',
                'services_executed': [s['service_id'] for s in services_list],
                'formatted_response': combined_message,
                'results': results
            }


# Singleton instance
_detector_instance = None

def get_service_detector() -> SyncServiceDetector:
    """Get or create singleton service detector"""
    global _detector_instance
    if _detector_instance is None:
        _detector_instance = SyncServiceDetector()
    return _detector_instance
