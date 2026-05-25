from deep_translator import GoogleTranslator

class TranslationHelper:
    def detect_language(self, text: str) -> str:
        # Keep simple in this stable build
        return 'en'

    def translate(self, text: str, target_lang: str, source_lang: str='auto') -> str:
        if source_lang == target_lang:
            return text
        try:
            return GoogleTranslator(source=source_lang, target=target_lang).translate(text)
        except Exception:
            return text
