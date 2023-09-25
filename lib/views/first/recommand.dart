import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/event_bus.dart';
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
  int _page = 1;
  int _totalPage = 1;

  @override
  void initState() {
    super.initState();
    getList();
    eventBus.on<BBSBus>().listen((event) {
      getList();
    });
  }

  Future<void> getList({bool refersh = false}) async {
    if (refersh) {
      _page = 1;
    }
    Map _res = await Api.getBBSList(_page, type: BBSModel.TYPE_POST);
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
      _totalPage = _res['result']['page']['total'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            if (_page == _totalPage) {
              _refreshController.loadNoData();
            } else {
              _page++;
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
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                constraints: BoxConstraints(minHeight: 50),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.person_2_outlined, size: 32),
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
              );
            },
          ),
        ))
      ],
    ));
  }
}
