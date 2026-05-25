import os
import re
import pandas as pd
from dataclasses import dataclass
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from rapidfuzz import process as rf_process

@dataclass
class Hit:
    answer: str
    score: float
    category: str = ''
    source: str = ''
    question: str = ''


def _normalize(text: str) -> str:
    text = (text or '').lower().strip()
    text = re.sub(r"\s+", " ", text)
    return text


class MLIndex:
    """Singleton-ish ML index over data.csv using TF-IDF."""

    def __init__(self, csv_path: str):
        self.csv_path = csv_path
        self.df = None
        self.vectorizer = None
        self.matrix = None
        self.exact = {}
        self.keys = []

    def load(self):
        if self.df is not None:
            return

        if not os.path.isfile(self.csv_path):
            raise FileNotFoundError(f"QA CSV not found: {self.csv_path}")

        df = pd.read_csv(self.csv_path, sep=';', engine='python')
        df.columns = [c.strip() for c in df.columns]
        for col in ['Question','Answer','Category','Source']:
            if col not in df.columns:
                raise ValueError(f"Missing column '{col}' in {self.csv_path}")

        df['Question'] = df['Question'].astype(str)
        df['Answer'] = df['Answer'].astype(str)
        df['Category'] = df['Category'].astype(str)
        df['Source'] = df['Source'].astype(str)

        df['q_norm'] = df['Question'].map(_normalize)
        df = df[df['q_norm'].str.len() > 0]

        self.df = df.reset_index(drop=True)

        # Exact map
        self.exact = {q: i for i, q in enumerate(self.df['q_norm'].tolist())}
        self.keys = list(self.exact.keys())

        # TF-IDF
        self.vectorizer = TfidfVectorizer(ngram_range=(1,2), lowercase=True)
        self.matrix = self.vectorizer.fit_transform(self.df['q_norm'].tolist())

    def query(self, text: str, min_sim: float = 0.18, fuzzy_min: int = 90) -> Hit | None:
        self.load()
        q = _normalize(text)
        if not q:
            return None

        # exact
        if q in self.exact:
            i = self.exact[q]
            row = self.df.iloc[i]
            return Hit(answer=row['Answer'], score=1.0, category=row['Category'], source=row['Source'], question=row['Question'])

        # fuzzy
        if self.keys:
            m = rf_process.extractOne(q, self.keys, score_cutoff=fuzzy_min)
            if m:
                best_key, score, _ = m
                i = self.exact[best_key]
                row = self.df.iloc[i]
                return Hit(answer=row['Answer'], score=float(score)/100.0, category=row['Category'], source=row['Source'], question=row['Question'])

        # tfidf
        v = self.vectorizer.transform([q])
        sims = cosine_similarity(v, self.matrix).ravel()
        best_i = int(sims.argmax())
        best_score = float(sims[best_i])
        if best_score < min_sim:
            return None
        row = self.df.iloc[best_i]
        return Hit(answer=row['Answer'], score=best_score, category=row['Category'], source=row['Source'], question=row['Question'])
