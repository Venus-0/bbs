import 'package:bbs/http/api.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/sharedPreferenceUtil.dart';
import 'package:bbs/views/home/home_page.dart';
import 'package:bbs/views/login/login.dart';
import 'package:flutter/material.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    await Future.delayed(Duration(milliseconds: 1000));
    String _cookie = await SharedPreferenceUtil.getCookie();
    if (_cookie.isEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else {
      Map _res = await Api.checkLogin();
      if (_res['code'] == 200) {
        GlobalModel.user = UserModel.fromJson(_res['result']['user']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
