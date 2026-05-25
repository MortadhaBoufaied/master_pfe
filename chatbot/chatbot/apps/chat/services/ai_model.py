import os
from apps.chat.services.helpers.ClassifierHelper import ClassifierHelper
from apps.chat.services.helpers.GetPredefinedResponse import ResponseHelper
from apps.chat.services.helpers.TranslationHelper import TranslationHelper
from apps.chat.services.helpers.GetBestAnser import QARetriever
from apps.chat.services.helpers.MarkdownDecisionEngine import MarkdownDecisionEngine
from apps.chat.services.helpers.qa_loader import QALoader

SIMILARITY_THRESHOLD = 0.65

class Chatbot:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init()
        return cls._instance

    def _init(self):
        self.trans_helper = TranslationHelper()
        self.class_helper = ClassifierHelper()
        self.resp_helper = ResponseHelper()
        self.markdown = MarkdownDecisionEngine()

        qa_csv = os.getenv('QA_CSV', 'apps/chat/training_models/data/data2.csv')
        q, a, exact = QALoader(qa_csv).load()
        self.qa = QARetriever(q, a, exact)

    async def generate_response(self, prompt: str) -> str:
        user_lang = self.trans_helper.detect_language(prompt)
        input_text = self.trans_helper.translate(prompt, target_lang='en', source_lang=user_lang)

        intent, _ = await self.class_helper.classify_intent_and_extract_entities(input_text)
        pre = await self.resp_helper.get_predefined_response(intent)
        if pre:
            return self.trans_helper.translate(self.markdown.format_text(pre), target_lang=user_lang, source_lang='en')

        best = self.qa.get_best_answer(input_text)
        if best:
            ans, score = best[0]
            if score >= SIMILARITY_THRESHOLD:
                return self.trans_helper.translate(self.markdown.format_text(ans), target_lang=user_lang, source_lang='en')

        return self.trans_helper.translate('No confident answer found.', target_lang=user_lang, source_lang='en')
