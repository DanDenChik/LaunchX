from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User, StudentProfile, TeacherProfile, Task, StudentTaskCompletion


class UserAdmin(BaseUserAdmin):
    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (_("Personal info"), {"fields": ("name",)}),
        (
            _("Permissions"),
            {
                "fields": (
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        (_("Important dates"), {"fields": ("last_login", "date_joined")}),
        (_("Additional info"), {"fields": ("user_type", "streak", "points")}),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("email", "password1", "password2", "user_type", "name"),
            },
        ),
    )
    list_display = (
        "email",
        "name",
        "user_type",
        "is_staff",
        "streak",
        "points",
    )
    search_fields = ("email", "name")
    ordering = ("email",)


class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ("user",)


class TeacherProfileAdmin(admin.ModelAdmin):
    list_display = ("user",)


class TaskAdmin(admin.ModelAdmin):
    list_display = ("title", "created_by")
    filter_horizontal = ("assigned_to",)


class StudentTaskCompletionAdmin(admin.ModelAdmin):
    list_display = ("student", "task", "completed_date")


admin.site.register(User, UserAdmin)
admin.site.register(StudentProfile, StudentProfileAdmin)
admin.site.register(TeacherProfile, TeacherProfileAdmin)
admin.site.register(Task, TaskAdmin)
admin.site.register(StudentTaskCompletion, StudentTaskCompletionAdmin)
