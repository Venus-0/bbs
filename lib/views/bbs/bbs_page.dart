import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/views/bbs/bbs.dart';
import 'package:bbs/views/bbs/digest.dart';
import 'package:bbs/views/bbs/question.dart';
import 'package:bbs/views/bbs/wiki.dart';
import 'package:flutter/material.dart';

class BBSPage extends StatefulWidget {
  const BBSPage({super.key});

  @override
  State<BBSPage> createState() => _BBSPageState();
}

class _BBSPageState extends State<BBSPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget tab = Container(
      height: 42,
      width: MediaQuery.of(context).size.width,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: "论坛"),
          Tab(text: "Wiki"),
          Tab(text: "问答区"),
          Tab(text: "精华区"),
        ],
        onTap: (value) {},
      ),
    );

    Widget tabBarView = TabBarView(controller: _tabController, children: [
      BBS(bbsModel: BBSModel.TYPE_POST,),
      BBS(bbsModel: BBSModel.TYPE_WIKI,),
      BBS(bbsModel: BBSModel.TYPE_QUESTION,),
      // WikiPage(),
      // QuestionPage(),
      DigestPage(),
    ]);
    return Container(
      child: Column(
        children: [tab, SizedBox(height: 10), Expanded(child: tabBarView)],
      ),
    );
  }
}
