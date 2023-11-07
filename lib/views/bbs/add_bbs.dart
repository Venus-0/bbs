import 'dart:convert';
import 'dart:typed_data';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/widgets/image_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
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
  int _type = BBSModel.TYPE_POST;

  List<Uint8List> _imageList = [];

  final int MAX_IMAGE = 9; //最多支持上传9张图

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

    List<String> _base64Images = [];
    for (final _imageByte in _imageList) {
      _base64Images.add(base64Encode(_imageByte));
    }

    Map _res = await Api.addBBS(_title, _content, _type, jsonEncode(_base64Images));
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
    Widget _image() {
      List<Widget> _list = [];
      for (int i = 0; i < _imageList.length; i++) {
        Image _image = Image.memory(_imageList[i]);
        _list.add(Hero(
            tag: _image.hashCode,
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _imageList.removeAt(i);
                });
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreview(image: _image, tag: _image.hashCode),
                    ));
              },
              child: _image,
            )));
      }
      if (_imageList.length < 9) {
        _list.add(GestureDetector(
          onTap: () async {
            // if (await Permission.photos.isGranted) {
            FilePickerResult? _result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, withData: true);
            print(_result?.count);

            if ((_result?.count ?? 0) + _imageList.length > 9) {
              Toast.showToast("最多支持上传9张图哦");
            }
            for (int i = 0; i < 9 - _imageList.length; i++) {
              if (i >= (_result?.files.length ?? 0)) break;
              Uint8List? _imageBytes = _result?.files[i].bytes;
              print(_imageBytes?.length);
              if (_imageBytes != null) {
                _imageList.add(_imageBytes);
              }
            }
            setState(() {});
            // }
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffd8d8d8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.add,
              color: Color(0xffd8d8d8),
            ),
          ),
        ));
      }

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return _list[index];
        },
      );
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      _type = BBSModel.TYPE_POST;
                    });
                  },
                  child: Text(
                    "帖子",
                    style: TextStyle(color: _type == BBSModel.TYPE_POST ? Colors.white : Color(0xfff39c12)),
                  ),
                  fillColor: _type == BBSModel.TYPE_POST ? Color(0xfff39c12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      _type = BBSModel.TYPE_WIKI;
                    });
                  },
                  child: Text(
                    "WIKI",
                    style: TextStyle(color: _type == BBSModel.TYPE_WIKI ? Colors.white : Color(0xfff39c12)),
                  ),
                  fillColor: _type == BBSModel.TYPE_WIKI ? Color(0xfff39c12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      _type = BBSModel.TYPE_QUESTION;
                    });
                  },
                  child: Text(
                    "问题",
                    style: TextStyle(color: _type == BBSModel.TYPE_QUESTION ? Colors.white : Color(0xfff39c12)),
                  ),
                  fillColor: _type == BBSModel.TYPE_QUESTION ? Color(0xfff39c12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
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
            SizedBox(height: 30),
            Expanded(
              child: _image(),
            )
          ],
        ),
      ),
    );
  }
}
