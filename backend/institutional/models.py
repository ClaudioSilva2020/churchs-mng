from django.conf import settings
from django.db import models


class Banner(models.Model):
    """RF-005/RF-008c: postagens exibidas em Avisos e Eventos."""

    class Kind(models.TextChoices):
        EVENT = "event", "Evento"
        SERVICE = "service", "Culto"
        WORD = "word", "Palavra"
        POST = "post", "Postagem"

    class MediaType(models.TextChoices):
        IMAGE = "image", "Imagem"
        VIDEO = "video", "Vídeo"

    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to="banners/", blank=True, null=True)
    kind = models.CharField(max_length=20, choices=Kind.choices, default=Kind.POST)
    media_type = models.CharField(max_length=20, choices=MediaType.choices, default=MediaType.IMAGE)
    starts_at = models.DateTimeField(blank=True, null=True)
    published_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="banners")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.title


class BannerLike(models.Model):
    banner = models.ForeignKey(Banner, related_name="likes", on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("banner", "user")


class BannerComment(models.Model):
    banner = models.ForeignKey(Banner, related_name="comments", on_delete=models.CASCADE)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]


class ChurchPrinciple(models.Model):
    """RF-006: conteúdo estático editável pelo Pastor — registro único."""

    title = models.CharField(max_length=120, default="Princípios e Valores")
    content = models.TextField()
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title


class ServiceSchedule(models.Model):
    """RF-007: programação institucional de cultos/eventos."""

    day_of_week = models.CharField(max_length=20)
    time = models.CharField(max_length=10)
    title = models.CharField(max_length=120)
    subtitle = models.CharField(max_length=200, blank=True)

    class Meta:
        ordering = ["id"]

    def __str__(self):
        return f"{self.day_of_week} {self.time} — {self.title}"
