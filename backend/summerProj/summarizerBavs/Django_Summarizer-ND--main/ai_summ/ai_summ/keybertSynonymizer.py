from keybert import KeyBERT
import nltk
from nltk.corpus import wordnet


#nltk.download('wordnet') //already done lol



def get_synonyms(word):
    synonyms = set()  
    for syn in wordnet.synsets(word):  
        for lemma in syn.lemmas():  
            synonyms.add(lemma.name()) 
    return list(synonyms)



def extract_keywords(text, accuracy=5):
    kw_model = KeyBERT()  # Use the default model
    keywords = kw_model.extract_keywords(text, top_n=accuracy, use_mmr=True)


    keywordSynonymDict = {}
    for keyword, score in keywords:
        #print(f"\nKeyword: {keyword}")
        keywordSynonymDict[keyword] = []
        synonyms = get_synonyms(keyword)  
        if synonyms:
            #print("Synonyms:")
            for synonym in synonyms:
                keywordSynonymDict[keyword].append(synonym)
        else:
             keywordSynonymDict[keyword].append("NA")

    return keywordSynonymDict


   



#print(extract_keywords("""In a pipelined computer, instructions flow through the central processing unit (CPU) in stages. For example, it might have one stage for each step of the von Neumann cycle: Fetch the instruction, fetch the operands, do the instruction, write the results. A pipelined computer usually has "pipeline registers" after each stage. These store information from the instruction and calculations so that the logic gates of the next stage can do the next step.
#This arrangement lets the CPU complete an instruction on each clock cycle. It is common for even-numbered stages to operate on one edge of the square-wave clock, while odd-numbered stages operate on the other edge. This allows more CPU throughput than a multicycle computer at a given clock rate, but may increase latency due to the added overhead of the pipelining process itself. Also, even though the electronic logic has a fixed maximum speed, a pipelined computer can be made faster or slower by varying the number of stages in the pipeline. With more stages, each stage does less work, and so the stage has fewer delays from the logic gates and could run at a higher clock rate"""))