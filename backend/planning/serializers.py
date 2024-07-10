from django.forms import ValidationError
from rest_framework import serializers

# from .models import
from django.contrib.auth import get_user_model
User = get_user_model()