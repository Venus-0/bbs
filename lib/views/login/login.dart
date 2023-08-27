import 'dart:math';

import 'package:bbs/http/api.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/login/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool _showPassword = false;

  bool _onBusy = false;

  ///注册
  void onRegister() async {
    if (_onBusy) return;
    String _email = _emailController.text;
    String _pwd = _pwdController.text;
    
    if (_email.isEmpty) {
      Toast.showToast("请填写邮箱");
      return;
    }
    if (_pwd.isEmpty) {
      Toast.showToast("密码不能为空");
      return;
    }

    _onBusy = true;
    EasyLoading.show();
    Map _res = await Api.login(_email, _pwd);
    EasyLoading.dismiss();
    _onBusy = false;
    if (_res['code'] == 200) {
      Toast.showToast("登录成功");
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
    }

    print(_res);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
          body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, -0.2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 4.0, color: Color(0xFFD8D8D8), blurStyle: BlurStyle.outer)],
                ),
                width: 300,
                height: 260,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "登录",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                        hintText: "邮箱",
                        hintStyle: TextStyle(color: Color(0xFFD8D8D8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _pwdController,
                      textAlign: TextAlign.center,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                        hintText: "密码",
                        hintStyle: TextStyle(color: Color(0xFFD8D8D8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment(0, 1),
                child: Container(
                  margin: EdgeInsets.only(bottom: max(0, 100 - MediaQuery.of(context).viewInsets.bottom / 2)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward),
                        iconSize: 48,
                        splashColor: Color(0xFFD8D8D8),
                        splashRadius: 10.0,
                      ),
                      SizedBox(height: 10),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => RegisterPage(),
                                ));
                          },
                          child: Text("注册"))
                    ],
                  ),
                ))
          ],
        ),
      )),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
