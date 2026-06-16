from django.conf import settings
from django.db import models

from ministries.models import Ministry


class ChatMessage(models.Model):
    """RF-012: mensagens de chat por ministério."""

    ministry = models.ForeignKey(Ministry, related_name="messages", on_delete=models.CASCADE)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="chat_messages")
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.author}: {self.text[:30]}"
