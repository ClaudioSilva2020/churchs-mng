from rest_framework import permissions, viewsets
from rest_framework.exceptions import PermissionDenied

from ministries.models import MinistryMembership

from .models import RepertoirePlan, Song
from .serializers import RepertoirePlanCreateSerializer, RepertoirePlanSerializer, SongSerializer


def _is_ministry_member(user, ministry_id):
    if user.role == "pastor":
        return True
    return MinistryMembership.objects.filter(ministry_id=ministry_id, user=user).exists()


def _is_ministry_leader(user, ministry_id):
    if user.role == "pastor":
        return True
    return MinistryMembership.objects.filter(
        ministry_id=ministry_id, user=user, role=MinistryMembership.MemberRole.LEADER
    ).exists()


class SongViewSet(viewsets.ModelViewSet):
    """RF-016: repertório de músicas — qualquer membro do ministério pode
    cadastrar."""

    serializer_class = SongSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Song.objects.filter(ministry_id=self.kwargs["ministry_pk"])

    def perform_create(self, serializer):
        ministry_id = self.kwargs["ministry_pk"]
        if not _is_ministry_member(self.request.user, ministry_id):
            raise PermissionDenied("Apenas membros do ministério podem cadastrar músicas.")
        serializer.save(ministry_id=ministry_id, added_by=self.request.user)


class RepertoirePlanViewSet(viewsets.ModelViewSet):
    """RF-016: escala de vocalistas por culto — apenas o Líder do Ministério
    de Louvor pode criar."""

    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return RepertoirePlan.objects.filter(ministry_id=self.kwargs["ministry_pk"])

    def get_serializer_class(self):
        if self.action == "create":
            return RepertoirePlanCreateSerializer
        return RepertoirePlanSerializer

    def perform_create(self, serializer):
        ministry_id = self.kwargs["ministry_pk"]
        if not _is_ministry_leader(self.request.user, ministry_id):
            raise PermissionDenied("Apenas o líder do ministério pode publicar a escala de louvor.")
        serializer.save(ministry_id=ministry_id, created_by=self.request.user)
