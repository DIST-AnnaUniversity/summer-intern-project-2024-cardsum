import 'package:flutter/material.dart';
import 'dart:convert';  // For JSON encoding/decoding
import 'package:http/http.dart' as http;

class MCQPage extends StatefulWidget {
  const MCQPage({super.key});

  @override
  _MCQPageState createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> {
  final List<Map<String, dynamic>> _questions = [];
  final List<String?> _selectedAnswers = [];
  final List<bool?> _isCorrect = [];
  final TextEditingController _topicController = TextEditingController();
  int _correctAnswersCount = 0;  

  void _generateQuestions(String topic) async {
    print("Inside q generator");
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/questionGenerate/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topic,  
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData);

      Map<String, dynamic> questionsFromApi = jsonData['questions'];
    
      print("before setState");
      setState(() {
        _questions.clear();
        _selectedAnswers.clear();
        _isCorrect.clear();
        _correctAnswersCount = 0; 

        questionsFromApi.forEach((question, answersMap) {
          answersMap.forEach((choiceKey, correctAnswerValue) {
            final choices = choiceKey.split('\n')..removeAt(0); 

            _questions.add({
              'question': question,  
              'choices': choices,    
              'correctAnswer': correctAnswerValue, 
            });

   
            _selectedAnswers.add(null); 
            _isCorrect.add(null);
          });
        });
      });
    } else {
      print("Error: Failed to generate questions. Status Code: ${response.statusCode}");
    }
  }

  void _submitAnswer(int questionIndex) {
    final correctAnswer = _questions[questionIndex]['correctAnswer'].trim();
    final userAnswer = _selectedAnswers[questionIndex]!.trim();

    setState(() {
      _isCorrect[questionIndex] = (userAnswer.substring(0, 4) == correctAnswer.substring(0, 4));  // Evil hack
      
  
      if (_isCorrect[questionIndex] == true) {
        _correctAnswersCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 21, 21, 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final topic = _topicController.text.trim();
                if (topic.isNotEmpty) {
                  _generateQuestions(topic);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 81, 81, 163),
                padding: const EdgeInsets.all(12),
              ),
              child: Text(
                'Generate Questions',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: const Color.fromARGB(255, 221, 219, 255), height: 1.3, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _questions.isEmpty
                  ? const Text(
                      'No questions available. Enter text and click "Generate Questions".',
                      style: TextStyle(color: Colors.white),
                    )
                  : ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];

                        return Card(
                          color: const Color.fromARGB(255, 23, 23, 31),
                          margin: const EdgeInsets.all(32.0),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  question['question'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: List<Widget>.generate(
                                    question['choices'].length,
                                    (choiceIndex) {
                                      final choice = question['choices'][choiceIndex];
                                      return RadioListTile<String>(
                                        title: Text(
                                          choice,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        value: choice,
                                        groupValue: _selectedAnswers[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedAnswers[index] = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _submitAnswer(index),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(36, 45),
                                    backgroundColor: const Color.fromARGB(255, 81, 81, 163),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: const Color.fromARGB(255, 221, 219, 255),
                                          height: 1.3,
                                          fontSize: 20,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (_isCorrect[index] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _isCorrect[index] == true
                                        ? 'Correct!'
                                        : 'Wrong! The correct answer is: ${question['correctAnswer']}',
                                    style: TextStyle(
                                      color: _isCorrect[index] == true ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Number of correct answers: $_correctAnswersCount / ${_questions.length}',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(
                    color: const Color.fromARGB(255, 221, 219, 255),
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark,
    ),
    home: const MCQPage(),
  ));
}
