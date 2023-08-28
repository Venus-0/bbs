import 'package:flutter/material.dart';

class BBS extends StatefulWidget {
  const BBS({super.key});

  @override
  State<BBS> createState() => _BBSState();
}

class _BBSState extends State<BBS> {
  final List<Map<String, dynamic>> _list = [
    {"user": "小蜜蜂工厂"},
    {"user": "键盘🐶都不玩"},
    {"user": "IFF"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey.withAlpha(76),
            ))),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_2_outlined, size: 24),
                    SizedBox(width: 10),
                    Text(_list[index]['user']),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.thumb_up, color: Colors.grey[400],size: 14,),
                        label: Text("点赞", style: TextStyle(color: Colors.grey[400]))),
                    SizedBox(width: 30),
                    TextButton(onPressed: () {}, child: Text("评论", style: TextStyle(color: Colors.grey[400]))),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
