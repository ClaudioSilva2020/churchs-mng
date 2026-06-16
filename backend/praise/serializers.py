from rest_framework import serializers

from .models import RepertoirePlan, Song, SongAssignment


class SongSerializer(serializers.ModelSerializer):
    added_by_name = serializers.CharField(source="added_by.get_full_name", read_only=True)

    class Meta:
        model = Song
        fields = ["id", "ministry", "title", "key", "reference_url", "added_by", "added_by_name", "created_at"]
        read_only_fields = ["ministry", "added_by", "created_at"]


class SongAssignmentSerializer(serializers.ModelSerializer):
    vocalist_name = serializers.CharField(source="vocalist.get_full_name", read_only=True)
    song_title = serializers.CharField(source="song.title", read_only=True)

    class Meta:
        model = SongAssignment
        fields = ["id", "plan", "song", "song_title", "vocalist", "vocalist_name"]


class RepertoirePlanSerializer(serializers.ModelSerializer):
    assignments = SongAssignmentSerializer(many=True, read_only=True)

    class Meta:
        model = RepertoirePlan
        fields = ["id", "ministry", "service_date", "created_by", "assignments"]
        read_only_fields = ["created_by"]


class RepertoirePlanCreateSerializer(serializers.ModelSerializer):
    """RF-016: criação de plano de louvor já com as designações de vocalistas."""

    assignments = serializers.ListField(child=serializers.DictField(), write_only=True)

    class Meta:
        model = RepertoirePlan
        fields = ["id", "ministry", "service_date", "assignments"]
        read_only_fields = ["ministry"]

    def create(self, validated_data):
        assignments_data = validated_data.pop("assignments")
        plan = RepertoirePlan.objects.create(**validated_data)
        for item in assignments_data:
            SongAssignment.objects.create(plan=plan, song_id=item["song"], vocalist_id=item["vocalist"])
        return plan
