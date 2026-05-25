# Django Chatbot (ML over data.csv) + Local API

Generated: 2025-12-22T02:01:06.647904Z

This project answers user questions using **machine-learning retrieval** (TF‑IDF cosine similarity) over your **data.csv** dataset.

## What it does
- Loads `apps/chat/training_models/data/data.csv` (your dataset) at startup (lazy singleton).
- Uses:
  1) built-in intent rules for greetings/thanks/goodbye
  2) exact match + fuzzy match
  3) ML retrieval: TF‑IDF similarity over dataset questions

## Endpoints
- `GET /` : Web UI
- `POST /` : Web UI backend
- `POST /api/chat` : API endpoint for other projects on same PC

### /api/chat request
```json
{
  "message": "How can I contact you?",
  "sender_id": "optional"
}
```

### /api/chat response
```json
{
  "response": "...",
  "score": 0.42,
  "category": "Support/Contact",
  "source": "Academy Info"
}
```

## Optional API key protection
Set environment variable:
- `CHATBOT_API_KEY=your-secret`

Then send header:
- `X-API-Key: your-secret`

## Run (Windows PowerShell)
```powershell
python -m venv env_py10
.\env_py10\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

## Tuning
- `MIN_SIM` (default 0.18): minimum cosine similarity to accept an answer.
- `FUZZY_MIN` (default 90): minimum fuzzy score (0-100) for fuzzy match.

