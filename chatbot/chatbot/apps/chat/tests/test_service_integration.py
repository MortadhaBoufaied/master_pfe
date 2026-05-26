"""Tests for N8N Service Detection Integration."""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List

import pytest

# Add project root to path
project_root = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(project_root))

# Test cases
TEST_CASES = [
    # Academy Services
    {
        "message": "Show me my player statistics",
        "expected_services": ["get-player-stats"],
        "category": "academy",
        "description": "Get player stats request"
    },
    {
        "message": "What's my performance rating",
        "expected_services": ["get-player-stats"],
        "category": "academy",
        "description": "Alternative player stats phrasing"
    },
    {
        "message": "Tell me about my team",
        "expected_services": ["get-team-info"],
        "category": "academy",
        "description": "Get team information"
    },
    {
        "message": "What matches are coming up",
        "expected_services": ["get-events"],
        "category": "academy",
        "description": "Get upcoming events/matches"
    },
    
    # Appointment Services
    {
        "message": "I want to book a training session",
        "expected_services": ["book-appointment"],
        "category": "appointments",
        "description": "Book appointment"
    },
    {
        "message": "When are slots available",
        "expected_services": ["get-schedule"],
        "category": "schedule",
        "description": "Get available schedule"
    },
    {
        "message": "Cancel my booking",
        "expected_services": ["cancel-appointment"],
        "category": "appointments",
        "description": "Cancel appointment"
    },
    
    # Payment Services
    {
        "message": "What's my fee status",
        "expected_services": ["get-payment-status"],
        "category": "payments",
        "description": "Get payment status"
    },
    {
        "message": "Check my invoice",
        "expected_services": ["get-payment-status"],
        "category": "payments",
        "description": "Get payment invoice"
    },
    
    # User Services
    {
        "message": "Show my profile",
        "expected_services": ["get-user-profile"],
        "category": "user-management",
        "description": "Get user profile"
    },
    
    # Scouting Services
    {
        "message": "I need to submit a scouting report",
        "expected_services": ["submit-scouting-report"],
        "category": "scouting",
        "description": "Submit scouting report"
    },
    
    # Feedback Services
    {
        "message": "I have a complaint about the service",
        "expected_services": ["submit-feedback"],
        "category": "feedback",
        "description": "Submit feedback/complaint"
    },
    
    # Multi-service requests
    {
        "message": "Show me upcoming matches and my stats",
        "expected_services": ["get-events", "get-player-stats"],
        "category": "academy",
        "description": "Multiple academy services"
    },
    {
        "message": "Book me a session and check available times",
        "expected_services": ["book-appointment", "get-schedule"],
        "category": "appointments",
        "description": "Booking with schedule check"
    },
    
    # Intent-based (should NOT trigger service detection)
    {
        "message": "Hello",
        "expected_services": [],
        "category": "intent",
        "description": "Greeting (intent detection, not service)"
    },
    {
        "message": "Thank you!",
        "expected_services": [],
        "category": "intent",
        "description": "Thanks (intent detection, not service)"
    },
    {
        "message": "Goodbye",
        "expected_services": [],
        "category": "intent",
        "description": "Goodbye (intent detection, not service)"
    },
]


def test_service_detection():
    """Test service detection functionality."""
    print("\n" + "="*70)
    print("N8N SERVICE DETECTION TESTS")
    print("="*70 + "\n")
    
    # Import here to avoid issues if dependencies not installed
    try:
        from apps.chat.services.service_detection import get_service_detector
    except ImportError:
        pytest.fail("Could not import service detection module")
    
    detector = get_service_detector()
    
    if not detector.enabled_services:
        pytest.fail(f"No services loaded from registry: {detector.services_path}")
    
    print(f"✓ Loaded {len(detector.enabled_services)} services\n")
    
    # Run tests
    passed = 0
    failed = 0
    
    for i, test in enumerate(TEST_CASES, 1):
        message = test["message"]
        expected = set(test["expected_services"])
        
        detected = detector.detect_services(message, threshold=70.0)
        detected_set = set(detected) if detected else set()
        
        is_pass = detected_set == expected
        status = "✓ PASS" if is_pass else "✗ FAIL"
        
        print(f"{i}. {status}")
        print(f"   Message: \"{message}\"")
        print(f"   Expected: {expected if expected else '(no services)'}")
        print(f"   Detected: {detected_set if detected_set else '(none)'}")
        
        if not is_pass:
            print(f"   Category: {test['category']}")
            print(f"   Description: {test['description']}")
        
        print()
        
        if is_pass:
            passed += 1
        else:
            failed += 1
    
    # Summary
    print("="*70)
    print(f"RESULTS: {passed} passed, {failed} failed out of {len(TEST_CASES)} tests")
    print("="*70 + "\n")

    if failed:
        pytest.fail(f"{failed} service-detection cases failed")


def list_all_services():
    """List all available services."""
    print("\n" + "="*70)
    print("AVAILABLE SERVICES")
    print("="*70 + "\n")
    
    try:
        from apps.chat.services.service_detection import get_service_detector
    except ImportError:
        print("ERROR: Could not import service detection module")
        return
    
    detector = get_service_detector()
    
    # Group by category
    categories = {}
    for service in detector.enabled_services:
        cat = service.get('category', 'uncategorized')
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(service)
    
    for category, services in sorted(categories.items()):
        print(f"\n{category.upper()} SERVICES:")
        print("-" * 70)
        
        for service in services:
            print(f"\n  {service['name']} ({service['id']})")
            print(f"  Description: {service['description']}")
            print(f"  Keywords: {', '.join(service.get('keywords', []))}")
            if service.get('requires_authentication'):
                print(f"  Authentication: REQUIRED")
    
    print("\n" + "="*70 + "\n")


def test_keyword_matching():
    """Test individual keyword matching."""
    print("\n" + "="*70)
    print("KEYWORD MATCHING TESTS")
    print("="*70 + "\n")
    
    try:
        from apps.chat.services.service_detection import get_service_detector
    except ImportError:
        print("ERROR: Could not import service detection module")
        return
    
    detector = get_service_detector()
    
    # Test various keyword phrases
    test_phrases = [
        "player stats",
        "my performance",
        "team members",
        "upcoming match",
        "book training",
        "available times",
        "cancel class",
        "check fees",
        "submit feedback",
        "scouting report",
    ]
    
    for phrase in test_phrases:
        detected = detector.detect_services(phrase, threshold=70.0)
        if detected:
            service = detector.get_service_by_id(detected[0])
            print(f"✓ \"{phrase}\" → {service['name']} (confidence: high)")
        else:
            print(f"✗ \"{phrase}\" → No match")
    
    print("\n" + "="*70 + "\n")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "list":
            list_all_services()
        elif command == "keywords":
            test_keyword_matching()
        else:
            print(f"Unknown command: {command}")
            print("\nUsage:")
            print("  python test_service_integration.py          # Run all tests")
            print("  python test_service_integration.py list     # List all services")
            print("  python test_service_integration.py keywords # Test keywords")
    else:
        passed, failed = test_service_detection()
        sys.exit(0 if failed == 0 else 1)
