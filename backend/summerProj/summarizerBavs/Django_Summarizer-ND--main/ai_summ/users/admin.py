from django.contrib import admin # type: ignore
from .models import Profile # type: ignore

# Register your models here.

admin.site.register(Profile)
