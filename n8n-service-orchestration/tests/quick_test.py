#!/usr/bin/env python3
"""
Quick test script to verify service detection
Run: python quick_test.py
"""
import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent.parent / 'service-registry'))
sys.path.insert(0, str(Path(__file__).parent.parent / 'chatbot-integration'))

from service_matcher import ServiceMatcher
from response_formatter import ResponseFormatter


def test_service_detection():
    """Test service detection with sample messages"""
    matcher = ServiceMatcher()
    
    test_messages = [
        "I want to book an appointment",
        "What times are available?",
        "Show me my profile",
        "I'd like to give you feedback",
        "Can you check my payment status?",
        "How do I cancel my booking?",
        "Tell me about your services",
        "Track my order",
        "Do you have FAQs?",
        "Hello, how are you?"  # Should not match any service
    ]
    
    print("=" * 60)
    print("SERVICE DETECTION TEST")
    print("=" * 60)
    
    for message in test_messages:
        print(f"\n📝 Message: '{message}'")
        
        services = matcher.detect_services(message)
        
        if services:
            print(f"✅ Services detected: {services}")
            
            # Get service names
            for service_id in services:
                service = matcher.get_service_by_id(service_id)
                if service:
                    print(f"   - {service['name']}")
        else:
            print("❌ No services detected")
    
    print("\n" + "=" * 60)


def test_response_formatting():
    """Test response formatting"""
    formatter = ResponseFormatter()
    
    print("\n" + "=" * 60)
    print("RESPONSE FORMATTING TEST")
    print("=" * 60)
    
    # Test booking confirmation
    booking_data = {
        'service_type': 'Haircut',
        'date': '2026-05-15',
        'time': '14:30',
        'booking_id': 'BOOK-54321',
        'duration': 30
    }
    
    print("\n📋 Booking Confirmation:")
    response = formatter.format_response('booking_confirmation', booking_data)
    print(response)
    
    # Test profile card
    profile_data = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1-234-567-8900',
        'created_date': '2024-01-15',
        'status': 'Active'
    }
    
    print("\n📋 Profile Card:")
    response = formatter.format_response('profile_card', profile_data)
    print(response)
    
    print("\n" + "=" * 60)


def test_service_list():
    """Display all available services"""
    matcher = ServiceMatcher()
    
    print("\n" + "=" * 60)
    print("AVAILABLE SERVICES")
    print("=" * 60)
    
    services = matcher.list_all_services()
    
    # Group by category
    categories = {}
    for service in services:
        cat = service['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(service)
    
    for category, services_in_cat in sorted(categories.items()):
        print(f"\n📚 {category.replace('-', ' ').title()}:")
        for service in services_in_cat:
            print(f"  • {service['name']} ({service['id']})")
            print(f"    Keywords: {', '.join(service['keywords'][:3])}")
    
    print("\n" + "=" * 60)


if __name__ == '__main__':
    print("\n🚀 N8N Service Orchestration - Quick Test\n")
    
    try:
        test_service_list()
        test_service_detection()
        test_response_formatting()
        
        print("\n✅ All tests completed!")
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
