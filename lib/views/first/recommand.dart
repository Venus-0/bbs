import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/notice_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/views/bbs/bbs_detail.dart';
import 'package:bbs/views/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecommandPage extends StatefulWidget {
  const RecommandPage({super.key});

  @override
  State<RecommandPage> createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  RefreshController _refreshController = RefreshController();
  List<BBSModel> _bbsList = [];
  int _startIndex = 0;
  int _totalData = 0;
  NoticeModel? _notice;

  @override
  void initState() {
    super.initState();
    getNotice();
    getList();
    eventBus.on<BBSBus>().listen((event) {
      getList(refersh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getNotice() async {
    _notice = await Api.getNotice();
    setState(() {});
  }

  Future<void> getList({bool refersh = false}) async {
    if (refersh) {
      _startIndex = 0;
    }
    Map _res = await Api.getRecommandBBSList(_startIndex);
    print(_res);
    if (_res['code'] == 200) {
      if (refersh) {
        _bbsList = [];
      }
      List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res['result']['data']);
      for (final json in _list) {
        BBSModel _bbsModel = BBSModel.fromJson(json);
        _bbsList.add(_bbsModel);
      }
      _totalData = _res['result']['page']['total'];
      _startIndex += (_res['result']['page']['returnDataCount'] ?? 0) as int;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar(BBSModel bbs) {
      if ((bbs.avatar ?? "").isEmpty) {
        return Icon(Icons.person_2_outlined);
      } else {
        return Image.memory(base64Decode(bbs.avatar!.split(",").last));
      }
    }

    return SmartRefresher(
      onRefresh: () {
        getList().then((value) {
          _refreshController.refreshCompleted();
        });
      },
      onLoading: () {
        if (_startIndex == _totalData) {
          _refreshController.loadNoData();
        } else {
          getList().then((value) {
            _refreshController.loadComplete();
          });
        }
      },
      enablePullUp: true,
      controller: _refreshController,
      child: ListView.builder(
        itemCount: _bbsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ...index == 0 && _notice != null ? [Notice(notice: _notice!)] : [],
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BBSDetail(bbs: _bbsList[index]),
                      ));
                },
                child: Hero(
                    tag: _bbsList[index].id,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      constraints: BoxConstraints(minHeight: 50),
                      decoration: GlobalWidegt.commonDecoration,
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: _getAvatar(_bbsList[index]),
                          ),
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
                                    _bbsList[index].title,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "${_bbsList[index].up_count}点赞",
                                    style: TextStyle(color: Colors.grey[400]),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${_bbsList[index].content}",
                                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  )
                                ],
                              )
                            ],
                          ))
                        ],
                      ),
                    )),
              )
            ],
          );
        },
      ),
    );
  }
}

class Notice extends StatefulWidget {
  const Notice({super.key, required this.notice});
  final NoticeModel notice;
  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  @override
  Widget build(BuildContext context) {
    void show() {
      showDialog(
          context: context,
          builder: (context) => Dialog(
                child: Container(
                  decoration: GlobalWidegt.commonDecoration,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    children: [
                      ...widget.notice.getImage() == null
                          ? []
                          : [
                              Expanded(
                                child: Container(
                                  color: Color(0xffd8d8d8),
                                  child: widget.notice.getImage(fit: BoxFit.cover),
                                ),
                                flex: 3,
                              )
                            ],
                      Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.notice.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(widget.notice.content),
                                ],
                              ),
                            ),
                          ),
                          flex: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            "返回",
                            style: TextStyle(color: Color(0xFF2ecc71)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ));
    }

    return GestureDetector(
      onTap: show,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        constraints: BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
            image: widget.notice.getImage() == null
                ? null
                : DecorationImage(
                    image: widget.notice.getImage()!.image,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.dstATop,
                    ),
                  ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0xFFD8D8D8),
                blurStyle: BlurStyle.outer,
              ),
            ]),
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: 200,
        child: Text(
          widget.notice.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
