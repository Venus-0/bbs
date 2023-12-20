import 'package:bbs/http/api.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/utils/sharedPreferenceUtil.dart';
import 'package:bbs/utils/toast.dart';
import 'package:bbs/views/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UserEditPassword extends StatefulWidget {
  const UserEditPassword({super.key});

  @override
  State<UserEditPassword> createState() => _UserEditPasswordState();
}

class _UserEditPasswordState extends State<UserEditPassword> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _oldController = TextEditingController();
  TextEditingController _newController = TextEditingController();
  TextEditingController _newAController = TextEditingController();

  void onEdit() async {
    if (_formKey.currentState?.validate() ?? false) {
      String _old = _oldController.text;
      String _new = _newController.text;
      String _newA = _newAController.text;
      if (_old == _new) {
        Toast.showToast("新旧密码不能一致");
        return;
      }
      if (_new != _newA) {
        Toast.showToast("两次新密码不一致");
      }
      if (_new.length <= 4) {
        Toast.showToast("请输入一个长度大于4位的密码");
        return;
      }
      EasyLoading.show();
      bool _isEdit = await Api.editPassword(_old, _new, _newA);
      EasyLoading.dismiss();
      if (_isEdit) {
        SharedPreferenceUtil.remove(SharedPreferenceUtil.COOKIE);
        GlobalModel.user = null;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
        Toast.showToast("修改完成，请重新登录");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("修改密码"),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      "旧密码",
                    ),
                  ),
                  SizedBox(width: 100),
                  Expanded(
                      child: TextFormField(
                    obscureText: true,
                    controller: _oldController,
                    validator: (newValue) {
                      if ((newValue ?? '').isEmpty) return "不能为空";
                    },
                  ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      "新密码",
                    ),
                  ),
                  SizedBox(width: 100),
                  Expanded(
                      child: TextFormField(
                    obscureText: true,
                    controller: _newController,
                    validator: (newValue) {
                      if ((newValue ?? '').isEmpty) return "不能为空";
                    },
                  ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      "再输入一次",
                    ),
                  ),
                  SizedBox(width: 100),
                  Expanded(
                      child: TextFormField(
                    obscureText: true,
                    controller: _newAController,
                    validator: (newValue) {
                      if ((newValue ?? '').isEmpty) return "不能为空";
                    },
                  ))
                ],
              ),
            ),
            SizedBox(height: 20),
            RawMaterialButton(
              onPressed: onEdit,
              child: Text(
                "保存",
                style: TextStyle(color: Colors.white),
              ),
              constraints: BoxConstraints(minWidth: 180, minHeight: 36),
              fillColor: Color(0xff2edfa3),
              shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xff2edfa3)), borderRadius: BorderRadius.circular(8)),
            )
          ],
        ),
      )),
    );
  }
}
