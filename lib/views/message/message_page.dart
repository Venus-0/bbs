import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/message_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/views/message/chat.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Map<String, dynamic> _messages = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMessageList();
    eventBus.on<Message>().listen((msg) {
      if (msg.message.receiver_id == GlobalModel.user?.user_id || msg.message.sender_id == GlobalModel.user?.user_id) {
        _getMessageList();
      }
    });
  }

  void _getMessageList() async {
    Map _res = await Api.getMessageList();
    if (_res['code'] == 200) {
      _messages = _res['result'];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List _data = _messages.values.toList();
    Widget _getAvatar(UserModel user) {
      if ((user.avatar ?? "").isEmpty) {
        return Icon(Icons.person_2_outlined);
      } else {
        return Image.memory(base64Decode(user.avatar!.split(",").last));
      }
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(children: [
              Text(
                "消息",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            ]),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "我的消息",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (BuildContext context, int index) {
                UserModel _user = UserModel.fromJson(_data[index]['user']);
                MessageModel? _message =
                    (_data[index]['messages'] ?? []).isEmpty ? null : MessageModel.fromJson(_data[index]['messages'][0]);
                return GestureDetector(
                  onTap: () {
                    List<MessageModel> _messages = [];
                    for (Map<String, dynamic> _json in _data[index]['messages']) {
                      _messages.add(MessageModel.fromJson(_json));
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(messages: _messages, user: _user),
                        ));
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(76)))),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: _getAvatar(_user),
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user.username,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _message?.content ?? "",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
