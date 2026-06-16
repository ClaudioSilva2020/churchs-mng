from rest_framework import permissions, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from accounts.permissions import CanManageMinistriesOrReadOnly

from .models import Ministry, MinistryEvent, MinistryMembership, ServiceSlot
from .serializers import (
    MinistryEventSerializer,
    MinistryMembershipSerializer,
    MinistrySerializer,
    ServiceSlotSerializer,
)


class MinistryViewSet(viewsets.ModelViewSet):
    """RF-009: ministérios da igreja."""

    queryset = Ministry.objects.all()
    serializer_class = MinistrySerializer
    permission_classes = [CanManageMinistriesOrReadOnly]

    def perform_create(self, serializer):
        ministry = serializer.save(created_by=self.request.user)
        MinistryMembership.objects.create(
            ministry=ministry, user=self.request.user, role=MinistryMembership.MemberRole.LEADER
        )

    @action(detail=True, methods=["get", "post"], permission_classes=[permissions.IsAuthenticated])
    def members(self, request, pk=None):
        """RF-010: lista membros do ministério ou adiciona/atualiza um membro (líder/pastor)."""
        ministry = self.get_object()

        if request.method == "GET":
            memberships = ministry.memberships.select_related("user")
            return Response(MinistryMembershipSerializer(memberships, many=True).data)

        if not request.user.can_manage_ministries:
            return Response(status=403)

        serializer = MinistryMembershipSerializer(data={**request.data, "ministry": ministry.id})
        serializer.is_valid(raise_exception=True)
        membership, _ = MinistryMembership.objects.update_or_create(
            ministry=ministry,
            user_id=request.data["user"],
            defaults={"role": request.data.get("role", MinistryMembership.MemberRole.SERVANT)},
        )
        return Response(MinistryMembershipSerializer(membership).data, status=201)


class MinistryEventViewSet(viewsets.ModelViewSet):
    """RF-013: agenda/reuniões do ministério."""

    serializer_class = MinistryEventSerializer
    permission_classes = [CanManageMinistriesOrReadOnly]

    def get_queryset(self):
        return MinistryEvent.objects.filter(ministry_id=self.kwargs["ministry_pk"])

    def perform_create(self, serializer):
        serializer.save(ministry_id=self.kwargs["ministry_pk"])


class ServiceSlotViewSet(viewsets.ModelViewSet):
    """RF-014: escala de serviço do ministério."""

    serializer_class = ServiceSlotSerializer
    permission_classes = [CanManageMinistriesOrReadOnly]

    def get_queryset(self):
        return ServiceSlot.objects.filter(ministry_id=self.kwargs["ministry_pk"])

    def perform_create(self, serializer):
        serializer.save(ministry_id=self.kwargs["ministry_pk"])
