import nltk
from nltk.tokenize import sent_tokenize
import spacy
from collections import Counter

def preprocess_text(text):
    """
    Preprocesses text by tokenizing into sentences and lowercasing.
    """
    sentences = sent_tokenize(text)
    sentences = [sentence.lower() for sentence in sentences]  # Lowercase for case-insensitive processing
    return sentences

def get_hotwords(sentences, hotword_tags=('NOUN', 'VERB', 'ADJ')):
    """
    Identifies words with desired POS tags (hotwords) from each sentence.
    """
    nlp = spacy.load("en_core_web_sm")  # Load spaCy model
    hotwords = []
    for sentence in sentences:
        doc = nlp(sentence)
        sentence_hotwords = [token.text for token in doc if token.pos_ in hotword_tags]
        hotwords.extend(sentence_hotwords)
    return Counter(hotwords)  # Count word frequency for ranking

def rank_sentences(sentences, hotwords):
    """
    Ranks sentences based on the frequency of their hotwords.
    """
    sentence_scores = {sentence: 0 for sentence in sentences}
    for sentence in sentences:
        words = sentence.split()
        for word in words:
            if word in hotwords:
                sentence_scores[sentence] += hotwords[word]
    return sorted(sentence_scores.items(), key=lambda x: x[1], reverse=True)  # Sort by score (descending)

def summarize_text(text, num_sentences=10):
    """
    Summarizes text by selecting the top-ranked sentences based on hotword frequency.
    """
    sentences = preprocess_text(text)
    hotwords = get_hotwords(sentences)
    ranked_sentences = rank_sentences(sentences, hotwords)
    summary = ' '.join([sentence for sentence, _ in ranked_sentences[:num_sentences]])
    return summary

# Example usage




def generate_questions(summary):
  """
  Generates questions based on the provided summary text.
  This is a simple rule-based approach, you can customize it further.
  """
  questions = []

  # Identify keywords/phrases and formulate questions
  for phrase in ["heat stress", "labor markets", "outdoor workers", "productivity", "economic losses"]:
    if phrase in summary:
      questions.append(f"How does {phrase} impact the world of work?")

  # Questions based on identified impacts
  impacts = ["reduced productivity", "increased health risks", "shifts in labor demand"]
  for impact in impacts:
    if impact in summary:
      questions.append(f"What are the {impact} associated with heat stress in labor markets?")

  # Return generated questions
  return questions

# Summarize the text





