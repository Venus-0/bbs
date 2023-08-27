import 'package:bbs/views/bbs/bbs_page.dart';
import 'package:bbs/views/first/first_page.dart';
import 'package:bbs/views/message/message_page.dart';
import 'package:bbs/views/user/user_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          onTap: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
            BottomNavigationBarItem(icon: Icon(Icons.wechat), label: "论坛"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: "消息"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
          ]),
    );
  }
}
