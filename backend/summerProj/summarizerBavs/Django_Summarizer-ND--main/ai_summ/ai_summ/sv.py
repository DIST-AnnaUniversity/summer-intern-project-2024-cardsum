import spacy 
import pandas as pd

from spacy.lang.en.stop_words import STOP_WORDS
from string import punctuation
from heapq import nlargest
from openai import OpenAI





import pickle
from heapq import nlargest
from spacy.lang.fr.stop_words import STOP_WORDS as FRENCH_STOP_WORDS
from spacy.lang.en.stop_words import STOP_WORDS as ENGLISH_STOP_WORDS
from spacy.lang.es.stop_words import STOP_WORDS as SPANISH_STOP_WORDS


def load_model(path):
    with open(path, "rb") as f:
        model = pickle.load(f)

    return model


def predict_language(text, model):
    return model.predict([text])[0]


model = load_model("ai_summ/lang_detection_model.pkl")
nlp_french = spacy.load("fr_core_news_sm")
nlp_english = spacy.load("en_core_web_sm")
nlp_spanish = spacy.load("es_core_news_sm")

def text_summarizer(text, language):
    if text is None or len(text.strip()) == 0:
        return "No content to summarize."

    # Select the appropriate NLP model and stopwords based on the language
    if language == 'French':
        nlp = nlp_french
        stopwords = list(FRENCH_STOP_WORDS)
    elif language == 'English':
        nlp = nlp_english
        stopwords = list(ENGLISH_STOP_WORDS)
    elif language == 'Spanish':
        nlp = nlp_spanish
        stopwords = list(SPANISH_STOP_WORDS)
    else:
        return "Unsupported language."

    docx = nlp(text)
    word_frequencies = {}

    for word in docx:
        if word.text.lower() not in stopwords and word.is_alpha:
            word_frequencies[word.text.lower()] = word_frequencies.get(word.text.lower(), 0) + 1

    if not word_frequencies:
        return "No valid words to summarize."

    maximum_frequency = max(word_frequencies.values())

    for word in word_frequencies.keys():
        word_frequencies[word] /= maximum_frequency

    sentence_list = [sentence for sentence in docx.sents]
    sentence_scores = {}

    for sent in sentence_list:
        for word in sent:
            if word.text.lower() in word_frequencies.keys():
                if len(sent.text.split(' ')) < 30:
                    sentence_scores[sent] = sentence_scores.get(sent, 0) + word_frequencies[word.text.lower()]

    if not sentence_scores:
        return "No sentences to summarize."

    summarized_sentences = nlargest(7, sentence_scores, key=sentence_scores.get)
    final_sentences = [w.text for w in summarized_sentences]
    summary = ' '.join(final_sentences)

    # Assuming summarizerContainer is defined elsewhere
    #summarizerContainerObj = summarizerContainer(clientObj)
    #summarizerContainerObj.generate_questions(summary)

    return summary


class summarizerContainer():
    
    def __init__(self): #pass a client handle to an instance of this
        
        self.questionsDict = {} #really shouldn't be here
        self.points=0
        self.clientObj = OpenAI()

    #TEXT SUMMARIZER CODE USING SPACY
    
    #QUESTION GENERATOR USING OPEN AI HERE
   
    def generate_questions(self, text,language):
        """
        Reads text from a file, sends it to OpenAI, and generates multiple-choice
        questions testing reading comprehension on the topic.
        """
       
        if text is None:
            return

        completion = self.clientObj.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You will be provided with a big text. You must then generate several multiple-choice questions testing one's reading comprehension on that topic. There should be 4 choices. In the final line should be the answer from one of the four choices. So totally 6 lines of text. Generate atleast five questions"},
                {"role": "user", "content": text},
            ]
        )

        questions = completion.choices[0].message.content.split("\n\n")
        #print(f"Comprehension Questions:\n")
        totalText = ''
        mcqDict = {}
        for question in questions:
            lines = question.strip().splitlines()
            #print(lines)


            if len(lines) < 3:
                print(f"Error: Invalid question format: {question}")
                continue


            question_text = lines[0]
            choices = lines[1:-1]
            option = lines[-1].split(": ")[-1]

            
            #print(option[0])
            #print(f"{question_text}")
            totalText = question_text
            choiceText = ''
            for i, choice in enumerate(choices):
                choiceText += "\n" + choice


            mcqDict[totalText] = {choiceText : option}
            
            

        return mcqDict
        
    def generate_flashcards(self, text, num_flashcards=5):
 
        if text is None:
            return {}

        completion = self.clientObj.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": f"""You will be provided with a large text. You have to detect the language and then generate exactly {num_flashcards} flashcards. Each card should provide a topic and a content summary in that language.The topic can be any keyword from the text and the summary should  be 5 lines about the topic the topic.

    Use only plain text throughout. Separate the topic and summary with a newline."""},
                {"role": "user", "content": text},
            ]
        )

        flashcards = completion.choices[0].message.content.split("\n\n")
        
        flashcards_dict = {}
        for card in flashcards:
            lines = card.strip().split("\n")
            if len(lines) >= 2:
                topic = lines[0].strip()
                summary = lines[1].strip()
                flashcards_dict[topic] = summary

        return flashcards_dict




