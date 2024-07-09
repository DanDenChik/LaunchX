from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from user_management.views import RegisterView, UserRetrieveUpdateAPIView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='sign_up'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('retrieve_user/', UserRetrieveUpdateAPIView.as_view(), name='retrieve_user'),
    path('update_user/', UserRetrieveUpdateAPIView.as_view(), name='update_user'),
]