import 'package:bbs/http/socket.dart';
import 'package:bbs/views/bbs/add_bbs.dart';
import 'package:bbs/views/bbs/bbs_page.dart';
import 'package:bbs/views/first/first_page.dart';
import 'package:bbs/views/message/message_page.dart';
import 'package:bbs/views/user/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _bottomNavigator = [
    {"title": "首页", "icon": Icons.home},
    {"title": "论坛", "icon": Icons.wechat},
    {"title": "消息", "icon": Icons.notifications_active},
    {"title": "我的", "icon": Icons.person},
  ];
  int _pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SocketClient.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    Widget getBottomNavigatorItem(int index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _pageIndex = index;
          });
        },
        child: SizedBox(
          height: 56,
          width: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(_bottomNavigator[index]['icon']), Text(_bottomNavigator[index]['title'])],
          ),
        ),
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: IndexedStack(
          index: _pageIndex,
          children: [
            FirstPage(),
            BBSPage(),
            MessagePage(),
            UserPage(),
          ],
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => AddBBSPage()));
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              getBottomNavigatorItem(0),
              getBottomNavigatorItem(1),
              SizedBox(height: 32),
              getBottomNavigatorItem(2),
              getBottomNavigatorItem(3),
            ],
          ),
        ));
  }
}
