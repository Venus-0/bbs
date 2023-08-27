import 'dart:math';

import 'package:bbs/http/api.dart';
import 'package:bbs/http/http.dart';
import 'package:bbs/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _nickNameController = TextEditingController(); //昵称文本控制器
  TextEditingController _emailController = TextEditingController(); //邮箱文本控制器
  TextEditingController _pwdController = TextEditingController(); //密码文本控制器
  TextEditingController _pwdTwiceController = TextEditingController(); //验证密码文本控制器
  bool _showPassword = false;

  bool _onBusy = false;

  ///注册
  void onRegister() async {
    if (_onBusy) return;
    String _name = _nickNameController.text;
    String _email = _emailController.text;
    String _pwd = _pwdController.text;
    if (_name.isEmpty) {
      Toast.showToast("请填写一个昵称");
      return;
    }
    if (_email.isEmpty) {
      Toast.showToast("请填写邮箱");
      return;
    }
    if (_pwd.isEmpty) {
      Toast.showToast("密码不能为空");
      return;
    }
    if (_pwd.length <= 4) {
      Toast.showToast("请输入一个长度大于4位的密码");
      return;
    }
    if (_pwd != _pwdTwiceController.text) {
      Toast.showToast("两次密码不一致");
      return;
    }

    _onBusy = true;
    EasyLoading.show();
    Map _res = await Api.register(_name, _email, _pwd);
    EasyLoading.dismiss();
    _onBusy = false;
    if (_res['code'] == 200) {
      Toast.showToast("注册成功");
      Navigator.pop(context);
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
              alignment: Alignment(0, -0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 4.0, color: Color(0xFFD8D8D8), blurStyle: BlurStyle.outer)],
                ),
                width: 300,
                height: 360,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "注册",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    TextField(
                      controller: _nickNameController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                        hintText: "昵称",
                        hintStyle: TextStyle(color: Color(0xFFD8D8D8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),
                    TextField(
                      controller: _pwdTwiceController,
                      textAlign: TextAlign.center,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                        hintText: "确认密码",
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
                  margin: EdgeInsets.only(bottom: max(0, 80 - MediaQuery.of(context).viewInsets.bottom / 2)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        onPressed: onRegister,
                        icon: Icon(Icons.check_rounded),
                        iconSize: 48,
                        splashColor: Color(0xFFD8D8D8),
                        splashRadius: 10.0,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("返回"))
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
