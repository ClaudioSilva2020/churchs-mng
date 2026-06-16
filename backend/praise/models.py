from django.conf import settings
from django.db import models

from ministries.models import Ministry


class Song(models.Model):
    """RF-016: música do repertório, cadastrada por qualquer membro do
    Ministério de Louvor."""

    ministry = models.ForeignKey(Ministry, related_name="songs", on_delete=models.CASCADE)
    title = models.CharField(max_length=120)
    key = models.CharField(max_length=10)  # tom, ex.: "G", "D#m", "Capo 2"
    reference_url = models.URLField(blank=True)
    added_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="songs_added")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["title"]

    def __str__(self):
        return f"{self.title} ({self.key})"


class RepertoirePlan(models.Model):
    """RF-016: plano de louvor de um culto, montado pelo Líder do Ministério
    de Louvor."""

    ministry = models.ForeignKey(Ministry, related_name="repertoire_plans", on_delete=models.CASCADE)
    service_date = models.DateTimeField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="repertoire_plans")

    class Meta:
        ordering = ["service_date"]

    def __str__(self):
        return f"{self.ministry} — {self.service_date}"


class SongAssignment(models.Model):
    """Associa uma música do plano de louvor a um vocalista designado."""

    plan = models.ForeignKey(RepertoirePlan, related_name="assignments", on_delete=models.CASCADE)
    song = models.ForeignKey(Song, related_name="assignments", on_delete=models.CASCADE)
    vocalist = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="song_assignments")

    class Meta:
        unique_together = ("plan", "song")

    def __str__(self):
        return f"{self.song} — {self.vocalist}"
