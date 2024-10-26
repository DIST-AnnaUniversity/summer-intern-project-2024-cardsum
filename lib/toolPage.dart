
import 'package:flutter/material.dart';
import 'package:summer_proj_app/flashcard_screen_container.dart';
import 'package:summer_proj_app/questionPage.dart';
import 'summarizerPage.dart';
import 'createFlashcardPage.dart';
import 'viewCardsPage.dart';





class toolPage extends StatefulWidget
{
  const toolPage({super.key});

  @override
  State<toolPage> createState() => _toolPageState();
}

class _toolPageState extends State<toolPage> {
  int selectedIndex = 0;
  String dbName = "Not Logged In/Loading: ";


  @override
  Widget build(BuildContext context)
  
  {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page =  const viewCardsPage();
        break;
      case 1:
        page =  const FlashcardScreenContainer();
        break;
      
      case 2:
        page = const ChatScreen();
        break;

      case 3:
        page = const CreateFlashCard();
        break;

      case 4:
        page = const MCQPage();
 

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }




    return Expanded(
      child: Row(children: 
        [
          NavigationRail(
            extended: true,
            leading:  Container(
                    
                    height: 128,
                    width: 128, //disgusting magic number
                    decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/cardsumLogo.png"), fit: BoxFit.fill))),
            
            backgroundColor:  const Color.fromARGB(255, 23, 23, 31),
            
            destinations: [
            NavigationRailDestination(icon: const Icon(Icons.sticky_note_2), label: Text("View Cards", style: Theme.of(context).textTheme.bodyMedium)),
            NavigationRailDestination(icon: const Icon(Icons.recycling), label: Text("Edit Cards", style: Theme.of(context).textTheme.bodyMedium)),
            NavigationRailDestination(icon: const Icon(Icons.recycling), label: Text("Summarize Text", style: Theme.of(context).textTheme.bodyMedium)),
            NavigationRailDestination(icon: const Icon(Icons.recycling), label: Text("Create Flashcard", style: Theme.of(context).textTheme.bodyMedium)),
            NavigationRailDestination(icon: const Icon(Icons.question_mark), label: Text("Question Zone", style: Theme.of(context).textTheme.bodyMedium))
            ], selectedIndex: selectedIndex, onDestinationSelected: (value) {setState(()
            {
              selectedIndex = value;
            });
            
            },), 
        
        Expanded(child: Container( 
          color: const Color.fromARGB(255, 21, 21, 21,), 
          child: page  ),)]),
    );
  }
}
