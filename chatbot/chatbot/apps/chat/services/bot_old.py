from django.conf import settings
from apps.chat.services.intent import detect_intent
from apps.chat.services import predefined
from apps.chat.services.ml_index import MLIndex

class Chatbot:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init()
        return cls._instance

    def _init(self):
        self.index = MLIndex(settings.QA_CSV)

    async def respond(self, message: str):
        intent = detect_intent(message)
        pre = await predefined.get_predefined(intent)
        if pre:
            return {'response': pre, 'score': 1.0, 'category': 'intent', 'source': intent}

        hit = self.index.query(message, min_sim=settings.MIN_SIM, fuzzy_min=settings.FUZZY_MIN)
        if hit:
            return {
                'response': hit.answer,
                'score': round(hit.score, 4),
                'category': hit.category,
                'source': hit.source,
                'matched_question': hit.question,
            }

        return {
            'response': "No confident answer found. Try rephrasing or asking about fees, schedule, registration, policies, contact.",
            'score': 0.0,
            'category': '',
            'source': '',
        }
