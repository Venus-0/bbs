import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/views/bbs/bbs_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BBSItem extends StatefulWidget {
  const BBSItem({super.key, required this.bbs});
  final BBSModel bbs;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BBSDetail(bbs: widget.bbs),
            ));
      },
      child: Hero(
          tag: widget.bbs.id,
          child: Container(
            height: 300,
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
                    Icon(Icons.person_2_outlined, size: 24),
                    SizedBox(width: 10),
                    Text(widget.bbs.title),
                  ],
                ),
                Expanded(child: Text(widget.bbs.content)),
                Row(
                  children: [
                    TextButton.icon(
                        onPressed: () async {
                          if (_onBusy || _isLoad) return;
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
                    TextButton(onPressed: () {}, child: Text("评论 ${widget.bbs.reply_count}", style: TextStyle(color: Colors.grey[400]))),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
