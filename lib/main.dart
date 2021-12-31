import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_networking_side/styles.dart' ;



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
  late final TextEditingController _controller;
  late Future<List<Album>> futureAlbum;
  late final FocusNode _focusNode;
  late var _text;
  List<Album> ?album ;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChange);
    _text = "";
    _focusNode = FocusNode()..addListener(_onFocusChange);
    futureAlbum = fetchAlbum();
  }

  void _onTextChange(){
    setState(() {
      _text = _controller.text;
    });
  }

  void _onFocusChange(){
    var bool = _focusNode.parent?.hasFocus.toString()??"false";
    print("Focus is" + bool + " ");
  }

  @override
  Widget build(BuildContext context) {
    var _questions = [
      {
        'questionText': 'What\'s the meaning of Assuetude?',
        'answers': ['kiss', 'insolent', 'habit', 'half'],
      },
      {
        'questionText': 'What\'s the meaning of Disingenuous?',
        'answers': ['guilty', 'jovial', 'jocular', 'insincere'],
      },
      {
        'questionText': 'What\'s the meaning of Affl?',
        'answers': ['ghost', 'inspiration', 'lifeless', 'greedy'],
      },
    ];

    Widget _buildSearchBox() {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SearchBar(
          controller: _controller,
          focusNode: _focusNode,
        ),
      );
    }

    return MaterialApp(
      title: 'Fetching Data',
      home : Scaffold(
        appBar: AppBar(
          title: Text('Api Part Integration'),
        ),
        body:Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context,snapshot){
              if(snapshot.hasData){
                try{
                  album = [];

                  album = snapshot.data?.where((element) {
                      return element.title.startsWith(_text);
                  }).toList();

                  //assert(album?isNotEmpty);

                  // album?.forEach((element) {
                  //   print(element.title);
                  // });

                }on Exception catch (_, ex){
                  //ex.toString();
              }

              }

              //print("UserId");
              //print(results?.userId.toString());


              if (snapshot.connectionState == ConnectionState.done) {
                var  name = _questions.toList().map((e) => e.values);
                var question = name.toList().map((e) => e.elementAt(0));
                var answer = name.toList().map((e) => e.elementAt(1));

                List<String> _answer = (answer.elementAt(0) as List<String>);
                 assert(_answer.elementAt(0).isNotEmpty);
                //print(_answer.elementAt(0));

                //print(_answer.indexOf('habit',0));
                // for(var str in _answer){
                //   print(str.indexOf('habit',1));
                // }

                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildSearchBox(),
                      //Text(answer.toString()),
                      Expanded(child: ListView.builder(
                          itemBuilder: (context,index){
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.amberAccent),
                              title: Text(album?.elementAt(index).id.toString()??"Empty"),
                              subtitle: Text(album?.elementAt(index).title??"Empty"),
                            );
                          },
                          itemCount: album?.length,
                          )
                      )
                      //Text(snapshot.data!.userId.toString()),

                      // TextField(
                      //   controller: _controller,
                      //   decoration: InputDecoration(hintText: 'Enter Title'),
                      //   inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      // ),
                      // RaisedButton(
                      //   child: const Text('Update'),
                      //   onPressed: () {
                      //     setState(() {
                      //       futureAlbum = updateAlbum(int.parse(_controller.text));
                      //     });
                      //   },
                      // ),
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

Future<List<Album>> fetchAlbum() async {
  final response = await http.get('https://jsonplaceholder.typicode.com/albums');
  /*https://jsonplaceholder.typicode.com/albums/2*/
  if (response.statusCode == 200) {
    List<Album> albumlist;
    return (json.decode(response.body) as List)
                .map((e) => Album.fromJson(e)).toList();
    //return albumlist;
    //print("object");
    //return Album.fromJson(json.decode(response.body));
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
  //Map<String, dynamic> toJson() => AlbumTo(this);
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Styles.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Styles.searchIconColor,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
                decoration: null,
              ),
            ),
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                Icons.clear,
                color: Styles.searchIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



