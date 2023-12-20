import 'dart:async';
import 'dart:convert';
import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/views/user/my_post.dart';
import 'package:bbs/views/user/user_detail.dart';
import 'package:bbs/views/user/user_subscription_page.dart';

import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int? _subscribe;
  int? _fans;
  List<BBSModel> _bbsList = [];
  late StreamSubscription<User> _userSubscription;
  late StreamSubscription<SubscribeChange> _subSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetail();
    _userSubscription = eventBus.on<User>().listen((event) {
      if (mounted) setState(() {});
    });
    _subSubscription = eventBus.on<SubscribeChange>().listen((event) {
      getDetail();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getDetail() async {
    final (_, _subscribe, _fans, _, _bbsList) = await Api.getUserDetail(GlobalModel.user!.user_id);
    setState(() {
      this._subscribe = _subscribe;
      this._fans = _fans;
      this._bbsList = _bbsList ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar() {
      print(GlobalModel.user?.avatar);
      if ((GlobalModel.user?.avatar ?? "").isEmpty) {
        return Icon(
          Icons.person,
          size: 80,
        );
      } else {
        return Image.memory(base64Decode(GlobalModel.user!.avatar!.split(",").last));
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetail(),
                  ));
            },
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: _getAvatar(),
                ),
                SizedBox(width: 20),
                Text(
                  "${GlobalModel.user?.username ?? '？？'}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSubScriptionPage(user_id: GlobalModel.user!.user_id, showType: 2),
                      ));
                },
                child: Row(
                  children: [
                    Text(
                      "${_fans ?? '--'}",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "粉丝",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSubScriptionPage(user_id: GlobalModel.user!.user_id, showType: 1),
                      ));
                },
                child: Row(
                  children: [
                    Text(
                      "${_subscribe ?? '--'}",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "关注",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 50),
          TextButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPost(bbsList: _bbsList),
                    ));
              },
              icon: Icon(Icons.edit, color: Colors.grey[400]),
              label: Text("我的帖子", style: TextStyle(color: Colors.grey[400]))),
          TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.thumb_up, color: Colors.grey[400]),
              label: Text("我赞过的内容", style: TextStyle(color: Colors.grey[400]))),
          // TextButton.icon(
          //     onPressed: () {},
          //     icon: Icon(Icons.favorite, color: Colors.grey[400]),
          //     label: Text("我的收藏", style: TextStyle(color: Colors.grey[400]))),
        ],
      ),
    );
  }
}
