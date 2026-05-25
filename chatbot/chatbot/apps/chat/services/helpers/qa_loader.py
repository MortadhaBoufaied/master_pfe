import os
import pandas as pd

class QALoader:
    def __init__(self, csv_path: str):
        self.csv_path = csv_path

    def load(self):
        os.makedirs(os.path.dirname(self.csv_path), exist_ok=True)
        if not os.path.isfile(self.csv_path):
            with open(self.csv_path, 'w', encoding='utf-8') as f:
                f.write('Question;Answer')
                f.write('What is your name?;My name is Wise Bear.')

        df = pd.read_csv(self.csv_path, sep=';')
        df = df[df['Question'].apply(lambda x: isinstance(x, str))]
        df = df[df['Answer'].apply(lambda x: isinstance(x, str))]
        questions = df['Question'].tolist()
        answers = df['Answer'].tolist()
        exact = {q.lower().strip().rstrip('?!'): a for q, a in zip(questions, answers)}
        return questions, answers, exact
