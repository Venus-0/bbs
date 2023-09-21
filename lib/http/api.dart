import 'package:bbs/http/http.dart';

///接口方法
class Api {
  static const HOST = "http://paediaaaa.cc"; //主域名

  static const CHECK_LOGIN = HOST + "/api/common/checkLogin"; //检查登录接口
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

  ///登录
  static Future<Map> login(String email, String pwd) async {
    Map _res = await Http.request(LOGIN, HttpType.POST, {
      "email": email,
      "pwd": pwd,
      "device": "testDevice",
    });
    return _res;
  }

  ///检查登录
  static Future<Map> checkLogin() async {
    Map _res = await Http.request(CHECK_LOGIN, HttpType.GET, null);
    return _res;
  }

  static Future<Map> addBBS(String title, String content, int type) async {
    Map _res = await Http.request(ADD_BBS, HttpType.POST, {
      "title": title,
      "content": content,
      "type": type,
    });
    return _res;
  }

  static Future<Map> getBBSList() async {
    Map _res = await Http.request(GET_BBS_LIST, HttpType.GET, null);
    return _res;
  }
}
