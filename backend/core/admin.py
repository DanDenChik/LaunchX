from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.html import format_html
from .models import User, Class, Goal, ChatMessage, StudentProfile, TeacherProfile, QRCode, Attendance

class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'full_name', 'user_type', 'display_avatar')
    list_filter = ('user_type',)
    search_fields = ('username', 'email', 'full_name')
    fieldsets = UserAdmin.fieldsets + (
        ('Custom Fields', {'fields': ('full_name', 'user_type', 'avatar')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Custom Fields', {'fields': ('full_name', 'user_type', 'avatar')}),
    )

    def display_avatar(self, obj):
        if obj.avatar:
            return format_html('<img src="{}" width="50" height="50" />', obj.get_avatar_url())
        return "No Avatar"
    display_avatar.short_description = 'Avatar'

class ClassAdmin(admin.ModelAdmin):
    list_display = ('name', 'teacher', 'display_students')
    list_filter = ('teacher',)
    search_fields = ('name', 'teacher__username', 'students__username')
    filter_horizontal = ('students',)

    def display_students(self, obj):
        return ", ".join([student.username for student in obj.students.all()])
    display_students.short_description = 'Students'

class GoalAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'class_group', 'deadline', 'is_completed', 'is_overdue', 'created_at')
    list_filter = ('user', 'class_group', 'is_completed')
    search_fields = ('title', 'user__username', 'class_group__name')

class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ('sender', 'receiver', 'content', 'timestamp')
    list_filter = ('sender', 'receiver')
    search_fields = ('sender__username', 'receiver__username', 'content')

class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'streak', 'completed_goals')
    search_fields = ('user__username', 'user__full_name')

class TeacherProfileAdmin(admin.ModelAdmin):
    list_display = ('user',)
    search_fields = ('user__username', 'user__full_name')

class QRCodeAdmin(admin.ModelAdmin):
    list_display = ('user', 'display_qr_code')
    search_fields = ('user__username', 'user__email')

    def display_qr_code(self, obj):
        if obj.qr_code:
            return format_html('<img src="{}" width="100" height="100" />', obj.qr_code.url)
        return "No QR Code"
    display_qr_code.short_description = 'QR Code'

class AttendanceAdmin(admin.ModelAdmin):
    list_display = ('user', 'date', 'is_present')
    list_filter = ('date', 'is_present')
    search_fields = ('user__username', 'user__full_name')

admin.site.register(User, CustomUserAdmin)
admin.site.register(Class, ClassAdmin)
admin.site.register(Goal, GoalAdmin)
admin.site.register(ChatMessage, ChatMessageAdmin)
admin.site.register(StudentProfile, StudentProfileAdmin)
admin.site.register(TeacherProfile, TeacherProfileAdmin)
admin.site.register(QRCode, QRCodeAdmin)
admin.site.register(Attendance, AttendanceAdmin)