from django.db import models

class PredefinedResponse(models.Model):
    intent = models.CharField(max_length=100, unique=True)
    response_text = models.TextField()

    def __str__(self):
        return f"PredefinedResponse({self.intent})"
