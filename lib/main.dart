import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyHomePage();
  }
}

class _MyHomePage extends State<MyHomePage>{
  final TextEditingController _controller = TextEditingController();
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetching Data',
      home : Scaffold(
        appBar: AppBar(
          title: Text('Fetching Album'),
        ),
        body:Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context,snapshot){
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(snapshot.data!.userId.toString()),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(hintText: 'Enter Title'),
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],

                      ),
                      RaisedButton(
                        child: const Text('Update'),
                        onPressed: () {
                          setState(() {
                            futureAlbum = updateAlbum(int.parse(_controller.text));
                          });
                        },
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
              }
              return CircularProgressIndicator();
              //For Fetching data from Internet
              /*if(snapshot.hasData){
                return Text(snapshot.data!.title);
              }else if(snapshot.hasError){
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();*/
            },
          ),
        ),
      )

    );
  }

}

Future<Album> updateAlbum(int userId) async {
  final http.Response response = await http.put(
    'https://jsonplaceholder.typicode.com/albums/2',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int>{
      'userId': userId,
    }),
  );
  // Dispatch action depending upon
  // the server response
  if (response.statusCode == 200) {
    return Album.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

Future<Album> fetchAlbum() async {
  final response = await http.get('https://jsonplaceholder.typicode.com/albums/1');
  /*https://jsonplaceholder.typicode.com/albums/2*/
  if (response.statusCode == 200) {
    //print("object");
    return Album.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class Album{
  final int userId;
  final int id;
  final String title;

  Album({required this.userId,required this.id,required this.title});

  factory Album.fromJson(Map<String,dynamic> json){
    return Album(userId: json['userId'],
                  id: json['id'],
                title: json['title']);
    
  }
}


