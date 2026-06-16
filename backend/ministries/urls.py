from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import MinistryEventViewSet, MinistryViewSet, ServiceSlotViewSet

router = DefaultRouter()
router.register("ministries", MinistryViewSet, basename="ministry")

events_list = MinistryEventViewSet.as_view({"get": "list", "post": "create"})
events_detail = MinistryEventViewSet.as_view(
    {"get": "retrieve", "put": "update", "patch": "partial_update", "delete": "destroy"}
)
slots_list = ServiceSlotViewSet.as_view({"get": "list", "post": "create"})
slots_detail = ServiceSlotViewSet.as_view(
    {"get": "retrieve", "put": "update", "patch": "partial_update", "delete": "destroy"}
)

urlpatterns = [
    path("", include(router.urls)),
    path("ministries/<int:ministry_pk>/events/", events_list, name="ministry-events-list"),
    path("ministries/<int:ministry_pk>/events/<int:pk>/", events_detail, name="ministry-events-detail"),
    path("ministries/<int:ministry_pk>/schedule-slots/", slots_list, name="ministry-slots-list"),
    path("ministries/<int:ministry_pk>/schedule-slots/<int:pk>/", slots_detail, name="ministry-slots-detail"),
]
