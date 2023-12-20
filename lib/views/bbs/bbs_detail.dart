import 'dart:convert';
import 'dart:math';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/comment_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/bbs/comment_item.dart';
import 'package:bbs/views/user/user_info.dart';
import 'package:bbs/views/widgets/image_preview.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BBSDetail extends StatefulWidget {
  const BBSDetail({super.key, required this.bbs});
  final BBSModel bbs;
  @override
  State<BBSDetail> createState() => _BBSDetailState();
}

class _BBSDetailState extends State<BBSDetail> {
  UserModel? _user;
  BBSModel? _bbs;
  bool isLoad = true;

  int _startIndex = 0;
  int _totalData = 0;

  List<Map<String, dynamic>> _commentList = []; //评论列表

  RefreshController _refreshController = RefreshController(); //下拉刷新

  TextEditingController _addCommentController = TextEditingController();

  bool _onBusy = false;

  bool _isSubscribe = false; //是否关注当前用户

  bool _isBusy = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetail();
    getComment();
  }

  Future<void> getDetail() async {
    Map _res = await Api.getPostDetail(widget.bbs.id);
    if (_res['code'] == 200) {
      Map<String, dynamic> _result = _res['result'];
      _bbs = BBSModel.fromJson(_result['post']);
      _user = UserModel.fromJson(_result['user']);
      if (GlobalModel.user!.user_id != _user?.user_id) {
        _checkSubscribe();
      }
      isLoad = false;
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
    }
  }

  void _checkSubscribe() async {
    _isSubscribe = await Api.checkSubscribe(_user!.user_id);
    setState(() {});
  }

  Future<void> getComment({bool refresh = false}) async {
    if (refresh) {
      _startIndex = 0;
    }
    Map _res = await Api.getCommentList(_startIndex, widget.bbs.id);
    if (_res['code'] == 200) {
      if (refresh) {
        _commentList.clear();
      }
      List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res['result']['list']);
      for (Map<String, dynamic> _comments in _list) {
        Map<String, dynamic> _comment = {};
        _comment['comment'] = CommentModel.fromJson(_comments);
        List<CommentModel> _subComments = [];
        for (Map<String, dynamic> _subComment in _comments['subComment']) {
          _subComments.add(CommentModel.fromJson(_subComment));
        }
        _comment['subComments'] = _subComments;
        _commentList.add(_comment);
      }

      _totalData = _res['result']['page']['total'] ?? 0;
      _startIndex += (_res['result']['page']['returnDataCount'] ?? 0) as int;
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? '出错了');
    }
  }

  void onReply(String comment) async {
    EasyLoading.show();
    Map _res = await Api.addComment(widget.bbs.id, widget.bbs.question_type, comment);
    EasyLoading.dismiss();
    if (_res['code'] == 200) {
      _addCommentController.clear();
      int _id = _res['result']['id'];
      CommentModel _comment = CommentModel(
        id: _id,
        user: GlobalModel.user,
        comment: comment,
        comment_type: CommentModel.TYPE_COMMENT,
        comment_id: widget.bbs.id,
        user_id: GlobalModel.user?.user_id ?? 0,
      );
      _commentList.add({"comment": _comment, "subComments": <CommentModel>[]});
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? '出错了');
    }
  }

  void onDeletePost() async {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("提示"),
              content: Text("是否删除该贴?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "是",
                      style: TextStyle(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("否")),
              ],
            ));
  }

  void onUnSubscribe() async {
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _isSubscribe = false;
    });
    Api.unSubScribe(_user!.user_id).then((value) {
      if (!value) {
        Toast.showToast("出错了");
        setState(() {
          _isSubscribe = true;
        });
      } else {
        eventBus.fire(SubscribeChange());
      }
    });
  }

  void onSubscribe() async {
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _isSubscribe = true;
    });
    Api.subscribeUser(_user!.user_id).then((value) {
      if (!value) {
        Toast.showToast("出错了");
        setState(() {
          _isSubscribe = false;
        });
      } else {
        eventBus.fire(SubscribeChange());
      }
    });
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

    void _showPostEdit() {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: 66,
                child: ListView(
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 42,
                        margin: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          '删除帖子',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      onTap: onDeletePost,
                    ),
                  ],
                ),
              ));
    }

    Widget _load = Row(
      children: [Icon(Icons.person_2_outlined)],
    );

    Widget _subscribe = GestureDetector(
      onTap: () {
        if (_isSubscribe) {
          onUnSubscribe();
        } else {
          onSubscribe();
        }
      },
      child: Container(
        width: 80,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _isSubscribe ? null : Color(0xff1c1a18),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _isSubscribe ? Color(0xffd8d8d8) : Color(0xff1c1a18), width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _isSubscribe
              ? [
                  Icon(Icons.check, color: Colors.black45),
                  Text("已关注", style: TextStyle(color: Colors.black45)),
                ]
              : [
                  Icon(Icons.add, color: Colors.white),
                  Text("关注", style: TextStyle(color: Colors.white)),
                ],
        ),
      ),
    );

    Widget _userSheet = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_user == null) return;
        if (_user!.user_id == GlobalModel.user?.user_id) return;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfo(user: _user!),
            ));
      },
      child: Row(
        children: [
          SizedBox(
            height: 42,
            width: 42,
            child: _getAvatar(),
          ),
          SizedBox(width: 10),
          Text(_user?.username ?? "未知用户"),
          Spacer(),
          ...GlobalModel.user!.user_id == _user?.user_id || _user?.disable_time != null ? [] : [_subscribe]
        ],
      ),
    );

    int imageCount = widget.bbs.images.length;
    double width = (MediaQuery.of(context).size.width - 20);
    int column = imageCount >= 3 ? 3 : max(1, imageCount % 3);
    if (imageCount == 2 || imageCount == 4) {
      column = imageCount ~/ 2;
    }
    double _imageWidth = width / column;
    double _gridHeight = imageCount > 3 ? width : width / min(imageCount, 3);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text("正文"),
        ),
        centerTitle: true,
        actions:
            widget.bbs.user_id == GlobalModel.user?.user_id ? [IconButton(onPressed: _showPostEdit, icon: Icon(Icons.more_horiz))] : [],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              await getDetail();
              await getComment(refresh: true);
              _refreshController.refreshCompleted();
            },
            onLoading: () {
              if (_startIndex == _totalData) {
                _refreshController.loadNoData();
              } else {
                getComment().then((value) {
                  _refreshController.loadComplete();
                });
              }
            },
            enablePullUp: true,
            child: ListView(
              children: [
                // SizedBox(
                //   height: widget.bbs.images.isEmpty ? 20 : 160,
                //   child: Swiper(
                //     itemCount: widget.bbs.images.length,
                //     itemBuilder: (context, index) {
                //       Image _image = Image.memory(widget.bbs.images[index]);

                //       return Hero(
                //           tag: _image.hashCode,
                //           child: GestureDetector(
                //             onTap: () {
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) => ImagePreview(image: _image, tag: _image.hashCode),
                //                   ));
                //             },
                //             child: _image,
                //           ));
                //     },
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: widget.bbs.id,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...isLoad ? [_load] : [_userSheet],
                            Text(_bbs?.title ?? "--", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(_bbs?.content ?? "--"),
                          ],
                        ),
                      ),
                      ...widget.bbs.images.isNotEmpty
                          ? [
                              SizedBox(
                                height: _gridHeight,
                                width: double.infinity,
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: column,
                                    // crossAxisCount: (widget.bbs.images.length > 3 ? 3 : widget.bbs.images.length),
                                  ),
                                  itemCount: widget.bbs.images.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    Image _image = Image.memory(widget.bbs.images[index], fit: BoxFit.cover, width: _imageWidth);
                                    return Hero(
                                        tag: _image.hashCode,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ImagePreview(image: widget.bbs.images[index], tag: _image.hashCode),
                                                ));
                                          },
                                          child: _image,
                                        ));
                                  },
                                ),
                              )
                            ]
                          : [],
                      Divider(),
                    ],
                  ),
                ),

                ...List.generate(
                    _commentList.length,
                    (index) => CommentItem(
                          commnet: _commentList[index]['comment'],
                          subComment: _commentList[index]['subComments'],
                          bbsUserId: widget.bbs.user_id,
                        )),
              ],
            ),
          )),
          Container(
            constraints: BoxConstraints(minHeight: 80),
            child: Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    minLines: 1,
                    maxLines: 3,
                    controller: _addCommentController,
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
                      hintText: "评论(已有${widget.bbs.reply_count}条评论)",
                      hintStyle: TextStyle(color: Color(0xffdfe6e9)),
                      suffix: GestureDetector(
                        onTap: () {
                          String _comment = _addCommentController.text;
                          if (_comment.isEmpty) {
                            Toast.showToast("总得写点东西吧");
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          onReply(_comment);
                        },
                        child: Text(
                          "回复",
                          style: TextStyle(color: Color(0xff3498db)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                //点赞数
                FutureBuilder(
                  future: Api.checkLike(widget.bbs.question_type, widget.bbs.id),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      bool _like = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () async {
                          if (_onBusy) return;
                          _onBusy = true;
                          if (_like) {
                            bool _ret = await Api.unlike(widget.bbs.question_type, widget.bbs.id);
                            _onBusy = false;
                            if (_ret) {
                              setState(() {
                                widget.bbs.up_count--;
                              });
                            }
                          } else {
                            bool _ret = await Api.like(widget.bbs.question_type, widget.bbs.id);
                            _onBusy = false;
                            if (_ret) {
                              setState(() {
                                widget.bbs.up_count++;
                              });
                            }
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up, color: _like ? Color(0xFFeb4d4b) : Color(0xff636e72)),
                            Text(
                              "${widget.bbs.up_count}",
                              style: TextStyle(color: Color(0xff636e72)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up, color: Color(0xff636e72)),
                            Text(
                              "${widget.bbs.up_count}",
                              style: TextStyle(color: Color(0xff636e72)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(width: 20),
                //评论数
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble, color: Color(0xff636e72)),
                    Text(
                      "${widget.bbs.reply_count}",
                      style: TextStyle(color: Color(0xff636e72)),
                    ),
                  ],
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
