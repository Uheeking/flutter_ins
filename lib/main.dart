import 'package:flutter/material.dart';
import 'style.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(theme: theme, home: MyApp()));
}

class ActionsIconTheme {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;
  var userContent;

  saveData(){
  var storage = await SharedPreferences.getInstance();
  storage.setString('name', 'john');
  var result = storage.getString('name');
  print(result);
}

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  addData(a) {
    setState(() {
      data.add(a);
    });
  }

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                          addMyData: addMyData)));
            },
          )
        ],
      ),
      body: tab == 0
          ? Home(
              data: data,
              addData: addData,
            )
          : Text('샵페이지'),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
              label: '홈',
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: '샵',
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag))
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, this.data, this.addData});
  final data;
  final addData;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();
  var handling = 0;

  getDataMore() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
    handling++;
  }

  getDataMore2() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more2.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
    handling++;
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        if (handling == 0) {
          getDataMore();
        } else if (handling == 1) {
          getDataMore2();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: (c, i) {
            return Column(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.data[i]['image'].runtimeType == String
                          ? Image.network(widget.data[i]['image'])
                          : Image.file(widget.data[i]['image']),
                      Text('좋아요 ${widget.data[i]['likes']}'),
                      Text('글쓴이 ${widget.data[i]['user']}'),
                      Text('글내용 ${widget.data[i]['content']}'),
                    ],
                  ),
                )
              ],
            );
          });
    } else {
      return Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            children: const [CircularProgressIndicator(), Text('로딩중입니다. ')],
          ),
        ),
      );
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent, this.addMyData})
      : super(key: key);
  final userImage;
  final setUserContent;
  final addMyData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(actions: [
          IconButton(
              onPressed: () {
                addMyData();
              },
              icon: Icon(Icons.send))
        ]),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: Image.file(userImage),
            ),
            Text('이미지업로드화면'),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)),
            TextField(onChanged: (text) {
              setUserContent(text);
            }),
            TextButton(onPressed: () {}, child: Text('추가'))
          ],
        ));
  }
}
