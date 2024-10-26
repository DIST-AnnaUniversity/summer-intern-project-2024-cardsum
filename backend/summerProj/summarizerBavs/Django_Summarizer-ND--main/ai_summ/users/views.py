from django.shortcuts import render, redirect # type: ignore
from django.contrib.auth.decorators import login_required # type: ignore
from django.contrib import messages # type: ignore
from .forms import UserRegisterForm

# Create your views here.
def register(request):
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            messages.success(request, f'Your accoun6 has been created! You are now able to login')
            return redirect('blog-home')
    else:
        form = UserRegisterForm()
    return render(request, 'users/register.html', {'form': form})

@login_required
def profile(request):
    return render(request, 'users/profile.html')

