import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:summer_proj_app/preferenceUtils.dart';
import 'flashcardsPage.dart';


class viewCardsPage extends StatefulWidget {
  const viewCardsPage({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<viewCardsPage> {
  Future<List<Map<String, dynamic>>> fetchFlashcards() async {

  String token = PreferenceUtils.getString("authToken");
  final url = Uri.parse('http://127.0.0.1:8000/getFlashcards/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({
      "authToken" : token,

    })
    
  );
  

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> flashcardsData = data['flashcards'];
      print(flashcardsData);
      return List<Map<String, dynamic>>.from(flashcardsData);
    } else {
      throw Exception('Failed to load flashcards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFlashcards(), // Replace with actual userId






        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());



          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));

            
          } 
          
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No flashcards found'));
          }
          
          
           else {
            final flashcards = snapshot.data!;
            return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Number of items per row
      crossAxisSpacing: 1.0, // Space between items in a row
      mainAxisSpacing: 1.0, // Space between rows
      childAspectRatio: 1.0, // Ratio of width to height of each item
    ),
    itemCount: flashcards.length,
    itemBuilder: (context, index) {
      final flashcard = flashcards[index];
      return 
         FlashcardScreen(
          title: flashcard['title'], 
          topic: flashcard['topic'], 
          text: flashcard['text'],
          flashID: flashcard['flashID'],
        );
    },
  );
          }
        },
      ),
    );
  }
}