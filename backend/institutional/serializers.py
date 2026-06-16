from rest_framework import serializers

from .models import Banner, BannerComment, ChurchPrinciple, ServiceSchedule


class BannerCommentSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.get_full_name", read_only=True)

    class Meta:
        model = BannerComment
        fields = ["id", "banner", "author", "author_name", "text", "created_at"]
        read_only_fields = ["author", "created_at"]


class BannerSerializer(serializers.ModelSerializer):
    published_by_name = serializers.CharField(source="published_by.get_full_name", read_only=True)
    likes_count = serializers.IntegerField(source="likes.count", read_only=True)
    comments = BannerCommentSerializer(many=True, read_only=True)
    liked_by_me = serializers.SerializerMethodField()

    class Meta:
        model = Banner
        fields = [
            "id",
            "title",
            "description",
            "image",
            "kind",
            "media_type",
            "starts_at",
            "published_by",
            "published_by_name",
            "created_at",
            "likes_count",
            "liked_by_me",
            "comments",
        ]
        read_only_fields = ["published_by", "created_at"]

    def get_liked_by_me(self, obj):
        request = self.context.get("request")
        if not request or not request.user.is_authenticated:
            return False
        return obj.likes.filter(user=request.user).exists()


class ChurchPrincipleSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChurchPrinciple
        fields = ["id", "title", "content", "updated_at"]
        read_only_fields = ["updated_at"]


class ServiceScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceSchedule
        fields = ["id", "day_of_week", "time", "title", "subtitle"]
