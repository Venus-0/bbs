import 'package:bbs/model/user_bean.dart';
import 'package:bbs/views/user/user_fans_view.dart';
import 'package:bbs/views/user/user_subscription_view.dart';
import 'package:flutter/material.dart';

class UserSubScriptionPage extends StatefulWidget {
  const UserSubScriptionPage({super.key, this.showType = 1, required this.user_id});
  final int showType; //显示的列表类型 1关注 2粉丝
  final int user_id;
  @override
  State<UserSubScriptionPage> createState() => _UserSubScriptionPageState();
}

class _UserSubScriptionPageState extends State<UserSubScriptionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..animateTo(widget.showType - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 200,
          alignment: Alignment.center,
          child: TabBar(
            tabs: [
              Tab(child: Text("关注")),
              Tab(child: Text("粉丝")),
            ],
            controller: _tabController,
            dividerColor: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: TabBarView(physics: NeverScrollableScrollPhysics(), controller: _tabController, children: [
        UserSubscriptionView(user_id: widget.user_id),
        UserFansView(user_id: widget.user_id),
      ]),
    );
  }
}
