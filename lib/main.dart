import 'package:flutter/material.dart';
import 'package:summer_proj_app/preferenceUtils.dart';
//this little fella makes sure JWT tokens are safely tucked away! local storage too!


import 'homepage.dart';



void main() async
{
  WidgetsFlutterBinding.ensureInitialized(); 
  await PreferenceUtils.init(); // Initialize PreferenceUtils for ze psuedo cookie storage

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SecondPage(), //stupid naming, should be homepage really

      theme: ThemeData(
        textTheme: const TextTheme(
          
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 48, 
          fontWeight: FontWeight.w700, 
          fontFamily: 'Raleway'),
        
        
        bodyMedium: TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontSize: 20,),

        labelMedium: TextStyle(
            color: Color.fromARGB(255, 99, 81, 159),
            height: 0.7,
            fontWeight: FontWeight.w500,
            fontFamily: 'Raleway',
            fontSize: 18,)


            
      ),
    ));
  }
}

