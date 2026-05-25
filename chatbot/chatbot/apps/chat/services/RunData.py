import os
import pandas as pd
from apps.chat.services.data_registry import DataRegistry


class RunData:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._load()
        return cls._instance

    def _load(self):
        qa_csv = os.getenv('QA_CSV', 'apps/chat/training_models/data/data2.csv')
        os.makedirs(os.path.dirname(qa_csv), exist_ok=True)

        if not os.path.isfile(qa_csv):
            with open(qa_csv, 'w', encoding='utf-8') as f:
                f.write('Question;Answer')
                f.write('What is your name?;My name is Wise Bear.')

        df = pd.read_csv(qa_csv, sep=';')
        df = df[df['Question'].apply(lambda x: isinstance(x, str))]
        df = df[df['Answer'].apply(lambda x: isinstance(x, str))]

        qa_q = df['Question'].tolist()
        qa_a = df['Answer'].tolist()

        exact = {q.lower().strip().rstrip('?!'): a for q, a in zip(qa_q, qa_a)}

        DataRegistry.register_components(qa_q=qa_q, qa_a=qa_a, exact=exact)
