from asgiref.sync import sync_to_async
from apps.chat.models import PredefinedResponse

class ResponseHelper:
    @sync_to_async
    def get_predefined_response(self, intent: str):
        try:
            return PredefinedResponse.objects.get(intent=intent).response_text
        except PredefinedResponse.DoesNotExist:
            return None
