from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='summ-home'),
    path('about/', views.about, name='summ-about'),
    path('summarize/', views.summarize, name = 'summ-summarizer'),
    path('login/', views.login, name='summ-login'),
    path('registerUser/', views.registerUser, name='summ-register'),
    path('getUserInfo/', views.getUserInfo, name='summ-getUserInfo'),
    path('registerFlashcard/', views.registerFlashcard, name='summ-registerFlashcard'),
    path('getFlashcards/', views.getFlashcards, name='summ-getFlashcards'),
    path('getFlashcard/', views.getFlashcard, name='summ-getFlashcard'),
    path('deleteFlashcard/', views.deleteFlashcard, name='summ-deleteFlashcard'),
    path('updateFlashcard/', views.updateFlashcard, name='summ-updateFlashcard'),
    path('summarizeToFlashcards/', views.summarizeToFlashcards, name = 'summ-summarizeToFlashcards'),
    path('questionGenerate/', views.questionGenerate, name = 'summ-questionGenerate'),
    path('logout/', views.logout, name = 'summ-logout'),
    path('summarizeSynonym/', views.summarizeSynonym, name = 'summ-summarizeSynonym'),
    path('simpleSummary/', views.simpleSummary, name = 'summ-simpleSummary')
]
