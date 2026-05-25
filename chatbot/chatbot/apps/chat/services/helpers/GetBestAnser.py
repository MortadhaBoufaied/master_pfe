from rapidfuzz import process as rf_process

class QARetriever:
    def __init__(self, questions, answers, exact_map):
        self.questions = questions
        self.answers = answers
        self.exact = exact_map
        self.keys = list(self.exact.keys())

    def _norm(self, s: str) -> str:
        return (s or '').lower().strip().rstrip('?!')

    def get_best_answer(self, query: str):
        key = self._norm(query)
        if key in self.exact:
            return [(self.exact[key], 1.0)]
        if self.keys:
            m = rf_process.extractOne(key, self.keys, score_cutoff=85)
            if m:
                best_key, score, _ = m
                return [(self.exact[best_key], float(score)/100.0)]
        return []
