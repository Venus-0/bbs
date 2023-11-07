import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/views/bbs/bbs_detail.dart';
import 'package:bbs/views/widgets/image_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BBSItem extends StatefulWidget {
  const BBSItem({super.key, required this.bbs, this.enableLike = true});
  final BBSModel bbs;
  final bool enableLike;
  @override
  State<BBSItem> createState() => _BBSItemState();
}

class _BBSItemState extends State<BBSItem> {
  bool _onBusy = false;
  bool _isLike = false;
  bool _isLoad = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLike();
  }

  void getLike() async {
    _isLike = await Api.checkLike(widget.bbs.question_type, widget.bbs.id);
    _isLoad = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar() {
      if ((widget.bbs.avatar ?? "").isEmpty) {
        return Icon(Icons.person_2_outlined);
      } else {
        return Image.memory(base64Decode(widget.bbs.avatar!.split(",").last));
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BBSDetail(bbs: widget.bbs),
            ));
      },
      child: Container(
        // height: 300,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey.withAlpha(76),
        ))),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...widget.enableLike
                    ? [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: _getAvatar(),
                        ),
                        SizedBox(width: 10),
                      ]
                    : [],
                Text(widget.bbs.title),
              ],
            ),
            Text(widget.bbs.content),
            ...widget.bbs.images.isEmpty
                ? []
                : [
                    Hero(
                        tag: "${widget.bbs.id}_image",
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImagePreview(image: Image.memory(widget.bbs.images[0]), tag: "${widget.bbs.id}_image"),
                                ));
                          },
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.memory(widget.bbs.images[0]),
                          ),
                        ))
                  ],
            Row(
              children: [
                TextButton.icon(
                    onPressed: () async {
                      if (_onBusy || _isLoad || !widget.enableLike) return;
                      _onBusy = true;
                      if (_isLike) {
                        setState(() {
                          _isLike = false;
                          widget.bbs.up_count--;
                        });
                        bool _ret = await Api.unlike(widget.bbs.question_type, widget.bbs.id);
                        _onBusy = false;

                        if (!_ret) {
                          setState(() {
                            _isLike = true;
                            widget.bbs.up_count++;
                          });
                        }
                      } else {
                        setState(() {
                          _isLike = true;
                          widget.bbs.up_count++;
                        });
                        bool _ret = await Api.like(widget.bbs.question_type, widget.bbs.id);
                        _onBusy = false;
                        if (!_ret) {
                          setState(() {
                            _isLike = false;
                            widget.bbs.up_count--;
                          });
                        }
                      }
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      color: _isLike ? Color(0xFFeb4d4b) : Colors.grey[400], //
                      size: 14,
                    ),
                    label: Text("点赞 ${widget.bbs.up_count}", style: TextStyle(color: _isLike ? Color(0xFFeb4d4b) : Colors.grey[400]))),
                SizedBox(width: 30),
                TextButton(onPressed: () async {}, child: Text("评论 ${widget.bbs.reply_count}", style: TextStyle(color: Colors.grey[400]))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
