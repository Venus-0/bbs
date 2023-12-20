import 'package:flutter/material.dart';
import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/views/bbs/bbs_item.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DigestPage extends StatefulWidget {
  const DigestPage({super.key});

  @override
  State<DigestPage> createState() => _DigestPageState();
}

class _DigestPageState extends State<DigestPage> {
  RefreshController _refreshController = RefreshController();
  List<BBSModel> _bbsList = [];
  int _startIndex = 0;
  int _totalData = 0;

  @override
  void initState() {
    super.initState();
    getList();
    eventBus.on<BBSBus>().listen((event) {
      getList(refresh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getList({bool refresh = false}) async {
    if (refresh) {
      _startIndex = 0;
    }
    Map _res = await Api.getStarBBSList(_startIndex);
    print(_res);
    if (_res['code'] == 200) {
      if (refresh) {
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
    return Container(
        child: SmartRefresher(
      onRefresh: () {
        getList(refresh: true).then((value) {
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
          return BBSItem(
            key: UniqueKey(),
            bbs: _bbsList[index],
          );
        },
      ),
    ));
  }
}
