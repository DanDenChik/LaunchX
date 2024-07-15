from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import (
    UserSignUpSerializer,
    UserSerializer,
    TaskSerializer,
    StudentTaskCompletionSerializer,
)
from rest_framework import generics, status, permissions
from .models import User, Task, StudentTaskCompletion
from datetime import date, timedelta
from django.utils.timezone import now


class RegisterView(APIView):
    serializer_class = UserSignUpSerializer

    def post(self, request):
        data = request.data

        serializer = self.serializer_class(data=data)

        if serializer.is_valid():
            serializer.save()

            response = {
                "message": "USER REGISTERED SUCCESSFULLY",
                "data": serializer.data,
            }

            return Response(data=response, status=status.HTTP_201_CREATED)

        return Response(data=serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserRetrieveUpdateAPIView(generics.RetrieveUpdateAPIView):
    permission_classes = (permissions.IsAuthenticated,)
    serializer_class = UserSerializer

    def retrieve(self, request, *args, **kwargs):
        serializer = self.serializer_class(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def update(self, request, *args, **kwargs):
        serializer = self.serializer_class(
            request.user, data=request.data, partial=True
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)


class TaskCreateView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        data = request.data
        data["created_by"] = request.user.id

        serializer = TaskSerializer(data=data)

        if serializer.is_valid():
            task = serializer.save()
            return Response(TaskSerializer(task).data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TaskListView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        tasks = Task.objects.filter(assigned_to=request.user)
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)


class TaskCompletionView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, task_id):
        user = request.user
        try:
            task = Task.objects.get(id=task_id)
        except Task.DoesNotExist:
            return Response(
                {"error": "Task not found"}, status=status.HTTP_404_NOT_FOUND
            )

        if user.user_type != "student":
            return Response(
                {"error": "Only students can complete tasks"},
                status=status.HTTP_403_FORBIDDEN,
            )

        completion = StudentTaskCompletion.objects.create(student=user, task=task)
        user.streak += 1
        user.points += 10
        user.save()

        return Response(
            StudentTaskCompletionSerializer(completion).data, status=status.HTTP_200_OK
        )


class DailyStreakResetView(APIView):
    def post(self, request):
        today = date.today()
        if today.weekday() < 5:
            users = User.objects.filter(user_type="student")
            for user in users:
                last_completion = user.completed_tasks.order_by("completed_date").last()
                if last_completion:
                    last_completion_date = last_completion.completed_date
                    if last_completion_date < today - timedelta(days=1):
                        user.streak = 0
                        user.save()
        return Response({"message": "Streaks updated"}, status=status.HTTP_200_OK)
