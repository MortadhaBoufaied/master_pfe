"""Service Detection - Detects if user wants to use n8n services."""

import logging
import json
from typing import Dict, List, Optional, Any
from pathlib import Path
from rapidfuzz import fuzz

logger = logging.getLogger('chatbot')


class ServiceDetector:
    """Detects services from user messages."""
    
    def __init__(self, services_registry_path: Optional[str] = None):
        """
        Initialize ServiceDetector with services registry.
        
        Args:
            services_registry_path: Path to services.json (defaults to n8n-service-orchestration/service-registry/services.json)
        """
        if services_registry_path is None:
            # Try to find services.json relative to project root
            base_dir = Path(__file__).parent.parent.parent.parent.parent.parent
            services_registry_path = base_dir / 'n8n-service-orchestration' / 'service-registry' / 'services.json'
        
        self.services_path = services_registry_path
        self.services = []
        self.enabled_services = []
        self._load_services()
    
    def _load_services(self):
        """Load services from registry JSON file."""
        try:
            if not self.services_path.exists():
                logger.warning(f"Services registry not found at {self.services_path}")
                return
            
            with open(self.services_path, 'r', encoding='utf-8') as f:
                registry = json.load(f)
            
            self.services = registry.get('services', [])
            self.enabled_services = [s for s in self.services if s.get('enabled', True)]
            logger.info(f"Loaded {len(self.enabled_services)} enabled services")
        except Exception as e:
            logger.error(f"Error loading services registry: {e}")
            self.services = []
            self.enabled_services = []
    
    def detect_services(self, message: str, threshold: float = 70.0) -> Optional[List[str]]:
        """
        Detect service IDs from user message.
        
        Args:
            message: User message
            threshold: Fuzzy matching threshold (0-100)
        
        Returns:
            List of service IDs or None if no services detected
        """
        if not self.enabled_services:
            return None
        
        matches = []
        message_lower = message.lower()
        
        for service in self.enabled_services:
            confidence = self._calculate_confidence(message_lower, service)
            
            if confidence >= threshold:
                matches.append({
                    'service_id': service['id'],
                    'confidence': confidence,
                })
        
        if not matches:
            return None
        
        # Sort by confidence descending and return top 3 service IDs
        matches.sort(key=lambda x: x['confidence'], reverse=True)
        return [m['service_id'] for m in matches[:3]]
    
    def get_service_by_id(self, service_id: str) -> Optional[Dict]:
        """Get service definition by ID."""
        for service in self.services:
            if service['id'] == service_id:
                return service
        return None
    
    def _calculate_confidence(self, message: str, service: Dict) -> float:
        """Calculate confidence score for a service."""
        keywords = service.get('keywords', [])
        max_score = 0.0
        
        for keyword in keywords:
            keyword_lower = keyword.lower()
            # Exact keyword matching with high weight
            if keyword_lower in message:
                max_score = max(max_score, 100.0)
            else:
                # Fuzzy match using token set ratio
                ratio = fuzz.token_set_ratio(keyword_lower, message)
                max_score = max(max_score, float(ratio))
        
        # Also check against service name
        name_ratio = fuzz.partial_token_set_ratio(service['name'].lower(), message)
        max_score = max(max_score, float(name_ratio) * 0.8)  # Slightly lower weight for name
        
        return max_score
    
    def get_service_info(self, service_id: str) -> Optional[Dict]:
        """Get service information."""
        service = self.get_service_by_id(service_id)
        if not service:
            return None
        
        return {
            'id': service['id'],
            'name': service['name'],
            'description': service['description'],
            'category': service['category'],
            'requires_authentication': service.get('requires_authentication', False),
        }
    
    def list_services_by_category(self, category: str) -> List[Dict]:
        """List services in a specific category."""
        return [
            {
                'id': s['id'],
                'name': s['name'],
                'description': s['description'],
            }
            for s in self.enabled_services
            if s.get('category') == category
        ]


# Singleton instance
_detector_instance = None


def get_service_detector() -> ServiceDetector:
    """Get or create singleton ServiceDetector instance."""
    global _detector_instance
    if _detector_instance is None:
        _detector_instance = ServiceDetector()
    return _detector_instance
