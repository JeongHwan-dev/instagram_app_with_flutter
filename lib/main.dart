import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import './style.dart' as style;

const dataUrl = 'https://codingapple1.github.io/app/data.json';
const moreDataUrl = 'https://codingapple1.github.io/app/more1.json';

void main() {
  runApp(MaterialApp(
    theme: style.theme,
    initialRoute: '/',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var feedList = [];
  var userImage;
  var userContent;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var response = await http.get(Uri.parse(dataUrl));

    if (response.statusCode == 200) {
      setState(() {
        feedList = jsonDecode(response.body);
      });
    } else {
      print('Data fetching error');
    }
  }

  addFeed(newFeed) {
    setState(() {
      feedList.add(newFeed);
    });
  }

  addMyFeed() {
    var myFeed = {
      'id': feedList.length,
      'image': userImage,
      'likes': 0,
      'date': 'July 5',
      'content': userContent,
      'liked': false,
      'user': 'David',
    };

    setState(() {
      feedList.insert(0, myFeed);
    });

    Navigator.pop(context);
  }

  setUserContent(content) {
    setState(() {
      userContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Instagram',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Upload(
                    userImage: userImage,
                    setUserContent: setUserContent,
                    addMyFeed: addMyFeed,
                  ),
                ),
              );
            },
            iconSize: 30,
          ),
        ],
      ),
      body: [
        Home(feedList: feedList, addFeed: addFeed),
        Text('샵 페이지'),
      ][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            tab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: '샵',
          ),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.feedList, this.addFeed}) : super(key: key);
  final feedList;
  final addFeed;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore();
      }
    });
  }

  getMore() async {
    var response = await http.get(Uri.parse(moreDataUrl));
    var newContent = jsonDecode(response.body);

    widget.addFeed(newContent);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedList.isNotEmpty) {
      return ListView.builder(
          controller: scroll,
          itemCount: widget.feedList.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.feedList[index]['image'].runtimeType == String
                    ? Image.network(widget.feedList[index]['image'])
                    : Image.file(widget.feedList[index]['image']),
                Text('좋아요 ${widget.feedList[index]['likes']}'),
                Text(widget.feedList[index]['user']),
                Text(widget.feedList[index]['date']),
                Text(widget.feedList[index]['content'])
              ],
            );
          });
    } else {
      return SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
      // return CircularProgressIndicator();
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({
    Key? key,
    this.userImage,
    this.setUserContent,
    this.addMyFeed,
  }) : super(key: key);
  final userImage;
  final setUserContent;
  final addMyFeed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              addMyFeed();
            },
            icon: Icon(Icons.send),
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          TextField(onChanged: (text) {
            setUserContent(text);
          }),
          Text('이미지 업로드 화면'),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
