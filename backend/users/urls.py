from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from .views import RegisterView, UserRetrieveUpdateAPIView, TaskCreateView, TaskListView, TaskCompletionView, DailyStreakResetView, UserRetrieveUpdateAPIView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="sign_up"),
    path("login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("login/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("retrieve_user/", UserRetrieveUpdateAPIView.as_view(), name="retrieve_user"),
    path("update_user/", UserRetrieveUpdateAPIView.as_view(), name="update_user"),
    path("profile/", UserRetrieveUpdateAPIView.as_view(), name="profile"),
    path("tasks/", TaskCreateView.as_view(), name="create-task"),
    path("tasks/assigned/", TaskListView.as_view(), name="assigned-tasks"),
    path(
        "tasks/<int:task_id>/complete/",
        TaskCompletionView.as_view(),
        name="complete-task",
    ),
    path("tasks/streak-reset/", DailyStreakResetView.as_view(), name="streak-reset"),
]
