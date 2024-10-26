import json

from django.shortcuts import render #type: ignore
from .models import Post, FlashcardsManager
from django.http import HttpResponse
from django.http import JsonResponse
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt

from ai_summ import summarizer
from ai_summ import summarizerv2
from ai_summ import keybertSynonymizer

import os
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from rest_framework.decorators import api_view
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken, OutstandingToken


from django.middleware.csrf import get_token

#stupid stuff, should really import over models?
#only damn reason I have these is for the tokens
#maybe sessions would have been a better idea?



def home(request):
    context = {
        'posts': Post.objects.all()
    }
    return render(request, 'summ/home.html', context)

@csrf_exempt
def about(request):
    body = request.body.decode('utf-8')
    print(body)
    print((request.body))
    return HttpResponse(body.upper())


@csrf_exempt
def summarize(request):
    data = json.load(request)
    return HttpResponse(summarizerv2.text_summarizer(data.get("userBody"), data.get("language")))


@csrf_exempt
def summarizeSynonym(request):
    
    data = json.loads(request.body)
    print(data.get("language"))
    userBody = data.get("userBody")
    summarizedText = summarizerv2.text_summarizer(userBody, data.get("language"))
    keywordsString = "\n\n"
    keywordsDict = keybertSynonymizer.extract_keywords(userBody)

    for i in keywordsDict:
        keywordsString += f"Keyword: {i} | Synonyms: {','.join(keywordsDict[i])}\n\n"


    return HttpResponse(summarizedText+keywordsString)



@csrf_exempt
def simpleSummary(request):
    bodyText = request.body.decode('utf-8')
    return HttpResponse(summarizerv2.summarizerContainer().generate_simple_summary(bodyText))


@csrf_exempt
def summarizeToFlashcards(request):
    data = json.loads(request.body)
    print(data)
    summarizerContainerObj = summarizerv2.summarizerContainer()
    flashcardsDict = summarizerContainerObj.generate_flashcards(data.get("text"))
    
    jsonSend = {}
    if request.method == "POST":
        
        for i in flashcardsDict:
            
            #print(f"HERE BE FLASHCARD EACH {repr(i)}")
    

            flashcard_data = {
                    'authToken': data.get('authToken'),
                    'topic': i,
                    'title': 'GenCard',
                    'text': flashcardsDict[i]
                }

        

            

            flashcard = FlashcardsManager.create_flashcard_from_dict(flashcard_data) 
            flashcard.save() 

            #what in the spaghetti code
    return JsonResponse({"message" : "Operation Finished Successfully"},  status = 200)



@csrf_exempt
def questionGenerate(request):
    summarizerContainerObj = summarizerv2.summarizerContainer()
    mcqDict = summarizerContainerObj.generate_questions(json.loads(request.body)['topic']) #quesiton+answer block + the corresponding right option

    if len(mcqDict) < 3:
        return JsonResponse({"error" : "Failed Question Generation"}, status = 400)
    
    #print(mcqDict)

    return JsonResponse({"questions" : mcqDict}, status = 200)


@csrf_exempt
def login(request):
    

    if request.method == "POST":
        data = json.loads(request.body)
        name = data.get('username')
        passKey = data.get('password')
         

        if not User.objects.filter(username=name).exists(): #user doesn't exist

            return JsonResponse({"error" : "Invalid User"}, status = 400)

        user = authenticate(username=name, password=passKey) #
         
        if user is None: #This stupid thing is going to make me work with json 

            return JsonResponse({"error" : "Invalid Pass"},  status = 400)
        
        else:

            refresh = RefreshToken.for_user(user)
            csrf_token = get_token(request)

            return JsonResponse({"accessToken" : str(refresh.access_token), "message" : "Authenticated Successfully", "csrfToken" : csrf_token},  status = 200)
     

@csrf_exempt
def logout(request):
    print(f"Logout request received: {request.method}")
    
    if request.method == "POST":
        try:
            auth_header = request.META.get("HTTP_AUTHORIZATION", "")
            print(f"Authorization Header: {auth_header}")  # Log the header

            if not auth_header or not auth_header.startswith("Bearer "):
                return JsonResponse({"error": "Invalid token"}, status=400)

            token = auth_header.split(" ")[1]
            jwt_auth = JWTAuthentication()
            validated_token = jwt_auth.get_validated_token(token)  # Validate the token
            
            # Blacklist the token
            BlacklistedToken.objects.create(token=validated_token)

            return JsonResponse({"message": "Logged out successfully"}, status=205)  # No content to send back
        except Exception as e:
            print(f"Error during logout: {str(e)}")  # Log the exception
            return JsonResponse({"error": str(e)}, status=400)

