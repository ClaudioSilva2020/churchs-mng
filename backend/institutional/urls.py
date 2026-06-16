from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    BannerCommentListCreateView,
    BannerLikeView,
    BannerViewSet,
    ChurchPrincipleView,
    ServiceScheduleViewSet,
)

router = DefaultRouter()
router.register("banners", BannerViewSet, basename="banner")
router.register("schedule", ServiceScheduleViewSet, basename="schedule")

urlpatterns = [
    path("", include(router.urls)),
    path("banners/<int:pk>/like/", BannerLikeView.as_view(), name="banner-like"),
    path("banners/<int:pk>/comments/", BannerCommentListCreateView.as_view(), name="banner-comments"),
    path("principles/", ChurchPrincipleView.as_view(), name="principles"),
]
