import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:summer_proj_app/preferenceUtils.dart'; 
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  // Add this to _ChatScreenState




  Future fetchData(String userBody, String language) async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/summarize/'), body:  jsonEncode({
      'userBody' : userBody,
      'language' : language

    }),);

    
    if (response.statusCode == 200) {
    
      return response.body;
    }
    
     else 
     {
      
      return 'Failed to load data. Try again';
    }
  }


  Future fetchDataWithKeywords(String userBody, String language) async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/summarizeSynonym/'), body:  jsonEncode({
      'userBody' : userBody,
      'language' : language

    }));
    if (response.statusCode == 200) {

      return response.body;
    }
    
     else 
     {
      
      return 'Failed to load data. Try again';
    }
  }


   Future fetchDataSimple(String userBody) async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/simpleSummary/'), body: userBody);
    if (response.statusCode == 200) {

      return response.body;
    }
    
     else 
     {
      
      return 'Failed to load data. Try again';
    }
  }




  void _handleSubmitted(String text, bool isGenerateCards, bool isGenerateKeywords, bool isSimple, String language) async {

  
  
  String result = '';
  if (!isGenerateKeywords)
  {
    result = await fetchData(text, language);
  }

  else if (isGenerateKeywords)
  {
    result = await fetchDataWithKeywords(text, language);
  }

  if (isGenerateCards)
  {
    String token = PreferenceUtils.getString("authToken");
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/summarizeToFlashcards/'), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({
          "authToken": token, 
          "text": text,        
          "result": result,    
        }),);
  }

  if (isSimple)
  {
    result = await fetchDataSimple(text);
  }


  if (text.isNotEmpty) {
    _controller.clear();
    setState(() {
      _messages.add(text);
      _messages.add(result);
    });

  
  }
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color.fromARGB(255,21,21,20),
      
      body: Column(
        children: <Widget>[

          TextBox(messages: _messages),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserInputField(controller: _controller, handleSubmitted: _handleSubmitted
             ,),
          ),
        ],
      ),
    );
  }
}

class TextBox extends StatelessWidget {
  const TextBox({
    super.key,
    required List<String> messages,
  }) : _messages = messages;

  final List<String> _messages;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 21, 21, 20),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'Nothing here yet! Get typing!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final isUserMessage = (index % 2 == 0);
                    return Container(
                      margin: const EdgeInsets.all(32),
                      child: ChatBubble(
                        title: isUserMessage ? 'User' : 'Response',
                        message: _messages[index],
                              
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}



class UserInputField extends StatefulWidget {
  const UserInputField({
    super.key,
    required this.controller,
    required this.handleSubmitted,
  });

  final TextEditingController controller;
  final void Function(String, bool, bool, bool, String) handleSubmitted;

  @override
  _UserInputFieldState createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  bool _isCardSelected = false;
  bool _isKeySelected = false;
  bool _isChildSelected = false;
  String _selectedLanguage = "English";  // Default selected language

  void _toggleCardIcon() {
    setState(() {
      _isCardSelected = !_isCardSelected;
    });
  }

  void _toggleKeyIcon() {
    setState(() {
      _isKeySelected = !_isKeySelected;
    });
  }

  void _toggleChildIcon() {
    setState(() {
      _isChildSelected = !_isChildSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Dropdown for language selection
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 21, 21, 20),
            borderRadius: BorderRadius.circular(12.0),  
            border: Border.all(color: Colors.grey),  
          ),
          child: DropdownButton<String>(
            value: _selectedLanguage,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: Container(),  //wipe ze underline
            dropdownColor: const Color.fromARGB(255, 21, 21, 20),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white),

            items: <String>['English', 'French', 'Spanish', 'Auto-Detect'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );



            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
          ),
        ),
        const SizedBox(width: 8),  // Space between dropdown and text field

        // Input text field
        Expanded(
          child: TextField(
            style: Theme.of(context).textTheme.labelMedium!.copyWith(height: 1.5),
            controller: widget.controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 21, 21, 20),
              hintText: 'Enter your message here',
              hintStyle: Theme.of(context).textTheme.labelMedium,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
        
        // Icons for toggling
        IconButton(
          icon: Icon(Icons.card_membership, color: _isCardSelected ? Colors.blue : Colors.grey),
          onPressed: _toggleCardIcon,
        ),
        IconButton(
          icon: Icon(Icons.vpn_key, color: _isKeySelected ? Colors.blue : Colors.grey),
          onPressed: _toggleKeyIcon,
        ),
        IconButton(
          icon: Icon(Icons.child_care, color: _isChildSelected ? Colors.blue : Colors.grey),
          onPressed: _toggleChildIcon,
        ),
        
        // Send button
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => widget.handleSubmitted(widget.controller.text, _isCardSelected, _isKeySelected, _isChildSelected, _selectedLanguage),
        ),
      ],
    );
  }
}



class ChatBubble extends StatelessWidget {
  final String message;
  final String title; // Added title field

  const ChatBubble({
    super.key,
    required this.message,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Align(
        alignment: Alignment.centerLeft, // Right alignment for user
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1200, // Maximum width for the bubble
          ),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: (title == "User") ? const Color.fromARGB(255, 99, 81, 159) : const Color.fromARGB(255, 51, 51, 53),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4), 
              const Divider(thickness: 1, color: Colors.black38), 
              const SizedBox(height: 8), 
              Text(
                message, 
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color:  (title == "User") ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255), height: 1.3, fontSize: 20),
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
