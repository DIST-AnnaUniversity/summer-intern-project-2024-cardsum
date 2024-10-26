import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//need this stuff for later bleh


class DataFetchingScreen extends StatefulWidget {
  const DataFetchingScreen({super.key});

  @override
  _DataFetchingScreenState createState() => _DataFetchingScreenState();
}


class _DataFetchingScreenState extends State<DataFetchingScreen> 
{

  Future fetchData() async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/summarize/'), body: "test");
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return response.body;
    }
    
     else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data');
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Data Fetching Example'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) 
            {
              return const CircularProgressIndicator(); // Show a loading indicator while fetching data
            } 
            
            else if (snapshot.hasError)
            {
              return SelectableText('Error: ${snapshot.error}');
            } 
            
            else 
            
            {
              // Display the fetched data
              return Text('Fetched Data: ${snapshot.data}');
            }


          },
        ),
      ),
    );
  }
}