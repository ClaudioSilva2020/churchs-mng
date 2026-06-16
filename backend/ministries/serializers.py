from rest_framework import serializers

from accounts.serializers import UserSerializer

from .models import Ministry, MinistryEvent, MinistryMembership, ServiceSlot


class MinistrySerializer(serializers.ModelSerializer):
    class Meta:
        model = Ministry
        fields = ["id", "name", "description", "color", "has_schedule", "has_repertoire", "created_by"]
        read_only_fields = ["created_by"]


class MinistryMembershipSerializer(serializers.ModelSerializer):
    user_detail = UserSerializer(source="user", read_only=True)

    class Meta:
        model = MinistryMembership
        fields = ["id", "ministry", "user", "user_detail", "role"]


class MinistryEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = MinistryEvent
        fields = ["id", "ministry", "title", "description", "location", "starts_at"]
        read_only_fields = ["ministry"]


class ServiceSlotSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source="member.get_full_name", read_only=True)

    class Meta:
        model = ServiceSlot
        fields = ["id", "ministry", "service_date", "role", "member", "member_name"]
        read_only_fields = ["ministry"]
