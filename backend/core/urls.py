from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (
    RegisterView, GoalListCreateView, UserListView, ChatMessageListCreateView, StudentProfileView,
    CustomPasswordResetView, CustomPasswordResetDoneView, CustomPasswordResetConfirmView, CustomPasswordResetCompleteView,
    TeacherProfileView, TeacherClassesView, ClassStudentsView, UserDetailView, GenerateQRCodeView, ExistingChatsView, SearchUsersView, UpdateAvatarView,
    TeacherClassGoalsView, StudentGoalsView, StudentPersonalGoalCreateView
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('users/', UserListView.as_view(), name='user-list'),
    path('chat/', ChatMessageListCreateView.as_view(), name='chat-messages'),
    path('profile/', StudentProfileView.as_view(), name='student-profile'),
    path("get-user/", UserDetailView.as_view(), name="get-user"),
    path("get-qr-code/", GenerateQRCodeView.as_view(), name='get-qr-code'),
    path('existing-chats/', ExistingChatsView.as_view(), name='existing-chats'),
    path('search-users/', SearchUsersView.as_view(), name='search-users'),
    path('goals/', GoalListCreateView.as_view(), name='goal-list-create'),
    path('teacher/class/<int:class_id>/goals/', TeacherClassGoalsView.as_view(), name='teacher-class-goals'),
    path('student/goals/', StudentGoalsView.as_view(), name='student-goals'),
    path('student/personal-goal/', StudentPersonalGoalCreateView.as_view(), name='student-personal-goal-create'),
    path('update_avatar/', UpdateAvatarView.as_view(), name='update_avatar'),

    # Password reset URLs
    path('password_reset/', CustomPasswordResetView.as_view(), name='password_reset'),
    path('password_reset/done/', CustomPasswordResetDoneView.as_view(), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', CustomPasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('reset/done/', CustomPasswordResetCompleteView.as_view(), name='password_reset_complete'),

    # Profile URLs
    path('student/profile/', StudentProfileView.as_view(), name='student-profile'),
    path('teacher/profile/', TeacherProfileView.as_view(), name='teacher-profile'),
    path('teacher/classes/', TeacherClassesView.as_view(), name='teacher-classes'),
    path('teacher/class/<int:class_id>/students/', ClassStudentsView.as_view(), name='class-students'),
]