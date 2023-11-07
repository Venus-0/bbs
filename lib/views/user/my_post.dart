import 'package:bbs/http/api.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/views/bbs/bbs_item.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyPost extends StatefulWidget {
  const MyPost({super.key, required this.bbsList});
  final List<BBSModel> bbsList;
  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  RefreshController _refreshController = RefreshController();
  List<BBSModel> _bbsList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bbsList = widget.bbsList;
  }

  Future<void> getDetail() async {
    final (_, _, _, _, _bbsList) = await Api.getUserDetail(GlobalModel.user!.user_id);
    setState(() {
      this._bbsList = _bbsList ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("我的帖子"), centerTitle: true),
        body: SmartRefresher(
          onRefresh: () {
            getDetail().then((value) {
              _refreshController.refreshCompleted();
            });
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
