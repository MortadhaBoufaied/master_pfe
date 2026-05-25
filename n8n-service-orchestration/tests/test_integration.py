"""
Integration tests for chatbot + n8n
"""
import unittest
import sys
from pathlib import Path
import json

sys.path.insert(0, str(Path(__file__).parent.parent / 'service-registry'))
sys.path.insert(0, str(Path(__file__).parent.parent / 'chatbot-integration'))

from service_matcher import ServiceMatcher
from response_formatter import ResponseFormatter


class TestChatbotIntegration(unittest.TestCase):
    """Integration tests"""
    
    def setUp(self):
        """Setup test fixtures"""
        self.matcher = ServiceMatcher()
        self.formatter = ResponseFormatter()
    
    def test_full_booking_flow(self):
        """Test complete booking flow"""
        # Simulate user message
        message = "Can I book an appointment on Monday at 2pm?"
        
        # Detect service
        services = self.matcher.detect_services(message)
        self.assertIsNotNone(services)
        self.assertIn('book-appointment', services)
        
        # Extract parameters
        params = self.matcher.extract_parameters(message, 'book-appointment')
        print(f"Extracted parameters: {params}")
    
    def test_multiple_services_detection(self):
        """Test detecting multiple services"""
        message = "Show me my profile and available appointments"
        
        services = self.matcher.detect_services(message)
        self.assertIsNotNone(services)
        self.assertGreaterEqual(len(services), 1)
    
    def test_service_registry_loaded(self):
        """Test that service registry loads correctly"""
        services = self.matcher.list_all_services()
        
        self.assertGreater(len(services), 0)
        # Check critical services exist
        service_ids = [s['id'] for s in services]
        self.assertIn('book-appointment', service_ids)
        self.assertIn('get-schedule', service_ids)
        self.assertIn('get-user-profile', service_ids)
    
    def test_response_templates_loaded(self):
        """Test that response templates load correctly"""
        templates = self.formatter.templates
        
        self.assertGreater(len(templates), 0)
        # Check critical templates exist
        self.assertIn('booking_confirmation', templates)
        self.assertIn('profile_card', templates)
        self.assertIn('schedule_list', templates)


if __name__ == '__main__':
    unittest.main()
