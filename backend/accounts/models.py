from django.contrib.auth.models import AbstractUser
from django.db import models


class Role(models.TextChoices):
    """RF-001 a RF-004b: papéis de usuário."""

    NON_MEMBER = "non_member", "Não-membro"
    MEMBER = "member", "Membro"
    SERVANT = "servant", "Servo"
    LEADER = "leader", "Líder de Ministério"
    MEDIA = "media", "Mídia"
    PASTOR = "pastor", "Pastor"


class User(AbstractUser):
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.NON_MEMBER)

    # RF-004: concedido individualmente pelo Pastor.
    has_automation_access = models.BooleanField(default=False)

    phone = models.CharField(max_length=20, blank=True)

    @property
    def can_manage_ministries(self):
        return self.role in (Role.LEADER, Role.PASTOR)

    @property
    def can_publish_content(self):
        return self.role in (Role.MEDIA, Role.PASTOR, Role.LEADER)

    @property
    def can_manage_members(self):
        return self.role == Role.PASTOR

    def __str__(self):
        return self.get_full_name() or self.username
