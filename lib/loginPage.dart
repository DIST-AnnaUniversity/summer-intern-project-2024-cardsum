import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:summer_proj_app/preferenceUtils.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  //callback to head to home page here


  bool loginValidator()
  {
    final FormState form = _formKey.currentState!;
    return form.validate();
  }
  Future<bool> _authenticate(String username, String password) async {
  const url = 'http://127.0.0.1:8000/login/';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    ); //seriously, the pass needs to be hashed or TLS'd

    if (response.statusCode == 200) 
    {
      //authenticate aachu bro
      final responseData = json.decode(response.body);
      PreferenceUtils.setString("authToken", responseData['accessToken']);
      PreferenceUtils.setString("csrfToken", responseData['csrfToken']);
      print('Access Token: ${responseData['accessToken']}');
      print('Message: ${responseData['message']}');
      setState(() { _errorMessage = "Login Successful";}
        );
      return true;



    } else if (response.statusCode == 400) 
    {
      // el failures
      final errorData = json.decode(response.body);
      print('Error: ${errorData['error']}');
      setState(() { _errorMessage = "Login Failed. Error: ${errorData['error']}";}
        );
      return false;
    } 
    
    else 
    {
      print('Unexpected status code: ${response.statusCode}');
      setState(() { _errorMessage = "Unexpected Error";} //no place for komedi here, need to change this later
        );
      return false;
      
    }
  } 
  
  catch (error) {
    print('An error occurred: $error');
    return false;
  }
}
//maybe pipe all this to the login form to be displayed


  Future<bool> _registerUser(String username, String password) async 
  {
  const url = 'http://127.0.0.1:8000/registerUser/';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    ); //seriously, the pass needs to be hashed or TLS'd

    if (response.statusCode == 200) 
    {
      //authenticate aachu bro
      final responseData = json.decode(response.body);
      print('Message: ${responseData['message']}');

      setState(() { _errorMessage = "Registration Successful";}
        );
      return true;



    } else if (response.statusCode == 400) 
    {
      // el failures
      final errorData = json.decode(response.body);
      print('Error: ${errorData['error']}');
      setState(() { _errorMessage = "Registration Failed. Error: ${errorData['error']}";}
        );
      return false;
    } 
    
    else 
    {
      print('Unexpected status code: ${response.statusCode}');
      setState(() { _errorMessage = "You are on your own, pal";} 
        );
      return false;
      
    }
  } 
  
  catch (error) {
    print('An error occurred: $error');
    return false;
  }
}



  void _login() async 
  {
      String username = _usernameController.text;
      String password = _passwordController.text;

      bool loginSuccess = await _authenticate(username, password);
      if (loginSuccess)
      {

        //Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondPage()));

      }


  }

   void _register() async 
  {

      //need some input sanitation here hmmm
      String username = _usernameController.text;
      String password = _passwordController.text;

      bool registerSuccess = await _registerUser(username, password);
      if (registerSuccess)
      {

        bool loginSuccess = await _authenticate(username, password);
        if (loginSuccess)
        {

          //Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondPage()));

      }

      }




  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          
          children: [
            Container(decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/signInBG.png"),
              fit: BoxFit.cover,)),
              child: Center(
                      
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left:256,right:256, bottom: 256),
                          child: Column(
                            children: [ const Text("Sign In, Turbocharge Your Learning Now.", selectionColor: Color.fromARGB(255, 255, 255, 255), style: TextStyle(color:  Color.fromARGB(255,255,255,255), fontSize: 48, fontFamily: 'Raleway', fontWeight: FontWeight.w300),),
                            const SizedBox(height: 56 ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    RoundedTextFormField(
                                      obscureText: false,
                                      controller: _usernameController,
                                      labelText: 'Username',
                                      hintText: 'Enter your username here',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a valid username';
                                        }
                                        return null;
                                      },
                                    ),
                
                
                                    const SizedBox(height: 40),
                                    RoundedTextFormField(
                                      obscureText: true,
                                      controller: _passwordController,
                                      labelText: 'Password',
                                      hintText: 'Enter your password here',
                                      validator: (value) {
                                        if (value == null || value.isEmpty || value.length < 7) {
                                          return 'Please enter a valid password. Minimum length of 7 characters ';
                                        }
                                        return null;
                                      },
                
                
                                    ),
                                   
                                   
                                    const SizedBox(height: 40),
                                     ElevatedButton(
                                      onPressed: () { if (loginValidator())
                                      {
                                        _login();
                                      }
                                      },

                                      style: ElevatedButton.styleFrom(minimumSize: const Size(180, 40)),
                                      child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway'),),
                                    ),
                
                                    
                                    const SizedBox(height: 40),
                                     ElevatedButton(
                                      onPressed: () { if (loginValidator())
                                      {
                                        _register();
                                      }
                                      },
                                      style: ElevatedButton.styleFrom(minimumSize: const Size(180, 40)),
                                      child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway'),),
                                    ),
                
                
                                    const SizedBox(height: 20, width: 60),
                                    Text(
                                      _errorMessage,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red),
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
    );
  }
}


class RoundedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const RoundedTextFormField({super.key, 
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.hintText,
    
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 47, 33, 33),
        border: Border.all(width: 1.0, color:const Color.fromARGB(255, 163, 163, 163) ),
        borderRadius: BorderRadius.circular(12.0),
      
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontFamily: 'Raleway'),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: const Color.fromARGB(255, 111, 111, 111)),

          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: const Color.fromARGB(255, 111, 111, 111)),
          
          errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red)
        ),
        validator: validator,
      ),
    );
  }
}