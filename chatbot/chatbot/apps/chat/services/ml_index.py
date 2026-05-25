"""ML-based semantic search using TF-IDF + fuzzy matching."""

import os
import re
import logging
import pandas as pd
from dataclasses import dataclass
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from rapidfuzz import process as rf_process

logger = logging.getLogger('ml_index')


@dataclass
class Hit:
    """Result from ML index query."""
    answer: str
    score: float
    category: str = ''
    source: str = ''
    question: str = ''

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            'answer': self.answer,
            'score': self.score,
            'category': self.category,
            'source': self.source,
            'question': self.question,
        }


def _normalize(text: str) -> str:
    """
    Normalize text for matching.
    
    - Convert to lowercase
    - Remove extra whitespace
    - Strip leading/trailing whitespace
    """
    if not text:
        return ''
    text = (text or '').lower().strip()
    text = re.sub(r"\s+", " ", text)
    return text


class MLIndex:
    """
    ML-based semantic search index over a CSV dataset.
    
    Uses three-tier matching strategy:
    1. Exact match (normalized)
    2. Fuzzy match (rapidfuzz)
    3. TF-IDF cosine similarity
    
    Loaded lazily on first query.
    """

    def __init__(self, csv_path: str):
        """
        Initialize ML index.
        
        Args:
            csv_path: Path to CSV file with columns: Question, Answer, Category, Source
        """
        self.csv_path = csv_path
        self.df = None
        self.vectorizer = None
        self.matrix = None
        self.exact = {}
        self.keys = []
        self._load_attempted = False
        self._load_error = None

    def load(self) -> bool:
        """
        Load CSV and build ML index.
        
        Returns:
            True if successful, False if error
        """
        if self.df is not None:
            return True
        
        if self._load_attempted and self._load_error:
            logger.error(f"Previous load error: {self._load_error}")
            return False
        
        try:
            self._load_attempted = True
            
            # Validate file exists
            if not os.path.isfile(self.csv_path):
                raise FileNotFoundError(f"QA CSV not found: {self.csv_path}")
            
            logger.info(f"Loading QA data from {self.csv_path}")
            
            # Load CSV
            df = pd.read_csv(self.csv_path, sep=';', engine='python')
            
            # Validate columns
            df.columns = [c.strip() for c in df.columns]
            required_cols = {'Question', 'Answer', 'Category', 'Source'}
            missing = required_cols - set(df.columns)
            if missing:
                raise ValueError(f"Missing columns: {missing}")
            
            # Convert to string type and remove nulls
            for col in required_cols:
                df[col] = df[col].astype(str)
            
            # Add normalized column
            df['q_norm'] = df['Question'].map(_normalize)
            
            # Remove empty rows
            initial_count = len(df)
            df = df[df['q_norm'].str.len() > 0]
            removed = initial_count - len(df)
            if removed > 0:
                logger.warning(f"Removed {removed} rows with empty questions")
            
            # Check for duplicates
            duplicates = df['q_norm'].duplicated().sum()
            if duplicates > 0:
                logger.warning(f"Found {duplicates} duplicate questions")
                df = df.drop_duplicates(subset=['q_norm'], keep='first')
            
            self.df = df.reset_index(drop=True)
            
            # Build exact match map
            self.exact = {q: i for i, q in enumerate(self.df['q_norm'].tolist())}
            self.keys = list(self.exact.keys())
            
            # Build TF-IDF matrix
            self.vectorizer = TfidfVectorizer(ngram_range=(1, 2), lowercase=True, max_features=500)
            self.matrix = self.vectorizer.fit_transform(self.df['q_norm'].tolist())
            
            logger.info(f"ML index loaded: {len(self.df)} questions, {len(self.vectorizer.get_feature_names_out())} features")
            return True
        
        except Exception as e:
            self._load_error = str(e)
            logger.error(f"Failed to load ML index: {e}", exc_info=True)
            return False

    def query(self, text: str, min_sim: float = 0.18, fuzzy_min: int = 90) -> Hit | None:
        """
        Query the ML index for matching Q&A entries.
        
        Args:
            text: User question to search
            min_sim: Minimum TF-IDF similarity score (0.0-1.0), default 0.18
            fuzzy_min: Minimum fuzzy matching score (0-100), default 90
        
        Returns:
            Hit object with matching answer, or None if no match found
            
        Process:
            1. Exact match on normalized questions
            2. Fuzzy match if no exact match
            3. TF-IDF cosine similarity if fuzzy fails
        """
        if not self.load():
            logger.error("Cannot query: ML index not loaded")
            return None
        
        q = _normalize(text)
        if not q:
            logger.debug("Empty normalized query")
            return None
        
        try:
            # 1. Exact match
            if q in self.exact:
                i = self.exact[q]
                row = self.df.iloc[i]
                logger.debug(f"Exact match found: {row['Question'][:50]}...")
                return Hit(
                    answer=row['Answer'],
                    score=1.0,
                    category=row['Category'],
                    source=row['Source'],
                    question=row['Question']
                )
            
            # 2. Fuzzy match
            if self.keys:
                match = rf_process.extractOne(q, self.keys, score_cutoff=fuzzy_min)
                if match:
                    best_key, score, _ = match
                    i = self.exact[best_key]
                    row = self.df.iloc[i]
                    fuzzy_score = float(score) / 100.0
                    logger.debug(f"Fuzzy match found: {row['Question'][:50]}... (score={fuzzy_score:.2f})")
                    return Hit(
                        answer=row['Answer'],
                        score=fuzzy_score,
                        category=row['Category'],
                        source=row['Source'],
                        question=row['Question']
                    )
            
            # 3. TF-IDF
            v = self.vectorizer.transform([q])
            sims = cosine_similarity(v, self.matrix).ravel()
            best_i = int(sims.argmax())
            best_score = float(sims[best_i])
            
            if best_score < min_sim:
                logger.debug(f"No TF-IDF match above threshold: {best_score:.4f} < {min_sim}")
                return None
            
            row = self.df.iloc[best_i]
            logger.debug(f"TF-IDF match found: {row['Question'][:50]}... (score={best_score:.4f})")
            return Hit(
                answer=row['Answer'],
                score=best_score,
                category=row['Category'],
                source=row['Source'],
                question=row['Question']
            )
        
        except Exception as e:
            logger.error(f"Error during query: {e}", exc_info=True)
            return None
