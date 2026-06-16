from django.conf import settings
from django.db import models


class Ministry(models.Model):
    """RF-009 a RF-011: ministério, com líderes e servos."""

    name = models.CharField(max_length=80)
    description = models.TextField(blank=True)
    color = models.CharField(max_length=7, blank=True)  # hex

    # RF-014: apenas Louvor, PGs, Missões, Libras e Mulheres têm escala.
    has_schedule = models.BooleanField(default=False)

    # RF-016: apenas o Ministério de Louvor tem repertório de músicas.
    has_repertoire = models.BooleanField(default=False)

    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="ministries_created")
    members = models.ManyToManyField(settings.AUTH_USER_MODEL, through="MinistryMembership", related_name="ministries")

    class Meta:
        ordering = ["id"]
        verbose_name_plural = "ministries"

    def __str__(self):
        return self.name


class MinistryMembership(models.Model):
    """RF-010: papéis dentro de um ministério (Líder/Servo)."""

    class MemberRole(models.TextChoices):
        LEADER = "leader", "Líder"
        SERVANT = "servant", "Servo"

    ministry = models.ForeignKey(Ministry, related_name="memberships", on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="ministry_memberships")
    role = models.CharField(max_length=20, choices=MemberRole.choices, default=MemberRole.SERVANT)

    class Meta:
        unique_together = ("ministry", "user")

    def __str__(self):
        return f"{self.user} @ {self.ministry} ({self.role})"


class MinistryEvent(models.Model):
    """RF-013: agenda/reuniões do ministério."""

    ministry = models.ForeignKey(Ministry, related_name="events", on_delete=models.CASCADE)
    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=120, blank=True)
    starts_at = models.DateTimeField()

    class Meta:
        ordering = ["starts_at"]

    def __str__(self):
        return self.title


class ServiceSlot(models.Model):
    """RF-014: escala de serviço — quem está designado para qual culto/data."""

    ministry = models.ForeignKey(Ministry, related_name="service_slots", on_delete=models.CASCADE)
    service_date = models.DateTimeField()
    role = models.CharField(max_length=80)  # ex.: "Responsável", "Apoio", "Vocal"
    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="service_slots")

    class Meta:
        ordering = ["service_date"]

    def __str__(self):
        return f"{self.ministry} — {self.role} ({self.member})"
