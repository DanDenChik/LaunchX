from django.contrib.auth.views import PasswordResetView, PasswordResetDoneView, PasswordResetConfirmView, PasswordResetCompleteView
from django.urls import reverse_lazy
from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Goal, ChatMessage, StudentProfile, Class, QRCode, Attendance, User, TeacherProfile
from .serializers import UserSerializer, GoalSerializer, ChatMessageSerializer, StudentProfileSerializer, ClassSerializer, QRCodeSerializer, AttendanceSerializer, TeacherProfileSerializer, AvatarUpdateSerializer
from .forms import PasswordResetForm
from django.db.models import Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework.filters import SearchFilter

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

    def perform_create(self, serializer):
        user = serializer.save()
        qr_code = QRCode.objects.create(user=user)
        qr_code.generate_qr_code()

class UserDetailView(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

class ChatMessageListCreateView(generics.ListCreateAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        other_user_id = self.request.query_params.get('user_id')
        if other_user_id:
            return ChatMessage.objects.filter(
                (Q(sender=user) & Q(receiver_id=other_user_id)) |
                (Q(sender_id=other_user_id) & Q(receiver=user))
            ).order_by('timestamp')
        return ChatMessage.objects.filter(Q(sender=user) | Q(receiver=user)).order_by('timestamp')

    def perform_create(self, serializer):
        receiver_id = self.request.data.get('receiver')
        serializer.save(sender=self.request.user, receiver_id=receiver_id)

class GoalListCreateView(generics.ListCreateAPIView):
    serializer_class = GoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'teacher':
            return Goal.objects.filter(class_group__teacher=user)
        else:
            return Goal.objects.filter(user=user)

    def perform_create(self, serializer):
        if self.request.user.user_type == 'teacher':
            serializer.save(class_group_id=self.request.data.get('class_group'))
        else:
            serializer.save(user=self.request.user)

class TeacherClassGoalsView(generics.ListCreateAPIView):
    serializer_class = GoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type != 'teacher':
            return Goal.objects.none()
        class_id = self.kwargs['class_id']
        return Goal.objects.filter(class_group_id=class_id, created_by=user)

    def perform_create(self, serializer):
        class_id = self.kwargs['class_id']
        class_obj = get_object_or_404(Class, id=class_id, teacher=self.request.user)
        serializer.save(created_by=self.request.user, class_group=class_obj)

class StudentGoalsView(generics.ListAPIView):
    serializer_class = GoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type != 'student':
            return Goal.objects.none()

        personal_goals = Goal.objects.filter(user=user)
        class_goals = Goal.objects.filter(class_group__students=user)

        return (personal_goals | class_goals).distinct()

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        personal_goals = queryset.filter(user=request.user)
        class_goals = queryset.filter(class_group__students=request.user)

        personal_serializer = self.get_serializer(personal_goals, many=True)
        class_serializer = self.get_serializer(class_goals, many=True)

        return Response({
            'personal_goals': personal_serializer.data,
            'class_goals': class_serializer.data
        })

class StudentPersonalGoalCreateView(generics.CreateAPIView):
    serializer_class = GoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, created_by=self.request.user)


class StudentProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = StudentProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return StudentProfile.objects.all()

    def get_object(self):
        profile = self.get_queryset().get(user=self.request.user)

        actual_completed_goals = Goal.objects.filter(user=self.request.user, is_completed=True).count()
        if profile.completed_goals != actual_completed_goals:
            profile.completed_goals = actual_completed_goals
            profile.save(update_fields=['completed_goals'])

        return profile

class TeacherProfileView(generics.RetrieveAPIView):
    serializer_class = TeacherProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return TeacherProfile.objects.get(user=self.request.user)

class TeacherClassesView(generics.ListAPIView):
    serializer_class = ClassSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Class.objects.filter(teacher=self.request.user)

class UserAvatarView(generics.UpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = (MultiPartParser, FormParser)

    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        if 'avatar' in self.request.data:
            serializer.save(avatar=self.request.data['avatar'])
        else:
            serializer.save()

class CustomPasswordResetView(PasswordResetView):
    template_name = 'core/password_reset_form.html'
    email_template_name = 'core/password_reset_email.html'
    success_url = reverse_lazy('password_reset_done')
    form_class = PasswordResetForm

class CustomPasswordResetDoneView(PasswordResetDoneView):
    template_name = 'core/password_reset_done.html'

class CustomPasswordResetConfirmView(PasswordResetConfirmView):
    template_name = 'core/password_reset_confirm.html'
    success_url = reverse_lazy('password_reset_complete')

class CustomPasswordResetCompleteView(PasswordResetCompleteView):
    template_name = 'core/password_reset_complete.html'


class ClassStudentsView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        class_id = self.kwargs['class_id']
        return User.objects.filter(classes__id=class_id, user_type='student')

class GenerateQRCodeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code, created = QRCode.objects.get_or_create(user=request.user)
        if created or not qr_code.qr_code:
            qr_code.generate_qr_code()
        serializer = QRCodeSerializer(qr_code)
        return Response(serializer.data)

class MarkAttendanceView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user_id = request.data.get('user_id')
        user = get_object_or_404(User, id=user_id)

        attendance, created = Attendance.objects.get_or_create(
            user=user,
            date=timezone.now().date(),
            defaults={'is_present': True}
        )

        if not created:
            attendance.is_present = True
            attendance.save()

        serializer = AttendanceSerializer(attendance)
        return Response(serializer.data, status=status.HTTP_200_OK)

class ExistingChatsView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        contacted_user_ids = ChatMessage.objects.filter(
            Q(sender=user) | Q(receiver=user)
        ).values_list('sender', 'receiver').distinct()

        flat_user_ids = set([user_id for pair in contacted_user_ids for user_id in pair if user_id != user.id])

        return User.objects.filter(id__in=flat_user_ids)

class SearchUsersView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [SearchFilter]
    search_fields = ['username']

    def get_queryset(self):
        return User.objects.exclude(id=self.request.user.id)

class UpdateAvatarView(generics.UpdateAPIView):
    parser_classes = (MultiPartParser, FormParser)
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        user = self.get_object()
        avatar = request.data.get('avatar')
        if avatar:
            user.avatar = avatar
            user.save()
            return Response({'avatar_url': user.get_avatar_url()}, status=status.HTTP_200_OK)
        return Response({'error': 'No avatar provided'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def scan_qr_code(request):
    scanned_email = request.data.get('email')
    try:
        student = User.objects.get(email=scanned_email, user_type='student')
        attendance, created = Attendance.objects.get_or_create(
            user=student,
            date=timezone.now().date(),
            defaults={'is_present': True}
        )
        if not created:
            attendance.is_present = True
            attendance.save()
            return Response({'message': 'Attendance marked successfully'}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Invalid QR code'}, status=status.HTTP_400_BAD_REQUEST)