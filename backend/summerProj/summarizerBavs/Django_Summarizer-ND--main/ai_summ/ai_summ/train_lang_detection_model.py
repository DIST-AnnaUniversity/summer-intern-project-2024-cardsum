import pandas as pd
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline
from sklearn.metrics import classification_report
import pickle

# Load the dataset from a JSON file
data = pd.read_json('Language_Detection.json') 

def clean_text(text):
    text = re.sub(r'\s+', ' ', text)  #squeaky clean
    text = text.strip()                
    return text


data['Text'] = data['Text'].apply(clean_text)


X_train, X_test, y_train, y_test = train_test_split(data['Text'], data['Language'], test_size=0.2, random_state=42)


model = make_pipeline(CountVectorizer(), MultinomialNB())


model.fit(X_train, y_train)


predictions = model.predict(X_test)


print(classification_report(y_test, predictions))

with open('lang_detection_model.pkl', 'wb') as f:
    pickle.dump(model, f)

print("Saved model")

# Function to predict language
def predict_language(text):
    return model.predict([text])[0]


