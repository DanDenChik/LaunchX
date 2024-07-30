from rest_framework import serializers
from .models import User, Goal, ChatMessage, StudentProfile, TeacherProfile, Class, QRCode, Attendance

class QRCodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = QRCode
        fields = ['qr_code']

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = ['id', 'user', 'date', 'is_present']

class ClassSerializer(serializers.ModelSerializer):
    class Meta:
        model = Class
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    password_confirmation = serializers.CharField(write_only=True)
    classes = ClassSerializer(many=True, read_only=True)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'full_name', 'username', 'email', 'password', 'password_confirmation', 'user_type', 'classes', 'avatar_url']

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        if instance.user_type == 'teacher':
            representation['classes'] = ClassSerializer(instance.classes.all(), many=True).data
        else:
            representation.pop('classes', None)
        return representation

    def get_avatar_url(self, obj):
        return obj.get_avatar_url()

    def validate(self, data):
        if data['password'] != data['password_confirmation']:
            raise serializers.ValidationError("Passwords don't match")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirmation')
        user = User.objects.create_user(**validated_data)
        return user


class ChatMessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    receiver = UserSerializer(read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'sender', 'receiver', 'content', 'timestamp']

class GoalSerializer(serializers.ModelSerializer):
    is_overdue = serializers.BooleanField(read_only=True)
    created_by = serializers.StringRelatedField(read_only=True)
    class_name = serializers.SerializerMethodField()

    class Meta:
        model = Goal
        fields = ['id', 'title', 'deadline', 'is_completed', 'user', 'class_group', 'created_at', 'is_overdue', 'created_by', 'class_name']

    def get_class_name(self, obj):
        return obj.class_group.name if obj.class_group else None

class StudentProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = StudentProfile
        fields = ['user', 'streak', 'completed_goals']

class AvatarUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['avatar']

class TeacherProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    classes_count = serializers.SerializerMethodField()

    class Meta:
        model = TeacherProfile
        fields = ['user', 'classes_count']

    def get_classes_count(self, obj):
        return obj.user.classes.count()