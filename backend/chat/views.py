from rest_framework import generics, permissions

from .models import ChatMessage
from .serializers import ChatMessageSerializer


class ChatMessageListCreateView(generics.ListCreateAPIView):
    """GET/POST /api/ministries/{id}/messages/ — histórico de chat (RF-012).

    Mensagens em tempo real são entregues via WebSocket
    (/ws/ministries/{id}/chat/); este endpoint serve para carregar o
    histórico ao abrir a tela.
    """

    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ChatMessage.objects.filter(ministry_id=self.kwargs["ministry_pk"])

    def perform_create(self, serializer):
        serializer.save(ministry_id=self.kwargs["ministry_pk"], author=self.request.user)
