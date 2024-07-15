from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        if not email:
            raise ValueError("The given email must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    USER_TYPE_CHOICES = [
        ("student", "Student"),
        ("teacher", "Teacher"),
        ("admin", "Admin"),
    ]

    username = None
    email = models.EmailField(_("email address"), unique=True)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    objects = UserManager()

    name = models.CharField(max_length=40, default="")
    streak = models.PositiveIntegerField(default=0)
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES)
    points = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.email


class StudentProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="student_profile"
    )

    def __str__(self):
        return self.user.email


class TeacherProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="teacher_profile"
    )

    def __str__(self):
        return self.user.email


class Task(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    created_by = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="created_tasks"
    )
    assigned_to = models.ManyToManyField(User, related_name="tasks")

    def __str__(self):
        return self.title


class StudentTaskCompletion(models.Model):
    student = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="completed_tasks"
    )
    task = models.ForeignKey(
        Task, on_delete=models.CASCADE, related_name="completed_by_students"
    )
    completed_date = models.DateField(auto_now_add=True)

    def __str__(self):
        return f"{self.student.email} - {self.task.title}"
