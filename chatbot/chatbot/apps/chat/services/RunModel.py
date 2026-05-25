import os, urllib.request
import fasttext
from apps.chat.services.model_registry import ModelRegistry

class RunModel:
    _instance=None
    def __new__(cls):
        if cls._instance is None:
            cls._instance=super().__new__(cls)
            cls._instance._load()
        return cls._instance

    def _load(self):
        lid_path = os.getenv('LID_MODEL_PATH', 'apps/chat/training_models/models/lid.176.ftz')
        os.makedirs(os.path.dirname(lid_path), exist_ok=True)
        if not os.path.isfile(lid_path):
            try:
                urllib.request.urlretrieve('https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.ftz', lid_path)
            except Exception:
                pass
        lid=None
        try:
            if os.path.isfile(lid_path):
                lid = fasttext.load_model(lid_path)
        except Exception:
            lid=None
        ModelRegistry.register_components(lid_176_ftz=lid, tokenizer=None, falcon_model=None)
