import 'dart:convert';

import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';
import 'package:bbs/utils/sharedPreferenceUtil.dart';
import 'package:bbs/views/login/login.dart';
import 'package:bbs/views/user/user_edit_pawssword.dart';
import 'package:flutter/material.dart';
import 'package:bbs/http/api.dart';
import 'package:bbs/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  void _selectAvatar() async {
    // if (await Permission.photos.isGranted) {
    FilePickerResult? _result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (_result?.files[0].bytes != null) {
      String _base64Image = base64Encode(_result!.files[0].bytes!);
      await _onAddAvatar(_base64Image);
    }
    // }
  }

  Future<void> _onAddAvatar(String base64Image) async {
    bool _isAdd = await Api.updateUser(avatar: base64Image);
    if (_isAdd) {
      GlobalModel.user!.avatar = base64Image;
      eventBus.fire(User());
      setState(() {});
    } else {
      Toast.showToast("出错了");
    }
  }

  void _showEditUserName() async {
    String? _newName = await showDialog(context: context, builder: (context) => EditUserNameDialog());
    if (_newName == GlobalModel.user?.username) return;
    if (_newName != null) {
      bool _isAdd = await Api.updateUser(userName: _newName);
      if (_isAdd) {
        GlobalModel.user?.username = _newName;
        eventBus.fire(User());
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _getAvatar() {
      print(GlobalModel.user?.avatar);
      if ((GlobalModel.user?.avatar ?? "").isEmpty) {
        return Icon(
          Icons.person,
          size: 80,
        );
      } else {
        return Image.memory(base64Decode(GlobalModel.user!.avatar!.split(",").last));
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("个人信息"),
        ),
        body: Container(
          color: Color(0xffd8d8d8).withAlpha(32),
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                              height: 66,
                              child: ListView(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      height: 42,
                                      margin: EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: Text('更换头像'),
                                    ),
                                    onTap: _selectAvatar,
                                  ),
                                ],
                              ),
                            ));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Text("头像"),
                        Spacer(),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: _getAvatar(),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showEditUserName,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Text("昵称"),
                        Spacer(),
                        Text("${GlobalModel.user?.username ?? "--"}"),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Text("邮箱"),
                        Spacer(),
                        Text("${GlobalModel.user?.email}"),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, color: Colors.transparent)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Text("注册时间"),
                        Spacer(),
                        Text(
                            "${GlobalModel.user?.create_time == null ? '--' : DateFormat("yyyy-MM-dd").format(GlobalModel.user!.create_time!)}"),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, color: Colors.transparent)
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.white,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserEditPassword(),
                        ));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [Text("修改密码"), Spacer(), Icon(Icons.arrow_forward_ios)],
                    ),
                  ),
                ),
                Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.white,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("提示"),
                              content: Text("是否退出?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text(
                                      "是",
                                      style: TextStyle(color: Colors.red),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      "否",
                                    ))
                              ],
                            )).then((value) {
                      if (value ?? false) {
                        SharedPreferenceUtil.remove(SharedPreferenceUtil.COOKIE);
                        GlobalModel.user = null;
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false);
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          "退出登录",
                          style: TextStyle(color: Colors.red),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class EditUserNameDialog extends StatefulWidget {
  const EditUserNameDialog({super.key});
  @override
  State<EditUserNameDialog> createState() => _EditUserNameDialogState();
}

class _EditUserNameDialogState extends State<EditUserNameDialog> {
  TextEditingController _nameController = TextEditingController();
  FocusNode _nameNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = GlobalModel.user?.username ?? "";
    Future.delayed(Duration.zero).then((_) {
      _nameNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("修改昵称"),
            TextField(
              textAlign: TextAlign.center,
              controller: _nameController,
              focusNode: _nameNode,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  // Toast.showToast("昵称不能为空");
                  return;
                }
                _nameNode.unfocus();
                Navigator.pop(context, value);
              },
            )
          ],
        ),
      ),
    );
  }
}
