from django.contrib import admin # type: ignore
from .models import Post # type: ignore
from .models import Flashcard

# Register your models here.

admin.site.register(Post)
admin.site.register(Flashcard)