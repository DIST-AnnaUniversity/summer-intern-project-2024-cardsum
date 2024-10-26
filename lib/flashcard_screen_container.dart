import 'package:flutter/material.dart';
import 'package:summer_proj_app/dbUtils.dart';
import 'package:summer_proj_app/flashcardsPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:summer_proj_app/preferenceUtils.dart'; 
import 'loginPage.dart';


class FlashcardScreenContainer extends StatefulWidget {
  const FlashcardScreenContainer({
    super.key,
  });

  @override
  State<FlashcardScreenContainer> createState() => _FlashcardScreenContainerState();
}

class _FlashcardScreenContainerState extends State<FlashcardScreenContainer> {
  int index = 0;
  int flashID = 0;

  Future<List<Map<String, dynamic>>> fetchFlashcard() async {
    String token = PreferenceUtils.getString("authToken");
    final url = Uri.parse('http://127.0.0.1:8000/getFlashcard/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "authToken": token,
        "flashcardIndex": index,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> flashcardsData = data['flashcards'];
      return List<Map<String, dynamic>>.from(flashcardsData);
    } else {
      throw Exception('Failed to load flashcards');
    }
  }

  void updateIndex(int inc) {
    setState(() {
      index += inc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlashcardContent(
      fetchFlashcard: fetchFlashcard,
      updateIndex: updateIndex,
 
    );
  }
}


class FlashcardContent extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchFlashcard;
  final void Function(int) updateIndex;


  const FlashcardContent({super.key, 
    required this.fetchFlashcard,
    required this.updateIndex,

  });

  @override
  State<FlashcardContent> createState() => _FlashcardContentState();
}

class _FlashcardContentState extends State<FlashcardContent> {
  int flashID = 0;


  void _showEditForm(BuildContext context) {
    final TextEditingController topicController =
        TextEditingController();
    final TextEditingController titleController =
        TextEditingController();
    final TextEditingController textController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 21, 21, 21),
          title: Text('Edit Flashcard', style: Theme.of(context).textTheme.bodyMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundedTextFormField(controller: topicController, labelText: 'Topic', hintText: "Enter Your Topic Here", obscureText: false,),
                const SizedBox(height: 30),

                RoundedTextFormField(controller: titleController, labelText: 'Title', hintText: "Enter Your Title Here", obscureText: false,),
                const SizedBox(height: 30),

                RoundedTextFormField(controller: textController, labelText: 'Text', hintText: "Enter Your Text Here", obscureText: false,),
                const SizedBox(height: 30),
               
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style : Theme.of(context).textTheme.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                setState(() {flashID = flashID;});
                updateFlashcard(flashID,topicController.text, titleController.text, textController.text);
                Navigator.of(context).pop(); // Close the dialog after submission
              },
              child: Text('Submit', style : Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.updateIndex(-1);
                  deleteFlashcard(flashID);
                  setState(() {flashID = flashID;}); //a bs to force a rerender id hate if a new flutter version optimizes this out
                 
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(36, 45),
                  backgroundColor: const Color.fromARGB(255, 81, 81, 163),
                  padding: const EdgeInsets.all(12),
                ),


                child: Text(
                  'Delete Flashcard',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: const Color.fromARGB(255, 221, 219, 255), height: 1.3, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 180),

              
              IconButton.filled(
                onPressed: () {
                  widget.updateIndex(-1);
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ],
          ),
          const SizedBox(width: 30),


          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: widget.fetchFlashcard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No flashcards found'));
                  } else {
                    final flashcard = snapshot.data![0];
                    flashID = flashcard['flashID'];
                    print(flashID);

                    return FlashcardScreen(
                      title: flashcard['title'],
                      topic: flashcard['topic'],
                      text: flashcard['text'],
                      flashID: flashcard['flashID'],
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => print("Placeholder"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(36, 45),
                  backgroundColor: const Color.fromARGB(255, 81, 81, 163),
                  padding: const EdgeInsets.all(12),
                ),
                child: Text(
                  'Regenerate Text',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: const Color.fromARGB(255, 221, 219, 255), height: 1.3, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(width: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _showEditForm(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(36, 45),
                  backgroundColor: const Color.fromARGB(255, 81, 81, 163),
                  padding: const EdgeInsets.all(12),
                ),
                child: Text(
                  'Edit Flashcard',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: const Color.fromARGB(255, 221, 219, 255), height: 1.3, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 180),
              IconButton.filled(
                onPressed: () {
                  widget.updateIndex(1);
                },
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }
}
