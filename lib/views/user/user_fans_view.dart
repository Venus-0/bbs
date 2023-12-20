import 'dart:math';

import 'package:bbs/http/api.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/views/user/user_subscription_view_item.dart';
import 'package:bbs/views/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserFansView extends StatefulWidget {
  const UserFansView({super.key, required this.user_id});
  final int user_id;
  @override
  State<UserFansView> createState() => _UserFansViewState();
}

class _UserFansViewState extends State<UserFansView> {
  RefreshController _refreshController = RefreshController();
  final int pageSize = 20;
  List<UserModel> _userList = [];
  int _startIndex = 0;
  int _total = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    Map res = await Api.getFansList(widget.user_id, _startIndex, pageSize: pageSize);
    if (res['code'] == 200) {
      List<Map<String, dynamic>> userList = List<Map<String, dynamic>>.from(res['result']['list']);
      _total = res['result']['total'];
      for (final user in userList) {
        _userList.add(UserModel.fromJson(user));
      }
      _startIndex = min(_total, _startIndex + pageSize);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: false,
      footer: GlobalWidegt.getRefreshFooter(),
      onLoading: () {
        if (_startIndex == _total) {
          _refreshController.loadNoData();
        } else {
          _getUser().then((value) {
            _refreshController.loadComplete();
          });
        }
      },
      enablePullUp: true,
      controller: _refreshController,
      child: ListView.builder(
        itemCount: _userList.length,
        itemBuilder: (BuildContext context, int index) {
          return UserSubscriptionViewItem(user: _userList[index], user_id: widget.user_id);
        },
      ),
    );
  }
}
