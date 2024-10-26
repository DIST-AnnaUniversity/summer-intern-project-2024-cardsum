import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:summer_proj_app/preferenceUtils.dart';


//funky functions for DB wala stuff goes here


Future<String> getUsername() async {
  // Retrieve the token from storage
  String? token = PreferenceUtils.getString("authToken");
  
  // Check if the token exists
  if (token.isEmpty) {
    return "No token found. Please log in.";
  }

  String body = jsonEncode({"authToken": token});

  final response = await http.post(
    Uri.parse("http://127.0.0.1:8000/getUserInfo/"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Include the token in the headers
    },
    body: body,
  );

  // Handle the case where the token is expired or invalid
  if (response.statusCode == 401) {
    // Perform logout or notify the user
    // You may want to clear the token from storage and notify the user
    PreferenceUtils.deleteString("authToken"); // Clear the token
    return "Logged Out. Please log in again."; // Inform the user
  }

  // Check for other errors
  if (response.statusCode != 200) {
    return "Failed to retrieve username. Status: ${response.statusCode}";
  }

  // If everything is fine, decode the response
  return jsonDecode(response.body)["username"];
}



Future<void> createFlashcard(String topic, String title, String text) async {
  final url = Uri.parse('http://127.0.0.1:8000/registerFlashcard/');
  String token = PreferenceUtils.getString("authToken");

try
{
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "authToken" : token,
      'topic': topic,
      'title': title,
      'content': text,

    }),
  );

  if (response.statusCode == 200) {
    print('Flashcard created successfully');
  } else {
    print('Failed to create flashcard: ${response.body}');
  }


}

catch (error)
{
  print(error);
}
  
}


Future<void> deleteFlashcard(int id) async {
  final url = Uri.parse('http://127.0.0.1:8000/deleteFlashcard/');
  String token = PreferenceUtils.getString("authToken");


  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "authToken" : token,
      'flashID' : id

    }),
  );
  

  if (response.statusCode == 200) {
    print('Flashcard deleted successfully');
  } else {
    print('Failed to delete flashcard: ${response.body}');
  }
}

Future<void> updateFlashcard(int id, String topic, String title, String text) async {
  final url = Uri.parse('http://127.0.0.1:8000/updateFlashcard/');
  String token = PreferenceUtils.getString("authToken");


  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "authToken" : token,
      'flashID' : id,
      'topic': topic,
      'title': title,
      'text': text,

    }),
  );
  

  if (response.statusCode == 200) {
    print('Flashcard updated successfully');
  } else {
    print('Failed to updated flashcard: ${response.body}');
  }
}




Future<void> logout(String accessToken, String csrfToken) async {
  print("attempting logout");
try{
  const url = 'http://127.0.0.1:8000/logout/';
  final response = await http.post(
    Uri.parse(url),  
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'X-CSRF-Token': csrfToken,
      "Access-Control-Allow-Origin": "*"
    },
     body: json.encode({
        'NA' : 'whyEvenLol'
      })
  ); //all because one method call wanted to be special
  print("response arrived for logout");
  if (response.statusCode == 205) {
    // Successfully logged out
    print('Logged out successfully');
  } else {
    // Handle error response
    print('Failed to log out: ${response.body}');
  }
}
catch (error)
{
  print(error);
}
}
