import 'package:bbs/model/user_bean.dart';
import 'package:flutter/material.dart';

class GlobalModel extends ChangeNotifier {
  static GlobalKey navigatorKey = GlobalKey();
  static UserModel? user;
}
