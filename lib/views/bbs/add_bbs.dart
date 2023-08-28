import 'package:bbs/http/api.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/toast.dart';
import 'package:flutter/material.dart';

class AddBBSPage extends StatefulWidget {
  const AddBBSPage({super.key});

  @override
  State<AddBBSPage> createState() => _AddBBSPageState();
}

class _AddBBSPageState extends State<AddBBSPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _onBusy = false;

  void onAdd() async {
    if (_onBusy) return;
    String _title = _titleController.text;
    String _content = _contentController.text;

    if (_title.isEmpty) {
      Toast.showToast("请输入标题");
      return;
    }
    if (_content.isEmpty) {
      Toast.showToast("请输入正文");
      return;
    }
    Map _res = await Api.addBBS(_title, _content, 3);
    if (_res['code'] == 200) {
      Toast.showToast("新内容已发布!");
      eventBus.fire(BBSBus());
      Navigator.pop(context);
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "发布新内容",
          style: TextStyle(color: Color(0xFFD8D8D8)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [TextButton(onPressed: onAdd, child: Text("发布"))],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: "请输入标题",
                hintStyle: TextStyle(
                  color: Color(0xFFD8D8D8),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(height: 1.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: "请输入正文",
                hintStyle: TextStyle(color: Color(0xFFD8D8D8)),
              ),
              minLines: 1,
              maxLines: 999,
            ),
          ],
        ),
      ),
    );
  }
}
