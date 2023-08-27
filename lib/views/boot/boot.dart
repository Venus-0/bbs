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
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
