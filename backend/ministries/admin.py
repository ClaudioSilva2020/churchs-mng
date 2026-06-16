from django.contrib import admin

from .models import Ministry, MinistryEvent, MinistryMembership, ServiceSlot


@admin.register(Ministry)
class MinistryAdmin(admin.ModelAdmin):
    list_display = ("name", "has_schedule", "has_repertoire", "created_by")


admin.site.register(MinistryMembership)
admin.site.register(MinistryEvent)
admin.site.register(ServiceSlot)
