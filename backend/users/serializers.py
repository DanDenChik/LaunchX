from django.forms import ValidationError
from rest_framework import serializers
from .models import User, StudentProfile, TeacherProfile, Task, StudentTaskCompletion
from django.utils.translation import gettext_lazy as _


class UserSignUpSerializer(serializers.ModelSerializer):
    email = serializers.CharField(max_length=255)
    password = serializers.CharField(
        label=_("Password"),
        style={"input_type": "password"},
        trim_whitespace=False,
        max_length=128,
        write_only=True,
    )
    user_type = serializers.ChoiceField(choices=User.USER_TYPE_CHOICES)
    name = serializers.CharField(max_length=255)

    class Meta:
        model = User
        fields = ["email", "password", "name", "user_type"]

    def create(self, validated_data):
        user = User.objects.create(
            email=validated_data["email"],
            name=validated_data["name"],
            user_type=validated_data["user_type"],
        )
        user.set_password(validated_data["password"])
        user.save()

        if user.user_type == "student":
            StudentProfile.objects.create(user=user)
        elif user.user_type == "teacher":
            TeacherProfile.objects.create(user=user)

        return user

    def validate(self, attrs):
        email_exists = User.objects.filter(email=attrs["email"]).exists()

        if email_exists:
            raise ValidationError("Email has already been used")

        return super().validate(attrs)


class UserSerializer(serializers.ModelSerializer):
    email = serializers.CharField(required=True)
    name = serializers.CharField(required=True)
    streak = serializers.IntegerField(required=True)
    user_type = serializers.ChoiceField(choices=User.USER_TYPE_CHOICES, required=True)
    points = serializers.IntegerField(required=True)

    class Meta:
        model = User
        fields = ["email", "name", "streak", "user_type", "points"]


class TaskSerializer(serializers.ModelSerializer):
    created_by = serializers.ReadOnlyField(source="created_by.email")

    class Meta:
        model = Task
        fields = ["id", "title", "description", "created_by", "assigned_to"]


class StudentTaskCompletionSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentTaskCompletion
        fields = ["id", "student", "task", "completed_date"]
