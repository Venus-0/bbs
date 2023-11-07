import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/message_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.messages, required this.user, this.loadMessage = false});
  final List<MessageModel> messages;
  final UserModel user;
  final bool loadMessage;
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _messageController = TextEditingController();
  UniqueKey _chatKey = UniqueKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.loadMessage) _loadMessgae();
    eventBus.on<Message>().listen((msg) {
      if (msg.message.receiver_id == GlobalModel.user?.user_id) {
        if (!widget.messages.any((element) => element.id == msg.message.id)) {
          widget.messages.insert(0, msg.message);
          setState(() {});
        }
      }
    });
  }

  void _loadMessgae() async {
    List<MessageModel> _messgaes = await Api.getUserChat(widget.user.user_id);
    widget.messages.insertAll(0, _messgaes);
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _sendMsg(String message) async {
    MessageModel _newMessage = MessageModel(
        id: 0, receiver_id: widget.user.user_id, sender_id: GlobalModel.user?.user_id ?? 0, content: message, create_time: DateTime.now());
    Api.sendMesaage(widget.user.user_id, message);
    widget.messages.insert(0, _newMessage);
    _messageController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar(UserModel user) {
      if ((user.avatar ?? "").isEmpty) {
        return Icon(Icons.person_2_outlined);
      } else {
        return Image.memory(base64Decode(user.avatar!.split(",").last));
      }
    }

    String _getDateTimeString(DateTime? time) {
      if (time == null) return "";
      return DateFormat("yyyy-MM-dd HH:mm").format(time);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            reverse: true,
            itemBuilder: (context, index) {
              MessageModel _message = widget.messages[index];
              bool _isSelf = _message.sender_id == GlobalModel.user?.user_id; //是不是自己发的
              if (_isSelf) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateTimeString(_message.create_time),
                        style: TextStyle(fontSize: 12, color: Color(0xffd8d8d8)),
                      ),
                      SizedBox(width: 10),
                      Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff9FE759)),
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xff9FE759),
                        ),
                        child: Text(_message.content),
                      ),
                      SizedBox(width: 10),
                      SizedBox(width: 44, height: 44, child: _getAvatar(GlobalModel.user!)),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 44, height: 44, child: _getAvatar(widget.user)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffFEFFFE)),
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xffFEFFFE),
                          ),
                          child: Text(_message.content),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _getDateTimeString(_message.create_time),
                        style: TextStyle(fontSize: 12, color: Color(0xffd8d8d8)),
                      ),
                      SizedBox(width: 100),
                    ],
                  ),
                );
              }
            },
            itemCount: widget.messages.length,
          )),
          Container(
            constraints: BoxConstraints(minHeight: 80),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xff636e72),
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xff636e72),
                          )),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (value) {},
                    onEditingComplete: () {
                      if (_messageController.text.isEmpty) return;
                      _sendMsg(_messageController.text);
                    },
                  ),
                ),
                // SizedBox(width: 10),
                // RawMaterialButton(
                //   onPressed: () {},
                //   child: Text(
                //     "保存",
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   fillColor: Color(0xff2edfa3),
                //   shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xff2edfa3)), borderRadius: BorderRadius.circular(8)),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
