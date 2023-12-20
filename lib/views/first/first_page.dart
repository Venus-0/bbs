import 'package:bbs/views/first/popular.dart';
import 'package:bbs/views/first/recent.dart';
import 'package:bbs/views/first/recommand.dart';
import 'package:bbs/views/first/search_page.dart';
import 'package:bbs/views/first/subscribe.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void onSearch() {
    if (_searchController.text.isEmpty) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            search: _searchController.text,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Widget search = Container(
      height: 32,
      width: double.infinity,
      alignment: Alignment.center,
      child: TextField(
        style: TextStyle(fontSize: 14),
        controller: _searchController,
        decoration: InputDecoration(
            fillColor: Colors.grey[200],
            filled: true,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
            hintText: "请输入搜索内容",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: EdgeInsets.only(left: 12)),
        onSubmitted: (value) {
          onSearch();
        },
      ),
    );

    Widget tab = Container(
      height: 42,
      width: MediaQuery.of(context).size.width,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: "推荐"),
          Tab(text: "关注"),
          Tab(text: "热门"),
          Tab(text: "最新"),
        ],
        onTap: (value) {},
      ),
    );

    Widget tabBarView = TabBarView(controller: _tabController, children: [
      RecommandPage(),
      SubscribePage(),
      PopularPage(),
      RecentPage(),
    ]);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height: 20),
            search,
            SizedBox(height: 10),
            tab,
            SizedBox(height: 10),
            Expanded(
              child: tabBarView,
            )
          ],
        ),
      ),
    );
  }
}
