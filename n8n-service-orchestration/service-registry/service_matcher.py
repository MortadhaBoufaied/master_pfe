"""
Service Matcher - Detects services from user messages
Uses keyword matching and fuzzy string matching to identify requested services
"""
import json
import re
from typing import List, Dict, Optional
from rapidfuzz import fuzz
from pathlib import Path


MIN_FUZZY_KEYWORD_LENGTH = 8
FUZZY_KEYWORD_THRESHOLD = 80.0
GENERIC_SINGLE_KEYWORDS = {
    "about",
    "booking",
    "information",
    "issue",
    "problem",
    "report",
    "service",
    "status",
    "training",
    "what is",
}


class ServiceMatcher:
    """Matches user messages to registered services"""
    
    def __init__(self, services_file: Optional[str] = None):
        """
        Initialize ServiceMatcher with services registry
        
        Args:
            services_file: Path to services.json (defaults to service-registry/services.json)
        """
        if services_file is None:
            base_dir = Path(__file__).parent
            services_file = base_dir / "services.json"
        
        with open(services_file, 'r', encoding='utf-8') as f:
            self.registry = json.load(f)
        
        self.services = self.registry.get('services', [])
        self.enabled_services = [s for s in self.services if s.get('enabled', True)]
    
    def match_services(self, message: str, threshold: float = 70.0) -> List[Dict]:
        """
        Match message to services using keyword and fuzzy matching
        
        Args:
            message: User message
            threshold: Fuzzy matching threshold (0-100)
        
        Returns:
            List of matched services with confidence scores
        """
        matches = []
        message_lower = message.lower()
        
        for service in self.enabled_services:
            confidence = self._calculate_confidence(message_lower, service)
            
            if confidence >= threshold:
                matches.append({
                    'service_id': service['id'],
                    'service_name': service['name'],
                    'category': service['category'],
                    'confidence': confidence,
                    'keywords_matched': self._get_matched_keywords(message_lower, service)
                })
        
        # Sort by confidence descending
        matches.sort(key=lambda x: x['confidence'], reverse=True)
        return matches
    
    def detect_services(self, message: str) -> Optional[List[str]]:
        """
        Detect service IDs from message
        
        Args:
            message: User message
        
        Returns:
            List of service IDs or None if no services matched
        """
        matches = self.match_services(message, threshold=70.0)
        
        if not matches:
            return None
        
        # Return top 3 matches (user can ask for multiple services)
        return [m['service_id'] for m in matches[:3]]
    
    def get_service_by_id(self, service_id: str) -> Optional[Dict]:
        """Get service definition by ID"""
        for service in self.services:
            if service['id'] == service_id:
                return service
        return None
    
    def _calculate_confidence(self, message: str, service: Dict) -> float:
        """Calculate confidence score for a service"""
        keywords = service.get('keywords', [])
        max_score = 0
        
        # Exact keyword matching with high weight
        for keyword in keywords:
            keyword_lower = keyword.lower()
            keyword_score = self._keyword_score(message, keyword_lower)
            if keyword_score:
                max_score = max(max_score, keyword_score)
            elif len(keyword_lower) >= MIN_FUZZY_KEYWORD_LENGTH and keyword_lower not in GENERIC_SINGLE_KEYWORDS:
                ratio = fuzz.token_set_ratio(keyword_lower, message)
                if ratio >= FUZZY_KEYWORD_THRESHOLD:
                    max_score = max(max_score, float(ratio))
        
        # Also check against service name
        name_ratio = fuzz.partial_token_set_ratio(service['name'].lower(), message)
        max_score = max(max_score, float(name_ratio) * 0.6)
        
        return max_score

    def _keyword_score(self, message: str, keyword: str) -> float:
        """Score exact keyword hits while suppressing overly generic single terms."""
        if not self._keyword_matches(message, keyword):
            return 0.0

        if " " in keyword:
            return 110.0
        if keyword in GENERIC_SINGLE_KEYWORDS:
            return 60.0
        return 100.0
    
    def _get_matched_keywords(self, message: str, service: Dict) -> List[str]:
        """Get list of matched keywords"""
        matched = []
        for keyword in service.get('keywords', []):
            if self._keyword_matches(message, keyword.lower()):
                matched.append(keyword)
        return matched

    def _keyword_matches(self, message: str, keyword: str) -> bool:
        """Return true when a keyword appears as words, not as a loose fuzzy hit."""
        return re.search(rf"(?<!\w){re.escape(keyword)}(?!\w)", message) is not None
    
    def extract_parameters(self, message: str, service_id: str) -> Dict:
        """
        Extract parameters from message for a specific service
        
        Args:
            message: User message
            service_id: Service ID
        
        Returns:
            Dictionary of extracted parameters
        """
        service = self.get_service_by_id(service_id)
        if not service:
            return {}
        
        parameters = {}
        service_params = service.get('parameters', {})
        message_lower = message.lower()
        
        # Simple parameter extraction logic
        # In production, use NER (Named Entity Recognition) or LLM
        for param_name, param_info in service_params.items():
            if param_info.get('required', False):
                # Try to extract from message
                extracted = self._extract_parameter_value(message, param_name, param_info)
                if extracted:
                    parameters[param_name] = extracted
        
        return parameters
    
    def _extract_parameter_value(self, message: str, param_name: str, param_info: Dict) -> Optional[str]:
        """
        Extract parameter value from message
        
        This is a basic implementation. For production, use:
        - Named Entity Recognition (spaCy, transformers)
        - Regular expressions for specific formats (dates, times)
        - LLM-based extraction
        """
        param_type = param_info.get('type', 'string')
        
        # Date parameter extraction
        if param_name == 'date' or param_type == 'date':
            # Look for common date patterns
            date_patterns = ['today', 'tomorrow', '2026', '2025']
            for pattern in date_patterns:
                if pattern in message.lower():
                    return pattern
        
        # Time parameter extraction
        if param_name == 'time' or param_type == 'time':
            # Look for time patterns (HH:mm)
            import re
            time_match = re.search(r'\b([01]?[0-9]|2[0-3]):[0-5][0-9]\b', message)
            if time_match:
                return time_match.group()
        
        # Service type extraction
        if param_name == 'service_type':
            # Could extract from context
            pass
        
        return None
    
    def validate_parameters(self, service_id: str, parameters: Dict) -> tuple[bool, Optional[str]]:
        """
        Validate parameters for a service
        
        Returns:
            Tuple of (is_valid, error_message)
        """
        service = self.get_service_by_id(service_id)
        if not service:
            return False, f"Service '{service_id}' not found"
        
        service_params = service.get('parameters', {})
        
        for param_name, param_info in service_params.items():
            if param_info.get('required', False) and param_name not in parameters:
                return False, f"Missing required parameter: {param_name}"
            
            if param_name in parameters:
                param_value = parameters[param_name]
                
                # Validate type
                param_type = param_info.get('type', 'string')
                if not self._validate_type(param_value, param_type):
                    return False, f"Invalid type for parameter {param_name}: expected {param_type}"
                
                # Validate constraints
                if param_type == 'string':
                    max_length = param_info.get('max_length')
                    if max_length and len(param_value) > max_length:
                        return False, f"Parameter {param_name} exceeds max length {max_length}"
                
                elif param_type == 'integer':
                    min_val = param_info.get('min')
                    max_val = param_info.get('max')
                    if isinstance(param_value, int):
                        if min_val is not None and param_value < min_val:
                            return False, f"Parameter {param_name} must be >= {min_val}"
                        if max_val is not None and param_value > max_val:
                            return False, f"Parameter {param_name} must be <= {max_val}"
        
        return True, None
    
    def _validate_type(self, value: any, expected_type: str) -> bool:
        """Validate value type"""
        type_map = {
            'string': str,
            'integer': int,
            'float': float,
            'boolean': bool,
            'array': list,
            'object': dict,
        }
        
        expected_python_type = type_map.get(expected_type)
        if expected_python_type:
            return isinstance(value, expected_python_type)
        
        return True
    
    def list_all_services(self) -> List[Dict]:
        """List all available services with basic info"""
        return [
            {
                'id': s['id'],
                'name': s['name'],
                'description': s['description'],
                'category': s['category'],
                'keywords': s['keywords']
            }
            for s in self.enabled_services
        ]
    
    def get_services_by_category(self, category: str) -> List[Dict]:
        """Get all services in a category"""
        return [s for s in self.enabled_services if s.get('category') == category]


# Singleton instance
_matcher_instance = None

def get_service_matcher() -> ServiceMatcher:
    """Get or create singleton ServiceMatcher instance"""
    global _matcher_instance
    if _matcher_instance is None:
        _matcher_instance = ServiceMatcher()
    return _matcher_instance
