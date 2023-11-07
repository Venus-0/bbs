import 'dart:convert';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/views/bbs/bbs_detail.dart';
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

  @override
  void initState() {
    super.initState();
    getList();
    eventBus.on<BBSBus>().listen((event) {
      getList(refersh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getList({bool refersh = false}) async {
    if (refersh) {
      _startIndex = 0;
    }
    Map _res = await Api.getBBSList(_startIndex, type: BBSModel.TYPE_POST);
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

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("推荐帖子"),
        Expanded(
            child: SmartRefresher(
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
              return GestureDetector(
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
                      margin: EdgeInsets.symmetric(vertical: 5),
                      constraints: BoxConstraints(minHeight: 50),
                      width: double.infinity,
                      child: Row(
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
              );
            },
          ),
        ))
      ],
    ));
  }
}
