from django.urls import re_path

from .consumers import MinistryChatConsumer

websocket_urlpatterns = [
    re_path(r"^ws/ministries/(?P<ministry_id>\d+)/chat/$", MinistryChatConsumer.as_asgi()),
]