@csrf_exempt
def registerUser(request):
    if request.method == "POST":
        data = json.loads(request.body)
        name = data.get('username')
        passKey = data.get('password')

        user = User.objects.create_user(username = name, password = passKey) #stores a nice hashed pass so I don't have to muck about with SDAs
        user.save() #should register, have a check to check for existing accounts
        return JsonResponse({"message" : "Registered Successfully"},  status = 200)
        #hopefully this saves it over in the DB


    else:
        return JsonResponse({"error" : "Registration Failed Due To Unspecified Reasons"},  status = 400)


@api_view(['POST'])
@csrf_exempt
def getUserInfo(request):

    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON"}, status=400)

    token = data.get('authToken')
    
    if not token:
        return JsonResponse({"error": "Token not provided"}, status=400)

    try:

        userID = AccessToken(token)['user_id']
    except Exception as e:

        return JsonResponse({"error": "Invalid or expired token"}, status=401)

    try:

        user = User.objects.get(id=userID)
    except User.DoesNotExist:
        return JsonResponse({"error": "User not found"}, status=404)

    username = user.username
    return JsonResponse({'username': username}, status=200)


@api_view(['POST'])
@csrf_exempt
def registerFlashcard(request):
    if request.method == "POST":
        flashcard = FlashcardsManager.create_flashcard(request) 
        flashcard.save() 
        ''' data = json.loads(request.body)

        userid = data.get('user_id')
        title = data.get('title')
        topic = data.get('topic')
        text = data.get('topic')'''

        

        return JsonResponse({"message" : "Flashcard Created Successfully"},  status = 200)
        #hopefully this saves it over in the DB


    else:
        return JsonResponse({"error" : "Flashcard Creation Failed Due To Unspecified Reasons"},  status = 400)
    

@api_view(['POST'])
@csrf_exempt
def getFlashcards(request):
    if request.method == "POST":
        data = json.loads(request.body)

        token = data.get('authToken')
        userID = AccessToken(token)['user_id']
        print(userID)
       
        


        flashcards = FlashcardsManager.get_flashcards(userID)
        flashcardsArr = [{'topic' : i.topic, 'title' : i.title , 'text' : i.text, 'flashID' :i.id } for i in flashcards]
        print(flashcardsArr)

        return JsonResponse({"flashcards" : flashcardsArr},  status = 200)

        #get back to this later, need to find out how to provide a JSON file of all flashcards and use a listBuilder to build them

    else:
        return JsonResponse({"error" : "Unspecified Error"},  status = 400)
    

@api_view(['POST'])
@csrf_exempt
def getFlashcard(request):
    if request.method == "POST":
        data = json.loads(request.body)
        token = data.get('authToken')
        userID = AccessToken(token)['user_id']
        flashcardIndex = data.get('flashcardIndex')


        flashcard = FlashcardsManager.get_flashcard(userID, flashcardIndex) #array wiht one ele just for a consistent interface
        flashcardsArr = [{'topic' : flashcard.topic, 'title' : flashcard.title , 'text' : flashcard.text, 'flashID' : flashcard.id}]

        print(flashcardsArr)

        return JsonResponse({"flashcards" : flashcardsArr},  status = 200)


    else:
        return JsonResponse({"error" : "Unspecified Error"},  status = 400)
    


@api_view(['POST'])
@csrf_exempt
def deleteFlashcard(request):
    if request.method == "POST":
        data = json.loads(request.body)
        
        token = data.get('authToken')
        userID = AccessToken(token)['user_id']
        flashID = data.get('flashID')
        print(flashID)
        print("delete run debug check")

        flashcard = FlashcardsManager.delete_flashcard(userID, flashID) #wipes
        

        return JsonResponse({"status" : "Successfully deleted"},  status = 200)


    else:
        return JsonResponse({"error" : "Unspecified Error"},  status = 400)
    

@api_view(['POST'])
@csrf_exempt
def updateFlashcard(request):
    if request.method == "POST":
        data = json.loads(request.body)
        
        token = data.get('authToken')
        userID = AccessToken(token)['user_id']
        flashID = data.get('flashID')
        
        topicCard = data.get("topic")
        titleCard = data.get("title")
        textCard = data.get("text")


        flashcard = FlashcardsManager.update_flashcard(userID, flashID, topic = topicCard, title = titleCard, text = textCard) #wipes
        

        return JsonResponse({"status" : "Successfully updated"},  status = 200)


    else:
        return JsonResponse({"error" : "Unspecified Error"},  status = 400)