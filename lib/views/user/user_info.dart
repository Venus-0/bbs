import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/bbs/bbs_item.dart';
import 'package:bbs/views/message/chat.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key, required this.user});
  final UserModel user;
  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  int? _subscribe;
  int? _fans;
  List<BBSModel> _bbsList = [];
  bool _isSubscribe = false;
  bool _isBusy = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetail();
  }

  void getDetail() async {
    final (_, _subscribe, _fans, _isSubscribe, _bbsList) = await Api.getUserDetail(widget.user.user_id);
    setState(() {
      this._subscribe = _subscribe;
      this._fans = _fans;
      this._isSubscribe = _isSubscribe ?? false;
      this._bbsList = _bbsList ?? [];
    });
  }

  void onSubscribe() async {
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _isSubscribe = true;
    });
    Api.subscribeUser(widget.user.user_id).then((value) {
      if (!value) {
        Toast.showToast("出错了");
        setState(() {
          _isSubscribe = false;
        });
      } else {
        eventBus.fire(SubscribeChange());
      }
    });
  }

  void onUnSubscribe() async {
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _isSubscribe = false;
    });
    Api.unSubScribe(widget.user.user_id).then((value) {
      if (!value) {
        Toast.showToast("出错了");
        setState(() {
          _isSubscribe = true;
        });
      } else {
        eventBus.fire(SubscribeChange());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar() {
      print(widget.user.avatar);
      if ((widget.user.avatar ?? "").isEmpty || widget.user.disable_time != null) {
        return Icon(
          Icons.person,
          size: 80,
        );
      } else {
        return Image.memory(base64Decode(widget.user.avatar!.split(",").last));
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("用户详情"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            child: _getAvatar(),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "${widget.user.username}",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "${_fans ?? '--'}\n粉丝",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${_subscribe ?? '--'}\n关注",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ...List.generate(_bbsList.length, (index) => BBSItem(bbs: _bbsList[index], enableLike: false))
                  ],
                ),
              ),
            ),
            ...widget.user.disable_time == null
                ? [
                    Container(
                      height: 80,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Chat(messages: [], user: widget.user, loadMessage: true),
                                    ));
                              },
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0xffd8d8d8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble, color: Colors.black45),
                                    Text("私信", style: TextStyle(color: Colors.black45)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ...widget.user.disable_time == null
                              ? []
                              : [
                                  Container(
                                    height: 20,
                                    width: double.maxFinite,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                      color: Color(0xffd8d8d8),
                                    ),
                                    child: Text(
                                      "该账户已被管理员封禁",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isSubscribe) {
                                  onUnSubscribe();
                                } else {
                                  onSubscribe();
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isSubscribe ? Color(0xffd8d8d8) : Color(0xff1c1a18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _isSubscribe
                                      ? [
                                          Icon(Icons.check, color: Colors.black45),
                                          Text("已关注", style: TextStyle(color: Colors.black45)),
                                        ]
                                      : [
                                          Icon(Icons.add, color: Colors.white),
                                          Text("关注", style: TextStyle(color: Colors.white)),
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                : [
                    Container(
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.center,
                      color:Color(0xFFe74c3c),
                      child: Text(
                        "当前用户已被管理员封禁",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
          ],
        ));
  }
}
