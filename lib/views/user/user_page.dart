import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 80, height: 80,child: Icon(Icons.person,size: 80,),),
              SizedBox(width: 20),
              Text(
                "BK199",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "10",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                "粉丝",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 30),
              Text(
                "20",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                "点赞",
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
          SizedBox(height: 50),
          TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit, color: Colors.grey[400]),
              label: Text("我的帖子", style: TextStyle(color: Colors.grey[400]))),
          TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.thumb_up, color: Colors.grey[400]),
              label: Text("我赞过的内容", style: TextStyle(color: Colors.grey[400]))),
          TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.favorite, color: Colors.grey[400]),
              label: Text("我的收藏", style: TextStyle(color: Colors.grey[400]))),
        ],
      ),
    );
  }
}
