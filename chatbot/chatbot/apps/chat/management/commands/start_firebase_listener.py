from django.core.management.base import BaseCommand
from apps.chat.services.firebase_listener import FirebaseListener


class Command(BaseCommand):
    help = 'Start Firebase listener (optional)'

    def handle(self, *args, **options):
        FirebaseListener().start()
