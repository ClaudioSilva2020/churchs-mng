from django.contrib import admin

from .models import Banner, BannerComment, BannerLike, ChurchPrinciple, ServiceSchedule


@admin.register(Banner)
class BannerAdmin(admin.ModelAdmin):
    list_display = ("title", "kind", "media_type", "published_by", "created_at")
    list_filter = ("kind", "media_type")


admin.site.register(BannerLike)
admin.site.register(BannerComment)


@admin.register(ChurchPrinciple)
class ChurchPrincipleAdmin(admin.ModelAdmin):
    list_display = ("title", "updated_at")


@admin.register(ServiceSchedule)
class ServiceScheduleAdmin(admin.ModelAdmin):
    list_display = ("day_of_week", "time", "title")
