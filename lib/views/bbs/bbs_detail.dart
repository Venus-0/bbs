import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/comment_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/bbs/comment_item.dart';
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
      isLoad = false;
      setState(() {});
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
    }
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

  @override
  Widget build(BuildContext context) {
    Widget _load = Row(
      children: [Icon(Icons.person_2_outlined)],
    );

    Widget _userSheet = Row(
      children: [
        Icon(Icons.person_2_outlined),
        SizedBox(width: 10),
        Text(_user?.username ?? "未知用户"),
        Spacer(),
        ...GlobalModel.user!.user_id == _user?.user_id
            ? []
            : [
                RawMaterialButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.add), Text('关注')],
                  ),
                )
              ]
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("正文"),
        centerTitle: true,
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
                SizedBox(height: 20),
                Hero(
                    tag: widget.bbs.id,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...isLoad ? [_load] : [_userSheet],
                          Text(_bbs?.title ?? "--", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_bbs?.content ?? "--"),
                          Divider(),
                        ],
                      ),
                    )),
                ...List.generate(
                    _commentList.length,
                    (index) => CommentItem(
                          commnet: _commentList[index]['comment'],
                          subComment: _commentList[index]['subComments'],
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up, color: Color(0xff636e72)),
                    Text(
                      "${widget.bbs.up_count}",
                      style: TextStyle(color: Color(0xff636e72)),
                    ),
                  ],
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
