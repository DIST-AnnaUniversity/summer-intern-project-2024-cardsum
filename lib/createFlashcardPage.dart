import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'dbUtils.dart';


class CreateFlashCard extends StatefulWidget {
  const CreateFlashCard({super.key});

  @override
  _CreateFlashCardState createState() => _CreateFlashCardState();
}

class _CreateFlashCardState extends State<CreateFlashCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

 

  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              
              children: [
                Container(decoration: const BoxDecoration(color: Color.fromARGB(255, 21, 21, 21)),
                
                  child: Center(
                          
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left:256,right:256, bottom: 256),
                              child: Column(
                                children: [ const Text("Enter Flashcard Details Here", selectionColor: Color.fromARGB(255, 255, 255, 255), style: TextStyle(color:  Color.fromARGB(255,255,255,255), fontSize: 48, fontFamily: 'Raleway', fontWeight: FontWeight.w300),),
                                const SizedBox(height: 56 ),
                                  Form(
                                   
                                    child: Column(
                                      children: [
                                        RoundedTextFormField(
                                          obscureText: false,
                                          controller: _titleController,
                                          labelText: 'Title',
                                          hintText: 'Enter flashcard title here',
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a title';
                                            }
                                            return null;
                                          },
                                        ),
                    
                    
                                        const SizedBox(height: 40),
                                        RoundedTextFormField(
                                          obscureText: false,
                                          controller: _topicController,
                                          labelText: 'Topic',
                                          hintText: 'Enter flashcard topic here',
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter flashcard topic';
                                            }
                                            return null;
                                          },
                    
                    
                                        ),
        
        
                                        const SizedBox(height: 40),
                                        RoundedTextFormField(
                                          obscureText: false,
                                          controller: _textController,
                                          labelText: 'Text',
                                          hintText: 'Enter flashcard text here',
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter flashcard text';
                                            }
                                            return null;
                                          },
                    
                    
                                        ),
                                       
                                       
                                        const SizedBox(height: 40),
                                         ElevatedButton(
                                    
                                          onPressed: () => createFlashcard(_topicController.text, _titleController.text, _textController.text),
                                          style: ElevatedButton.styleFrom(backgroundColor:  const Color.fromARGB(255, 99, 81, 159), minimumSize: const Size(180, 40)),
                                          child: Text('Submit',style: Theme.of(context).textTheme.bodyMedium,),
                                        ),
                    
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                  
              
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TextBox extends StatelessWidget 
{

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
            color: const Color.fromARGB(255,21,21,20),
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
                    return Padding(
                      padding: const EdgeInsets.only(left: 32, top: 16),
                      child: (index % 2 == 0)  ?  Text("> ${_messages[index]}" , style: DefaultTextStyle.of(context).style.copyWith(color: const Color.fromARGB(255, 99, 81, 159)) ) : Text( _messages[index] ,),
                    );
                  },
                ),
        ),
      ),
    );
  }
}



class UserInputField extends StatelessWidget {
  const UserInputField({
    super.key,
    required TextEditingController controller,
    required void Function(String) handleSubmitted,
  }) : _controller = controller, _handleSubmitted = handleSubmitted;
  

  final TextEditingController _controller;
  final void Function(String) _handleSubmitted;
 



  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            style: Theme.of(context).textTheme.labelMedium!.copyWith(height: 1.5),
            
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255,21,21,20),
              
            
              hintText: 'Enter your message here',
              hintStyle: Theme.of(context).textTheme.labelMedium,
              border: const OutlineInputBorder(borderRadius : BorderRadius.all(Radius.circular(12.0))),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null, // Allows the input field to be scrollable
            onSubmitted: (text) => _handleSubmitted(text),
            
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => _handleSubmitted(_controller.text),
        ),
      ],
    );
  }
}
