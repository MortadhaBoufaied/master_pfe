"""
Response Formatter - Formats service responses using templates
"""
import json
from typing import Dict, Optional, Any
from pathlib import Path
import re


class ResponseFormatter:
    """Formats service responses using predefined templates"""
    
    def __init__(self, templates_file: Optional[str] = None):
        """
        Initialize ResponseFormatter with templates
        
        Args:
            templates_file: Path to response-templates.json
        """
        if templates_file is None:
            base_dir = Path(__file__).parent
            templates_file = base_dir / "response-templates.json"
        
        with open(templates_file, 'r', encoding='utf-8') as f:
            self.templates_data = json.load(f)
        
        self.templates = self.templates_data.get('response_templates', {})
    
    def format_response(self, template_name: str, data: Dict[str, Any]) -> str:
        """
        Format response using template with data substitution
        
        Args:
            template_name: Name of the template
            data: Dictionary of data to substitute in template
        
        Returns:
            Formatted response string
        """
        if template_name not in self.templates:
            return self._get_fallback_response(template_name)
        
        template_info = self.templates[template_name]
        template_text = template_info.get('template', '')
        fallback = template_info.get('fallback', 'No response available')
        
        try:
            # Replace template variables
            formatted = self._substitute_variables(template_text, data)
            return formatted
        except Exception as e:
            print(f"Error formatting response: {e}")
            return fallback
    
    def format_service_response(self, service_id: str, response_data: Dict[str, Any], 
                               status: str = 'success') -> Dict[str, Any]:
        """
        Format a complete service response with metadata
        
        Args:
            service_id: Service ID
            response_data: Response data from service
            status: 'success' or 'error'
        
        Returns:
            Formatted response dictionary
        """
        # Determine template based on response structure and status
        template_name = self._select_template(service_id, status)
        
        # Merge response data with metadata
        format_data = {
            'service_id': service_id,
            'status': status,
            **response_data
        }
        
        # Get formatted message
        formatted_message = self.format_response(template_name, format_data)
        
        return {
            'service_id': service_id,
            'status': status,
            'formatted_response': formatted_message,
            'template_used': template_name,
            'data': response_data,
            'timestamp': self._get_timestamp()
        }
    
    def format_multiple_services_response(self, services_responses: list) -> str:
        """
        Format multiple service responses into one message
        
        Args:
            services_responses: List of formatted service responses
        
        Returns:
            Combined formatted message
        """
        results_text = ""
        overall_status = "success"
        total_time = 0
        
        for i, response in enumerate(services_responses, 1):
            status = response.get('status', 'unknown')
            message = response.get('formatted_response', '')
            service_id = response.get('service_id', '')
            
            if status == 'error':
                overall_status = 'partial'
            
            results_text += f"\n**{i}. {service_id.replace('-', ' ').title()}**\n{message}\n"
        
        # Format final response
        template_data = {
            'services_results': results_text,
            'overall_status': overall_status,
            'execution_time_ms': total_time
        }
        
        return self.format_response('multiple_services_response', template_data)
    
    def _select_template(self, service_id: str, status: str = 'success') -> str:
        """Select appropriate template based on service and status"""
        # Map service ID to template name
        template_map = {
            'get-user-profile': 'profile_card',
            'book-appointment': 'booking_confirmation',
            'get-schedule': 'schedule_list',
            'submit-feedback': 'feedback_confirmation',
            'get-payment-status': 'payment_status',
            'cancel-appointment': 'cancellation_confirmation',
            'get-service-details': 'service_details',
            'track-order': 'order_tracking',
            'get-faq': 'faq_list',
        }
        
        if status == 'error':
            # Map to error template
            error_map = {
                'book-appointment': 'booking_error',
                'get-schedule': 'schedule_error',
                'submit-feedback': 'feedback_error',
                'get-payment-status': 'payment_error',
                'cancel-appointment': 'cancellation_error',
                'get-service-details': 'service_not_found',
                'track-order': 'order_not_found',
                'get-faq': 'faq_not_found',
            }
            return error_map.get(service_id, 'error_default')
        
        return template_map.get(service_id, 'error_default')
    
    def _substitute_variables(self, template: str, data: Dict[str, Any]) -> str:
        """
        Substitute {variable} placeholders in template with data
        
        Args:
            template: Template string with {variable} placeholders
            data: Data dictionary
        
        Returns:
            String with substituted variables
        """
        def replace_var(match):
            var_name = match.group(1)
            value = data.get(var_name, f"[{var_name} not provided]")
            
            # Handle None values
            if value is None:
                return "[N/A]"
            
            # Convert lists to formatted text
            if isinstance(value, list):
                if not value:
                    return "[empty]"
                # Check if it's a list of dicts (like slots)
                if value and isinstance(value[0], dict):
                    return self._format_list_of_dicts(value)
                return ", ".join(str(v) for v in value)
            
            # Convert dicts to formatted text
            if isinstance(value, dict):
                return json.dumps(value, indent=2)
            
            return str(value)
        
        # Replace {variable_name} with actual values
        result = re.sub(r'\{(\w+)\}', replace_var, template)
        return result
    
    def _format_list_of_dicts(self, items: list) -> str:
        """Format list of dictionaries as a table or list"""
        if not items:
            return "[empty]"
        
        # Simple markdown table format
        lines = []
        
        # Get keys from first item
        keys = list(items[0].keys())
        
        # Header
        header = " | ".join(keys)
        lines.append(header)
        lines.append(" | ".join(["---" for _ in keys]))
        
        # Rows
        for item in items:
            row = " | ".join(str(item.get(k, "")) for k in keys)
            lines.append(row)
        
        return "\n".join(lines)
    
    def _get_fallback_response(self, template_name: str) -> str:
        """Get fallback response if template not found"""
        if template_name in self.templates:
            return self.templates[template_name].get('fallback', 'No response available')
        return "No response available"
    
    def _get_timestamp(self) -> str:
        """Get current timestamp"""
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).isoformat()
    
    def handle_timeout(self, service_id: str) -> str:
        """Format timeout response"""
        template_data = {
            'reference_id': f"{service_id}-{self._get_timestamp()}"
        }
        return self.format_response('service_timeout', template_data)
    
    def handle_error(self, error_message: str, reference_id: str = "") -> str:
        """Format error response"""
        if not reference_id:
            reference_id = f"ERR-{self._get_timestamp()}"
        
        template_data = {
            'error_message': error_message,
            'reference_id': reference_id
        }
        return self.format_response('error_default', template_data)


# Singleton instance
_formatter_instance = None

def get_response_formatter() -> ResponseFormatter:
    """Get or create singleton ResponseFormatter instance"""
    global _formatter_instance
    if _formatter_instance is None:
        _formatter_instance = ResponseFormatter()
    return _formatter_instance
