import 'package:flutter/material.dart';

class RecommandPage extends StatefulWidget {
  const RecommandPage({super.key});

  @override
  State<RecommandPage> createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  List<Map<String, dynamic>> _list = [
    {"title": "如何提升显卡性能", "up": 234, "detail": "大家有什么好的方法可以分享一下吗"},
    {"title": "Adobe常用软件破解分享", "up": 124, "detail": "新手小白上路，想快速下载Adobe常用软件吗，资源分享"},
    {"title": "求助：如何解决电脑蓝屏问题", "up": 23, "detail": "最近电脑使用过程中，经常蓝屏，希望大佬帮忙解决一下"},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("推荐帖子"),
        Expanded(
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                constraints: BoxConstraints(minHeight: 50),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.person_2_outlined, size: 32),
                    SizedBox(width: 10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              _list[index]['title'],
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${_list[index]['up']}点赞",
                              style: TextStyle(color: Colors.grey[400]),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${_list[index]['detail']}",
                              style: TextStyle(color: Colors.grey[400],fontSize: 14),
                            )
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              );
            },
          ),
        )
      ],
    ));
  }
}
