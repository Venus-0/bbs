import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/user/user_info.dart';
import 'package:flutter/material.dart';

class UserSubscriptionViewItem extends StatefulWidget {
  const UserSubscriptionViewItem({super.key, required this.user, required this.user_id});
  final UserModel user; //当前显示的user
  final int user_id; //当前所属的user_id
  @override
  State<UserSubscriptionViewItem> createState() => _UserSubscriptionViewItemState();
}

class _UserSubscriptionViewItemState extends State<UserSubscriptionViewItem> {
  bool _isSubscribe = false;
  bool _isBusy = false;
  @override
  void initState() {
    super.initState();
    if (widget.user_id == GlobalModel.user?.user_id) {
      _isSubscribe = true;
    } else {
      _checkSubscribe();
    }
  }

  void _checkSubscribe() async {
    _isSubscribe = await Api.checkSubscribe(widget.user.user_id);
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar() {
      if ((widget.user.avatar ?? "").isEmpty) {
        return Icon(
          Icons.person,
          size: 20,
        );
      } else {
        return Image.memory(base64Decode(widget.user.avatar!.split(",").last));
      }
    }

    Widget _subscribe = GestureDetector(
      onTap: () {
        if (_isSubscribe) {
          onUnSubscribe();
        } else {
          onSubscribe();
        }
      },
      child: Container(
        width: 80,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _isSubscribe ? null : Color(0xff1c1a18),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _isSubscribe ? Color(0xffd8d8d8) : Color(0xff1c1a18), width: 1.5)),
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
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfo(user: widget.user)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: _getAvatar(),
            ),
            SizedBox(width: 10),
            Text(widget.user.username),
            Spacer(),
            _subscribe,
          ],
        ),
      ),
    );
  }
}
