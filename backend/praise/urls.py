from django.urls import path

from .views import RepertoirePlanViewSet, SongViewSet

songs_list = SongViewSet.as_view({"get": "list", "post": "create"})
songs_detail = SongViewSet.as_view(
    {"get": "retrieve", "put": "update", "patch": "partial_update", "delete": "destroy"}
)
plans_list = RepertoirePlanViewSet.as_view({"get": "list", "post": "create"})
plans_detail = RepertoirePlanViewSet.as_view(
    {"get": "retrieve", "put": "update", "patch": "partial_update", "delete": "destroy"}
)

urlpatterns = [
    path("ministries/<int:ministry_pk>/songs/", songs_list, name="ministry-songs-list"),
    path("ministries/<int:ministry_pk>/songs/<int:pk>/", songs_detail, name="ministry-songs-detail"),
    path("ministries/<int:ministry_pk>/repertoire-plans/", plans_list, name="ministry-plans-list"),
    path("ministries/<int:ministry_pk>/repertoire-plans/<int:pk>/", plans_detail, name="ministry-plans-detail"),
]
