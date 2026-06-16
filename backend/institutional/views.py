from rest_framework import generics, permissions, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.permissions import CanPublishContentOrReadOnly

from .models import Banner, BannerComment, BannerLike, ChurchPrinciple, ServiceSchedule
from .serializers import (
    BannerCommentSerializer,
    BannerSerializer,
    ChurchPrincipleSerializer,
    ServiceScheduleSerializer,
)


class BannerViewSet(viewsets.ModelViewSet):
    """RF-005/RF-008c: banners/postagens de Avisos e Eventos."""

    queryset = Banner.objects.all()
    serializer_class = BannerSerializer
    permission_classes = [CanPublishContentOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(published_by=self.request.user)


class BannerLikeView(APIView):
    """POST/DELETE /api/banners/{id}/like/ — curtir/descurtir uma postagem."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        banner = Banner.objects.get(pk=pk)
        BannerLike.objects.get_or_create(banner=banner, user=request.user)
        return Response({"liked": True, "likes_count": banner.likes.count()})

    def delete(self, request, pk):
        banner = Banner.objects.get(pk=pk)
        BannerLike.objects.filter(banner=banner, user=request.user).delete()
        return Response({"liked": False, "likes_count": banner.likes.count()})


class BannerCommentListCreateView(generics.ListCreateAPIView):
    """GET/POST /api/banners/{id}/comments/"""

    serializer_class = BannerCommentSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return BannerComment.objects.filter(banner_id=self.kwargs["pk"])

    def perform_create(self, serializer):
        serializer.save(author=self.request.user, banner_id=self.kwargs["pk"])


class ChurchPrincipleView(APIView):
    """GET/PUT /api/principles/ — RF-006, registro único editável pelo Pastor."""

    permission_classes = [CanPublishContentOrReadOnly]

    def get(self, request):
        principle, _ = ChurchPrinciple.objects.get_or_create(pk=1, defaults={"content": ""})
        return Response(ChurchPrincipleSerializer(principle).data)

    def put(self, request):
        principle, _ = ChurchPrinciple.objects.get_or_create(pk=1, defaults={"content": ""})
        serializer = ChurchPrincipleSerializer(principle, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class ServiceScheduleViewSet(viewsets.ModelViewSet):
    """RF-007: programação institucional de cultos/eventos."""

    queryset = ServiceSchedule.objects.all()
    serializer_class = ServiceScheduleSerializer
    permission_classes = [CanPublishContentOrReadOnly]
