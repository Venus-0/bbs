import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<Map<String, dynamic>> msg = [
    {"title": "论坛客服", "msg": "账户解封请联系QQ：12345678", "icon": Icons.headset_mic},
    {"title": "系统消息", "msg": "账户解封请联系QQ：12345678", "icon": Icons.wechat_outlined},
    {"title": "论坛通知", "msg": "账户解封请联系QQ：12345678", "icon": Icons.chat_bubble},
    {"title": "小蜜蜂工厂", "msg": "账户解封请联系QQ：12345678", "icon": Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
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
              itemCount: msg.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 60,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(76)))),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(msg[index]['icon'], size: 32),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg[index]['title'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            msg[index]['msg'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    ],
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
