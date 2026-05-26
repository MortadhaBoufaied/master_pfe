import logging
import os
import urllib.parse
import urllib.request

import fasttext
from apps.chat.services.model_registry import ModelRegistry

logger = logging.getLogger(__name__)
LID_MODEL_URL = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.ftz"

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
            parsed = urllib.parse.urlparse(LID_MODEL_URL)
            if parsed.scheme != "https":
                raise ValueError("Language identification model must be downloaded over HTTPS")
            try:
                urllib.request.urlretrieve(LID_MODEL_URL, lid_path)  # nosec B310
            except Exception as exc:
                logger.warning("Unable to download language identification model: %s", exc)
        lid=None
        try:
            if os.path.isfile(lid_path):
                lid = fasttext.load_model(lid_path)
        except Exception as exc:
            logger.warning("Unable to load language identification model: %s", exc)
            lid=None
        ModelRegistry.register_components(lid_176_ftz=lid, tokenizer=None, falcon_model=None)
