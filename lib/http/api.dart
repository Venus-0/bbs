import 'package:bbs/http/http.dart';

///接口方法
class Api {
  static const HOST = "http://192.168.31.188:8080"; //主域名

  static const REGISTER = HOST + "/api/user/register"; //注册接口
  static const LOGIN = HOST + "/api/user/login"; //登录接口
  static const GET_BBS_LIST = HOST + "/api/bbs/getBBSList"; //获取帖子列表
  static const ADD_BBS = HOST + "/api/bbs/addBBS"; //添加帖子
  static const ADD_COMMENT = "/api/user/addComment"; //添加评论

  ///注册
  static Future<Map> register(String name, String email, String pwd) async {
    Map _res = await Http.request(REGISTER, HttpType.POST, {
      "username": name,
      "email": email,
      "password": pwd,
    });
    return _res;
  }

  static Future<Map> login(String email, String pwd) async {
    Map _res = await Http.request(REGISTER, HttpType.POST, {
      "email": email,
      "pwd": pwd,
      "device": "testDevice",
    });
    return _res;
  }
}
