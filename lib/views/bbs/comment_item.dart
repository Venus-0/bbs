import 'package:bbs/http/api.dart';
import 'package:bbs/model/comment_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({super.key, required this.commnet, this.subComment = const []});
  final CommentModel commnet;
  final List<CommentModel> subComment;
  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  String? getReply(int subId) {
    if (subId == widget.commnet.id) return null;
    int _index = widget.subComment.indexWhere((element) => element.id == subId);
    if (_index == -1) return null;
    return widget.subComment[_index].user?.username;
  }

  final TextStyle _replyerStyle = TextStyle(color: Color(0xff0984e3));
  final TextStyle _replyUserStyle = TextStyle(color: Color(0xffb2bec3));
  final TextStyle _replyCommentStyle = TextStyle(color: Colors.black);

  FocusNode _replyNode = FocusNode();
  TextEditingController _replyController = TextEditingController();

  bool _onBusy = false;

  ///此处都是楼中楼回复
  void onReply(CommentModel commentModel, String comment) async {
    EasyLoading.show();
    Map _res = await Api.addComment(widget.commnet.id, CommentModel.TYPE_COMMENT, comment, commentModel.id);
    EasyLoading.dismiss();
    if (_res['code'] == 200) {
      _replyController.clear();
      int _id = _res['result']['id'];
      CommentModel _comment = CommentModel(
        id: _id,
        user: GlobalModel.user,
        comment: comment,
        comment_type: CommentModel.TYPE_COMMENT,
        comment_id: widget.commnet.id,
        sub_comment_id: commentModel.id,
        user_id: GlobalModel.user?.user_id ?? 0,
      );
      widget.subComment.add(_comment);
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? '出错了');
    }
  }

  void showReply(CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          constraints: BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _replyController,
                focusNode: _replyNode,
                minLines: 1,
                maxLines: 3,
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
                    hintText: "回复${comment.user?.username ?? ""}",
                    hintStyle: TextStyle(color: Color(0xffdfe6e9))),
              )),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () {
                    String _comment = _replyController.text;
                    if (_comment.isEmpty) {
                      Toast.showToast("总得写点东西吧");
                      return;
                    }
                    onReply(comment, _comment);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "回复",
                    style: TextStyle(color: Color(0xff3498db)),
                  )),
            ],
          ),
        ),
      ),
    ).then((value) {
      _replyNode.unfocus();
    });
    _replyNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.person_2_outlined),
              SizedBox(width: 10),
              Text(widget.commnet.user?.username ?? "未知用户"),
              Spacer(),
              FutureBuilder(
                future: Api.checkLike(4, widget.commnet.id),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    bool _like = snapshot.data ?? false;
                    return TextButton.icon(
                        onPressed: () async {
                          if (_onBusy) return;
                          _onBusy = true;
                          if (_like) {
                            bool _ret = await Api.unlike(4, widget.commnet.id);
                            _onBusy = false;
                            if (_ret) {
                              setState(() {
                                widget.commnet.up_count--;
                              });
                            }
                          } else {
                            bool _ret = await Api.like(4, widget.commnet.id);
                            _onBusy = false;
                            if (_ret) {
                              setState(() {
                                widget.commnet.up_count++;
                              });
                            }
                          }
                        },
                        icon: Icon(
                          Icons.thumb_up,
                          color: _like ? Color(0xFFeb4d4b) : Color(0xffb2bec3),
                          size: 18,
                        ),
                        label: Text(
                          "${widget.commnet.up_count}",
                          style: TextStyle(color: Color(0xffb2bec3)),
                        ));
                  } else {
                    return TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.thumb_up,
                          color: Color(0xffb2bec3),
                          size: 18,
                        ),
                        label: Text(
                          "${widget.commnet.up_count}",
                          style: TextStyle(color: Color(0xffb2bec3)),
                        ));
                  }
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              showReply(widget.commnet);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5),
                Text(widget.commnet.comment),
                SizedBox(height: 5),
              ],
            ),
          ),
          ...widget.subComment.isEmpty
              ? []
              : [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xFFD8D8D8).withAlpha(128),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(widget.subComment.length, (index) {
                              String? _replyName = getReply(widget.subComment[index].sub_comment_id!);
                              return GestureDetector(
                                onTap: () {
                                  showReply(widget.subComment[index]);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(text: widget.subComment[index].user?.username ?? "--", style: _replyerStyle),
                                    ..._replyName != null
                                        ? [
                                            TextSpan(text: " 回复 ", style: _replyUserStyle),
                                            TextSpan(text: "$_replyName ", style: _replyUserStyle),
                                          ]
                                        : [],
                                    TextSpan(text: " : ", style: _replyUserStyle),
                                    TextSpan(text: widget.subComment[index].comment, style: _replyCommentStyle),
                                  ])),
                                ),
                              );
                            }),
                          ),
                        ),
                      )
                    ],
                  )
                ]
        ],
      ),
    );
  }
}
