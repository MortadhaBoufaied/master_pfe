class SiteIndexer:
    def __init__(self, query_text):
        self.query_text=query_text
    def index_with_progress(self):
        yield "FOUND:0"
        yield "RESULT:NO_RESULT"
