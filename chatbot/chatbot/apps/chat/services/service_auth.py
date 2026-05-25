"""
Service authorization integration - Communicates with scouting-ai-service backend.
Checks user permissions for accessing services.
"""
import logging
import os
from typing import Optional, Dict, Any

import httpx

logger = logging.getLogger('chatbot')

# Backend service URL
BACKEND_SERVICE_URL = os.getenv(
    'BACKEND_SERVICE_URL',
    'http://localhost:8000/api/v1'
)


class ServiceAuthClient:
    """Client to communicate with backend service for authorization checks."""
    
    def __init__(self, base_url: str = BACKEND_SERVICE_URL):
        self.base_url = base_url
        self.timeout = 5.0
    
    async def check_service_access(
        self,
        user_id: int,
        service: str,
    ) -> Dict[str, Any]:
        """
        Check if user can access a specific service.
        
        Args:
            user_id: User ID from request
            service: Service name to check access for
            
        Returns:
            Dict with authorization result and explanation
        """
        if not user_id:
            return {
                "can_access": False,
                "reason": "User ID not provided",
                "redirect_to_chatbot": True,
            }
        
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    f"{self.base_url}/auth/check-service-access",
                    params={
                        "service": service,
                        "user_id": user_id,
                    }
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    logger.warning(
                        f"Backend auth check failed: {response.status_code} - {response.text}"
                    )
                    return {
                        "can_access": False,
                        "reason": "Could not verify service access",
                        "redirect_to_chatbot": True,
                    }
        except Exception as exc:
            logger.error(f"Error checking service access: {exc}")
            # On error, deny access to be safe
            return {
                "can_access": False,
                "reason": "Service verification failed",
                "redirect_to_chatbot": True,
            }
    
    async def get_user_info(self, user_id: int) -> Optional[Dict[str, Any]]:
        """
        Get user information from backend.
        
        Args:
            user_id: User ID
            
        Returns:
            User information dict or None on error
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(
                    f"{self.base_url}/auth/services/{user_id}"
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    logger.warning(
                        f"Could not fetch user info: {response.status_code}"
                    )
                    return None
        except Exception as exc:
            logger.error(f"Error fetching user info: {exc}")
            return None
    
    async def process_service_request(
        self,
        user_id: int,
        service: str,
        action: str,
        payload: Dict[str, Any],
    ) -> Dict[str, Any]:
        """
        Process a service request through the backend broker.
        
        Args:
            user_id: User ID
            service: Service name
            action: Action to perform
            payload: Request payload
            
        Returns:
            Broker response with authorization and routing info
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    f"{self.base_url}/broker/process-request",
                    json={
                        "service": service,
                        "user_id": user_id,
                        "action": action,
                        "payload": payload,
                    }
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    logger.warning(
                        f"Service request processing failed: {response.status_code}"
                    )
                    return {
                        "status": "error",
                        "can_process": False,
                        "reason": "Could not process service request",
                    }
        except Exception as exc:
            logger.error(f"Error processing service request: {exc}")
            return {
                "status": "error",
                "can_process": False,
                "reason": "Service request processing failed",
            }


def get_service_auth_client() -> ServiceAuthClient:
    """Get singleton service auth client."""
    return ServiceAuthClient()
