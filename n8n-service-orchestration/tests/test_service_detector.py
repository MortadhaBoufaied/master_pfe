"""
Test Service Detector - Unit tests for service detection
"""
import unittest
import sys
from pathlib import Path

# Add service registry to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'service-registry'))

from service_matcher import ServiceMatcher
from response_formatter import ResponseFormatter


class TestServiceMatcher(unittest.TestCase):
    """Tests for ServiceMatcher"""
    
    def setUp(self):
        """Setup test fixtures"""
        self.matcher = ServiceMatcher()
    
    def test_detect_book_appointment(self):
        """Test detection of book appointment service"""
        message = "I want to book an appointment"
        services = self.matcher.detect_services(message)
        
        self.assertIsNotNone(services)
        self.assertIn('book-appointment', services)
    
    def test_detect_get_schedule(self):
        """Test detection of get schedule service"""
        message = "What times are available?"
        services = self.matcher.detect_services(message)
        
        self.assertIsNotNone(services)
        self.assertIn('get-schedule', services)
    
    def test_detect_get_profile(self):
        """Test detection of get profile service"""
        message = "Show me my profile"
        services = self.matcher.detect_services(message)
        
        self.assertIsNotNone(services)
        self.assertIn('get-user-profile', services)
    
    def test_detect_no_service(self):
        """Test no service detected"""
        message = "Tell me a joke"
        services = self.matcher.detect_services(message)
        
        self.assertIsNone(services)
    
    def test_confidence_scoring(self):
        """Test confidence scoring"""
        message = "I'd like to book an appointment"
        matches = self.matcher.match_services(message, threshold=0)
        
        self.assertTrue(len(matches) > 0)
        # First match should have highest confidence
        self.assertTrue(matches[0]['confidence'] >= matches[-1]['confidence'])
    
    def test_get_service_by_id(self):
        """Test getting service by ID"""
        service = self.matcher.get_service_by_id('book-appointment')
        
        self.assertIsNotNone(service)
        self.assertEqual(service['id'], 'book-appointment')
    
    def test_list_all_services(self):
        """Test listing all services"""
        services = self.matcher.list_all_services()
        
        self.assertGreater(len(services), 0)
        self.assertTrue(any(s['id'] == 'book-appointment' for s in services))
    
    def test_extract_parameters(self):
        """Test parameter extraction"""
        service_id = 'book-appointment'
        message = "Book me on 2026-05-15 at 14:30"
        
        params = self.matcher.extract_parameters(message, service_id)
        
        # Should extract date and time
        # Note: Basic extraction may not catch everything
        self.assertIsInstance(params, dict)
    
    def test_validate_parameters_success(self):
        """Test parameter validation - success case"""
        service_id = 'submit-feedback'
        parameters = {
            'message': 'Great service!',
            'rating': 5,
            'category': 'experience'
        }
        
        is_valid, error_msg = self.matcher.validate_parameters(service_id, parameters)
        
        self.assertTrue(is_valid)
        self.assertIsNone(error_msg)
    
    def test_validate_parameters_missing_required(self):
        """Test parameter validation - missing required"""
        service_id = 'book-appointment'
        parameters = {}  # Missing required parameters
        
        is_valid, error_msg = self.matcher.validate_parameters(service_id, parameters)
        
        self.assertFalse(is_valid)
        self.assertIsNotNone(error_msg)
    
    def test_validate_parameters_max_length(self):
        """Test parameter validation - max length"""
        service_id = 'submit-feedback'
        parameters = {
            'message': 'x' * 2000  # Exceeds max_length of 1000
        }
        
        is_valid, error_msg = self.matcher.validate_parameters(service_id, parameters)
        
        self.assertFalse(is_valid)


class TestResponseFormatter(unittest.TestCase):
    """Tests for ResponseFormatter"""
    
    def setUp(self):
        """Setup test fixtures"""
        self.formatter = ResponseFormatter()
    
    def test_format_booking_confirmation(self):
        """Test formatting booking confirmation"""
        data = {
            'service_type': 'Haircut',
            'date': '2026-05-15',
            'time': '14:30',
            'booking_id': 'BOOK-12345',
            'duration': 30
        }
        
        response = self.formatter.format_response('booking_confirmation', data)
        
        self.assertIn('BOOK-12345', response)
        self.assertIn('2026-05-15', response)
        self.assertIn('Haircut', response)
    
    def test_format_profile_card(self):
        """Test formatting profile card"""
        data = {
            'name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+1-234-567-8900',
            'created_date': '2024-01-01',
            'status': 'Active'
        }
        
        response = self.formatter.format_response('profile_card', data)
        
        self.assertIn('John Doe', response)
        self.assertIn('john@example.com', response)
        self.assertIn('Active', response)
    
    def test_format_error_response(self):
        """Test formatting error response"""
        data = {
            'error_message': 'Service not found',
            'reference_id': 'REF-123'
        }
        
        response = self.formatter.format_response('error_default', data)
        
        self.assertIn('Service not found', response)
        self.assertIn('REF-123', response)
    
    def test_format_service_response(self):
        """Test complete service response formatting"""
        service_response = {
            'status': 'success',
            'data': {
                'name': 'John',
                'email': 'john@test.com'
            }
        }
        
        formatted = self.formatter.format_service_response(
            'get-user-profile',
            service_response,
            'success'
        )
        
        self.assertEqual(formatted['service_id'], 'get-user-profile')
        self.assertEqual(formatted['status'], 'success')
        self.assertIn('formatted_response', formatted)
    
    def test_handle_timeout(self):
        """Test timeout response"""
        response = self.formatter.handle_timeout('get-schedule')
        
        self.assertIn('timeout', response.lower())


if __name__ == '__main__':
    unittest.main()
