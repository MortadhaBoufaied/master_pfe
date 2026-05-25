"""Core chatbot service with multi-tier response strategy."""

import logging
import time
from typing import Dict, Any
from django.conf import settings
from apps.chat.services.intent import detect_intent
from apps.chat.services import predefined
from apps.chat.services.ml_index import MLIndex
from apps.chat.services.monitoring import MetricsCollector, QueryMetrics
from apps.chat.services.service_detection import get_service_detector

logger = logging.getLogger('chatbot')


class Chatbot:
    """
    Singleton chatbot service.
    
    Uses multi-tier response strategy:
    1. Intent detection for greetings, thanks, etc.
    2. Predefined responses from database
    3. ML-based semantic search over QA dataset
    4. Default fallback message
    """
    _instance = None

    def __new__(cls):
        """Implement singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init()
        return cls._instance

    def _init(self):
        """Initialize chatbot with ML index and service detector."""
        self.index = MLIndex(settings.QA_CSV)
        self.service_detector = get_service_detector()
        logger.info("Chatbot initialized with service detection enabled")

    async def respond(self, message: str) -> Dict[str, Any]:
        """
        Generate a response to user message.
        
        Uses multi-tier strategy:
        1. Detect intent (greeting, goodbye, etc.)
        2. Check predefined responses
        3. Detect service requests (n8n services)
        4. Query ML index (exact/fuzzy/TF-IDF)
        5. Return fallback message
        
        Args:
            message: User input message
            
        Returns:
            Dict with keys: response, score, category, source, matched_question, services (optional)
        """
        start_time = time.time()
        
        try:
            logger.debug(f"Processing message: {message[:50] if message else 'empty'}...")
            
            # 1. Intent detection
            intent = detect_intent(message)
            logger.debug(f"Detected intent: {intent}")
            
            pre = await predefined.get_predefined(intent)
            if pre:
                response_time = (time.time() - start_time) * 1000
                logger.info(f"Intent response returned in {response_time:.2f}ms")
                
                # Record metrics
                MetricsCollector.record_query(QueryMetrics(
                    message=message,
                    response_score=1.0,
                    category='intent',
                    source=intent,
                    processing_time_ms=response_time,
                    matched=True,
                ))
                
                return {
                    'response': pre,
                    'score': 1.0,
                    'category': 'intent',
                    'source': intent,
                    'matched_question': None,
                }
            
            # 2. Service detection (n8n services)
            detected_services = self.service_detector.detect_services(message, threshold=70.0)
            if detected_services:
                response_time = (time.time() - start_time) * 1000
                logger.info(f"Services detected in {response_time:.2f}ms: {detected_services}")
                
                # Record metrics
                MetricsCollector.record_query(QueryMetrics(
                    message=message,
                    response_score=0.85,
                    category='service_detection',
                    source=','.join(detected_services),
                    processing_time_ms=response_time,
                    matched=True,
                ))
                
                # Format service information
                services_info = []
                for service_id in detected_services:
                    service_info = self.service_detector.get_service_info(service_id)
                    if service_info:
                        services_info.append(service_info)
                
                service_names = ", ".join([s['name'] for s in services_info])
                response_text = f"I can help you with: {service_names}. Let me route your request to the appropriate service..."
                
                return {
                    'response': response_text,
                    'score': 0.85,
                    'category': 'service_detection',
                    'source': 'n8n_services',
                    'matched_question': None,
                    'services': detected_services,
                    'service_details': services_info,
                }
            
            # 3. ML-based search
            hit = self.index.query(
                message,
                min_sim=settings.MIN_SIM,
                fuzzy_min=settings.FUZZY_MIN
            )
            
            if hit:
                response_time = (time.time() - start_time) * 1000
                logger.info(f"ML match returned in {response_time:.2f}ms (score={hit.score:.4f})")
                
                # Record metrics
                MetricsCollector.record_query(QueryMetrics(
                    message=message,
                    response_score=hit.score,
                    category=hit.category,
                    source=hit.source,
                    processing_time_ms=response_time,
                    matched=True,
                ))
                
                return {
                    'response': hit.answer,
                    'score': round(hit.score, 4),
                    'category': hit.category,
                    'source': hit.source,
                    'matched_question': hit.question,
                }
            
            # 3. Fallback response
            response_time = (time.time() - start_time) * 1000
            logger.warning(f"No confident match found for: {message[:50] if message else 'empty'}...")
            
            # Record metrics
            MetricsCollector.record_query(QueryMetrics(
                message=message,
                response_score=0.0,
                category='fallback',
                source='default',
                processing_time_ms=response_time,
                matched=False,
            ))
            
            fallback_msg = (
                "I couldn't find a confident answer to your question. "
                "Try rephrasing or ask about: player stats, team info, bookings, payments, schedules, "
                "registrations, fees, policies, or contact information."
            )
            
            return {
                'response': fallback_msg,
                'score': 0.0,
                'category': 'fallback',
                'source': 'default',
                'matched_question': None,
            }
        
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            logger.error(f"Error in respond(): {e}", exc_info=True)
            
            # Record error
            MetricsCollector.record_error('respond_error', str(e), {'message': message[:50] if message else 'empty'})
            
            return {
                'response': "An error occurred processing your request. Please try again.",
                'score': 0.0,
                'category': 'error',
                'source': 'error_handler',
                'matched_question': None,
            }
