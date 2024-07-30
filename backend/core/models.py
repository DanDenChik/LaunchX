from django.contrib.auth.models import AbstractUser
from django.db import models
import qrcode
from io import BytesIO
from django.core.files import File
from django.conf import settings
from django.utils import timezone

class User(AbstractUser):
    USER_TYPE_CHOICES = (
        ('student', 'Student'),
        ('teacher', 'Teacher'),
    )
    full_name = models.CharField(max_length=255)
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES)
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)

    def get_avatar_url(self):
        if self.avatar:
            return f"{settings.DOMAIN_NAME}{self.avatar.url}"
        return

    def __str__(self):
        return self.username

class Class(models.Model):
    name = models.CharField(max_length=255)
    teacher = models.ForeignKey(User, on_delete=models.CASCADE, related_name='classes')
    students = models.ManyToManyField(User, related_name='enrolled_classes')

    def __str__(self):
        return self.name

class Goal(models.Model):
    title = models.CharField(max_length=255)
    deadline = models.DateTimeField()
    is_completed = models.BooleanField(default=False)
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="personal_goals",
        null=True,
        blank=True,
    )
    class_group = models.ForeignKey(
        Class,
        on_delete=models.CASCADE,
        related_name="class_goals",
        null=True,
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def is_overdue(self):
        return self.deadline < timezone.now() and not self.is_completed


class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    streak = models.IntegerField(default=0)
    completed_goals = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user.username}'s profile"


class TeacherProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

class QRCode(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    qr_code = models.ImageField(upload_to="qr_codes/", blank=True)

    def generate_qr_code(self):
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(self.user.email)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        self.qr_code.save(f"qr_code_{self.user.id}.png", File(buffer), save=False)
        self.save()


class Attendance(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField(auto_now_add=True)
    is_present = models.BooleanField(default=False)

    class Meta:
        unique_together = ('user', 'date')


class ChatMessage(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['timestamp']