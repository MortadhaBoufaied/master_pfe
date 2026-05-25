import torch

class MarkdownsRegistry:
    """
    Singleton registry for Markdown-related models and components
    """
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._registry = {}
            # Set device information
            cls._instance.device = "cuda" if torch.cuda.is_available() else "cpu"
            cls._instance.pipeline_device = 0 if cls._instance.device == "cuda" else -1
        return cls._instance

    def register_component(self, key, component):
        """Register a single component by key"""
        self._registry[key] = component

    def get(self, key):
        """Get a registered component by key"""
        return self._registry.get(key)

    @property
    def embedder(self):
        return self.get('embedder')

    @property
    def format_classifier_pipeline(self):
        return self.get('format_classifier_pipeline')

    @property
    def ner_pipeline(self):
        return self.get('ner_pipeline')

    @property
    def syntax_model(self):
        return self.get('syntax_model')

    @property
    def syntax_tokenizer(self):
        return self.get('syntax_tokenizer')

    @property
    def nlp_pipeline(self):
        return self.get('nlp_pipeline')

    @property
    def lang_classifier(self):
        return self.get('lang_classifier')

    @property
    def keyphrase_model(self):
        return self.get('keyphrase_model')
    
