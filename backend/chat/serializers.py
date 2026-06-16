from rest_framework import serializers

from .models import ChatMessage


class ChatMessageSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.get_full_name", read_only=True)

    class Meta:
        model = ChatMessage
        fields = ["id", "ministry", "author", "author_name", "text", "created_at"]
        read_only_fields = ["ministry", "author", "created_at"]
