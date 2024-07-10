from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class ShopProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, primary_key=True, related_name="shop_profile"
    )
    address = models.CharField(max_length=255, default="")
    company = models.CharField(max_length=255, default="")
    rating = models.PositiveIntegerField(default=0)
    help_count = models.PositiveIntegerField(default=0)

    def __str__(self):
        return str(self.user.email)


class VolunteerProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        primary_key=True,
        related_name="volunteer_profile",
    )
    company = models.CharField(max_length=255, default="")
    rating = models.PositiveIntegerField(default=0)
    order_count = models.PositiveIntegerField(default=0)


class Norm(models.Model):
    norm_name = models.CharField(max_length=255)

    def __str__(self):
        return str(self.norm_name)


class CustomerProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        primary_key=True,
        related_name="customer_profile",
    )
    address = models.CharField(max_length=255, default="")
    norm = models.ForeignKey(Norm, on_delete=models.CASCADE, null=True, blank=True)


class Category(models.Model):
    category_name = models.CharField(max_length=255, unique=True)
    description = models.TextField(default="")
    unit_of_measurement = models.CharField(max_length=255, default="шт")

    def __str__(self):
        return str(self.category_name)


class CategoryNorm(models.Model):
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    norm = models.ForeignKey(Norm, on_delete=models.CASCADE)
    overall_quantity = models.IntegerField(default=0)

    def __str__(self):
        return str(self.category.category_name)


class Product(models.Model):
    shop = models.ForeignKey(ShopProfile, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    product_name = models.CharField(max_length=255, default="")
    quantity_per_unit = models.IntegerField(default=0)
    units_in_stock = models.IntegerField(default=0)
    units_on_order = models.IntegerField(default=0)
    discontinued = models.BooleanField(default=False)

    def __str__(self):
        return str(self.product_name)


class Order(models.Model):
    customer = models.ForeignKey(CustomerProfile, on_delete=models.CASCADE)
    volunteer = models.ForeignKey(
        VolunteerProfile, on_delete=models.CASCADE, null=True, blank=True
    )
    order_date = models.DateField(auto_now=True)


class OrderDetail(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=0)
