import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GlobalWidegt {
  static Widget getRefreshFooter() => CustomFooter(
        builder: (context, mode) {
          late Widget body;
          TextStyle style = TextStyle(color: Color(0xffd8d8d8));
          if (mode == LoadStatus.canLoading) {
            body = Text("松手，加载更多", style: style);
          } else if (mode == LoadStatus.noMore) {
            body = Text("没有更多了", style: style);
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败，请重试", style: style);
          } else if (mode == LoadStatus.loading) {
            body = Text("加载中....", style: style);
          } else if (mode == LoadStatus.idle) {
            body = Text("上拉加载", style: style);
          } else {
            body = Container();
          }
          return Container(height: 55, child: body);
        },
      );

  static BoxDecoration get commonDecoration => BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 4,
          color: Color(0xFFD8D8D8),
          blurStyle: BlurStyle.outer,
        )
      ]);
}
