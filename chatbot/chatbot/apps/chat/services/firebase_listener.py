import asyncio
import csv
import os

import firebase_admin
from firebase_admin import credentials, db
from django.conf import settings

from apps.chat.services.ai_model import Chatbot


class FirebaseListener:
    def __init__(self):
        if not settings.ENABLE_FIREBASE_LISTENER:
            raise RuntimeError('Firebase listener disabled (set ENABLE_FIREBASE_LISTENER=1).')

        cred_path = settings.FIREBASE_CREDENTIALS
        if not cred_path:
            raise RuntimeError('FIREBASE_CREDENTIALS not set (path to service account json).')
        if not os.path.exists(cred_path):
            raise RuntimeError(f'Credentials file not found: {cred_path}')
        if not settings.FIREBASE_DB_URL:
            raise RuntimeError('FIREBASE_DB_URL not set.')

        cred = credentials.Certificate(cred_path)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred, {'databaseURL': settings.FIREBASE_DB_URL})

        self.chat_ref = db.reference('chat')
        self.feedback_ref = db.reference('feedback')
        self.chatbot = Chatbot()

        self.csv_path = os.getenv('FEEDBACK_CSV', 'apps/chat/training_models/data/feedbacks.csv')
        os.makedirs(os.path.dirname(self.csv_path), exist_ok=True)

        if not os.path.isfile(self.csv_path):
            with open(self.csv_path, 'w', newline='', encoding='utf-8') as f:
                f.write('Question;Answer;Category;Source;timestamp')

    async def process_messages(self):
        while True:
            all_chats = self.chat_ref.get() or {}
            for chat_id, chat in all_chats.items():
                if not isinstance(chat, dict):
                    continue
                status = chat.get('status', 'pending')
                msg = (chat.get('message') or '').strip()
                if not msg or status != 'pending':
                    continue

                self.chat_ref.child(chat_id).update({'status': 'processing'})
                try:
                    response = await self.chatbot.generate_response(msg)
                    self.chat_ref.child(chat_id).update({'response': response, 'status': 'done'})
                except Exception as e:
                    self.chat_ref.child(chat_id).update({'status': 'pending', 'error': str(e)})

            await asyncio.sleep(1)

    def start(self):
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.create_task(self.process_messages())
        loop.run_forever()
