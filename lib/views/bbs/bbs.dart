import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BBS extends StatefulWidget {
  const BBS({super.key});

  @override
  State<BBS> createState() => _BBSState();
}

class _BBSState extends State<BBS> {
  RefreshController _refreshController = RefreshController();
  List<BBSModel> _bbsList = [];

  @override
  void initState() {
    super.initState();
    getList();
    eventBus.on<BBSBus>().listen((event) {
      getList();
    });
  }

  Future<void> getList() async {
    Map _res = await Api.getBBSList();
    print(_res);
    if (_res['code'] == 200) {
      _bbsList = [];
      List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res['result']['data']);
      for (final json in _list) {
        BBSModel _bbsModel = BBSModel.fromJson(json);
        _bbsList.add(_bbsModel);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SmartRefresher(
      onRefresh: () {
        getList().then((value) {
          _refreshController.refreshCompleted();
        });
      },
      controller: _refreshController,
      child: ListView.builder(
        itemCount: _bbsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
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
                    Text(_bbsList[index].title),
                  ],
                ),
                Expanded(child: Text(_bbsList[index].content)),
                Row(
                  children: [
                    TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.thumb_up,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        label: Text("点赞", style: TextStyle(color: Colors.grey[400]))),
                    SizedBox(width: 30),
                    TextButton(onPressed: () {}, child: Text("评论", style: TextStyle(color: Colors.grey[400]))),
                  ],
                )
              ],
            ),
          );
        },
      ),
    ));
  }
}

class BBSItem extends StatefulWidget {
  const BBSItem({super.key, required this.bbs});
  final BBSModel bbs;
  @override
  State<BBSItem> createState() => _BBSItemState();
}

class _BBSItemState extends State<BBSItem> {
  CancelToken? _cancelToken;

  void getLike(){
    

  }



  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.thumb_up,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                  label: Text("点赞 ${widget.bbs.up_count}", style: TextStyle(color: Colors.grey[400]))),
              SizedBox(width: 30),
              TextButton(onPressed: () {}, child: Text("评论 ${widget.bbs..reply_count}", style: TextStyle(color: Colors.grey[400]))),
            ],
          )
        ],
      ),
    );
  }
}
