from django.contrib import admin

from .models import RepertoirePlan, Song, SongAssignment

admin.site.register(Song)
admin.site.register(RepertoirePlan)
admin.site.register(SongAssignment)
