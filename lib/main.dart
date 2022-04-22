import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app_with_flutter/notification.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'notification.dart';

import './style.dart' as style;

const dataUrl = 'https://codingapple1.github.io/app/data.json';
const moreDataUrl = 'https://codingapple1.github.io/app/more1.json';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Store1(),
        ),
        ChangeNotifierProvider(
          create: (context) => Store2(),
        ),
      ],
      child: MaterialApp(
        theme: style.theme,
        home: MyApp(),
      ),
    ),
  );
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
    initNotification(context);
    getData();
    saveData();
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

  saveData() async {
    var storage = await SharedPreferences.getInstance();

    storage.setString('name', 'john');

    var result = storage.get('name');

    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () {
          showNotification();
        },
      ),
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
                GestureDetector(
                  child: Text(widget.feedList[index]['user']),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => Profile(),
                        transitionsBuilder: (c, a1, a2, child) =>
                            SlideTransition(
                          position: Tween(
                            begin: Offset(0, -1.0),
                            end: Offset(0.0, 0.0),
                          ).animate(a1),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
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

class Store1 extends ChangeNotifier {
  var name = 'Jeong Park';
  var followerCount = 0;
  var isFollowed = false;
  var profileImage = [];

  getData() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var profileData = jsonDecode(response.body);

    profileImage = profileData;

    print(profileData);
    notifyListeners();
  }

  changeName() {
    name = 'john son';
    notifyListeners();
  }

  followToggle() {
    isFollowed ? unfollowUser() : followUser();
    notifyListeners();
  }

  followUser() {
    followerCount += 1;
    isFollowed = true;
  }

  unfollowUser() {
    followerCount -= 1;
    isFollowed = false;
  }
}

class Store2 extends ChangeNotifier {
  var name = 'john kim';
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store1>().name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    child: Image.network(
                        context.watch<Store1>().profileImage[index])),
                childCount: context.watch<Store1>().profileImage.length,
              ),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3))
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
        ),
        Text('팔로워 ${context.watch<Store1>().followerCount}명'),
        ElevatedButton(
          onPressed: () {
            context.read<Store1>().followToggle();
          },
          child: Text('팔로우'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<Store1>().getData();
          },
          child: Text('사진 가져오기'),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
