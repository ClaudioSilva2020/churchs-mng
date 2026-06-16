from django.urls import path

from .views import ChatMessageListCreateView

urlpatterns = [
    path("ministries/<int:ministry_pk>/messages/", ChatMessageListCreateView.as_view(), name="ministry-messages"),
]
