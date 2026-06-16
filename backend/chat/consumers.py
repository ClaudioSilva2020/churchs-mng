import json

from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncWebsocketConsumer

from ministries.models import MinistryMembership

from .models import ChatMessage


class MinistryChatConsumer(AsyncWebsocketConsumer):
    """RF-012: chat em tempo real por ministério.

    Endpoint: /ws/ministries/{ministry_id}/chat/
    Mensagens enviadas/recebidas: {"text": "..."}
    """

    async def connect(self):
        self.ministry_id = self.scope["url_route"]["kwargs"]["ministry_id"]
        self.group_name = f"ministry_chat_{self.ministry_id}"
        user = self.scope["user"]

        if not user.is_authenticated or not await self._is_member(user):
            await self.close()
            return

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        text = data.get("text", "").strip()
        if not text:
            return

        user = self.scope["user"]
        message = await self._save_message(user, text)

        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "chat.message",
                "id": message.id,
                "author": user.get_full_name() or user.username,
                "author_id": user.id,
                "text": message.text,
                "created_at": message.created_at.isoformat(),
            },
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def _is_member(self, user):
        if user.role == "pastor":
            return True
        return MinistryMembership.objects.filter(ministry_id=self.ministry_id, user=user).exists()

    @database_sync_to_async
    def _save_message(self, user, text):
        return ChatMessage.objects.create(ministry_id=self.ministry_id, author=user, text=text)
