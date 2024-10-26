import 'package:flutter/material.dart';
import 'toolPage.dart';
import 'loginPage.dart';
import 'package:summer_proj_app/preferenceUtils.dart';
import 'package:summer_proj_app/dbUtils.dart';



class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  final int _tabIndex = 0; //this lil guy helps us swap pages!!
  Widget displayedPage = const homePageWidget(); //nice default lad


  void _swapWidgetCallback(int index)
  {
    setState(()
    {
      switch (index)
      {
        case 0:
          displayedPage = const LoginForm();
          break;
        
        case 1:
          displayedPage = const toolPage();
          break;

        case 2:
          String authToken = PreferenceUtils.getString("authToken");
          

          String csrfToken = PreferenceUtils.getString("csrfToken");
          logout(authToken, csrfToken);
          displayedPage = const LoginForm();
          break;

        case 3:
          displayedPage = const homePageWidget();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color.fromARGB(255, 21, 21, 21),
    
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          
          mainAxisSize: MainAxisSize.max,
          children: [ 
          homePageNavBar( _swapWidgetCallback),
          displayedPage,
         
            /*ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Exit Placeholder'),
            ),*/
          ],
        ),
      ),
    );
  }
}

class homePageWidget extends StatelessWidget {
  const homePageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: SingleChildScrollView(child: scrollableHome()));
  }
}

class scrollableHome extends StatelessWidget {
  const scrollableHome({
    super.key,
  });
  

  @override
  Widget build(BuildContext context) {
    return Container( 
      
      
      color: const Color.fromARGB(255, 21, 21, 21),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
              Text("Revolutionize Your Learning. Here & Now.", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Text("""Leave the tech stuff to us. We make learning simple and effective for you.\n
          How do we do it you ask? You give us the material, we chop it up and make it easy for you.""", 
              style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
          
              const SizedBox(height: 30),
              ElevatedButton(onPressed: () => print("Skibidi"), child: const Text("Get Started", )),
          
              const SizedBox(height: 30),
              Container(
                
                height: 500, //disgusting magic number
                decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/flashcardsMock.png"), fit: BoxFit.contain))),
              
              
              Text("Here is a nifty tool, our AI-powered flashcards.", style: Theme.of(context).textTheme.headlineMedium,  textAlign: TextAlign.center),
              
              const SizedBox(height: 30),
              Text("""Summarizes your documents into bite-sized cards? Check.\n
Integrated with quizlets? Check.\n
Saveable for offline use? Check.""", 
              style: Theme.of(context).textTheme.labelMedium,  textAlign: TextAlign.center),
              
              const SizedBox(height: 30),
          
              Container(),
             
              
              ],),
              
          ),
         Container(
         decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 32, 32, 32),
                        border: Border(
                         top:BorderSide(width: 1.0,
                          // assign the color to the border color
                          color: Color.fromARGB(255, 102, 102, 102),
                        )),)
         , child: Padding(
           padding: const EdgeInsets.symmetric(vertical: 15),
           child: Row(mainAxisAlignment: MainAxisAlignment.center, 
            
            children: [
            
            Text("""About""", 
            style: Theme.of(context).textTheme.bodyMedium,  textAlign: TextAlign.center),
            const SizedBox(width: 30),
            
            Text("""XYZ""", 
            style: Theme.of(context).textTheme.bodyMedium,  textAlign: TextAlign.center),
            const SizedBox(width: 30),
            
            
            Text("""YYZ""", 
            style: Theme.of(context).textTheme.bodyMedium,  textAlign: TextAlign.center),
            const SizedBox(width: 30),
            
            
            ],),
         ))],
      ),
    );
  }
}

class homePageNavBar extends StatefulWidget {
  final void Function(int) tabCallback;

  const homePageNavBar(
    this.tabCallback,
    {super.key}
  );

  @override
  State<homePageNavBar> createState() => _homePageNavBarState();
}

class _homePageNavBarState extends State<homePageNavBar> with TickerProviderStateMixin {
  int _tabIndex = 0;
  late TabController _controller; //the fact I have to use a mixin in a ctor to avoid this is ridiculous
  
  
  @override
  void initState()
  {
    super.initState();
    _controller = TabController(length : 4, vsync: this, initialIndex: 3);
    _controller.addListener(() {setState(()
    {
      _tabIndex = _controller.index;
      widget.tabCallback(_tabIndex);
    });

    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(color: const Color.fromARGB(255, 21, 21, 21),
      child: Row(mainAxisAlignment : MainAxisAlignment.spaceBetween,
        children: [ 
          
          Expanded(flex: 1, child: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Row(
            children: [
              Text("CardSum", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 20),
              FutureBuilder<String>(
          future: getUsername(),
          builder: (context, snapshot)
          {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();  
            } 
            
            else if (snapshot.error == 401) 
            {
              return  SelectableText('User: Logged Out', style: Theme.of(context).textTheme.labelMedium);  
            }
            
             else if (snapshot.hasData) 
             {
              return Text(("Current User: ${snapshot.data!}"), style: Theme.of(context).textTheme.labelMedium);  
            } 
            
            else {
              return Text('User: Unspecified Error ${snapshot.error}', style: Theme.of(context).textTheme.labelMedium );  
            }
          }
        ),
              
            ],
          ),
        )),

        const SizedBox(width: 200,),


          Expanded(flex: 1,
            child: DefaultTabController(
                
                length: 4, // Number of tabs
                child: TabBar(
                  
                controller: _controller,
                tabAlignment: TabAlignment.center,
                dividerColor: Colors.transparent,

                 

                isScrollable: true,
                  

                tabs: const <Widget>[
                    Tab(child: Text("Login/Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway'))),
                    Tab(child: Text("Toolkit Page", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway'))),
                    Tab(child: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway'))),
                    Tab(child: Text("Homepage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway')))
                    
                  ],
                
                
                ),
              ),
          ),
        ],
      ),
    );
  }
}



