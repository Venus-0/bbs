import 'package:bbs/http/http.dart';
import 'package:bbs/model/bbs_model.dart';
import 'package:bbs/model/comment_model.dart';
import 'package:bbs/model/message_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/toast.dart';

///接口方法
class Api {
  static const HOST = "http://192.168.31.188:8080"; //主域名
  // static const HOST = "http://paediaaaa.cc"; //主域名

  static const CHECK_LOGIN = HOST + "/api/common/checkLogin"; //检查登录接口
  static const REGISTER = HOST + "/api/user/register"; //注册接口
  static const LOGIN = HOST + "/api/user/login"; //登录接口
  static const GET_BBS_LIST = HOST + "/api/bbs/getBBSList"; //获取帖子列表
  static const ADD_BBS = HOST + "/api/bbs/addBBS"; //添加帖子
  static const ADD_COMMENT = HOST + "/api/bbs/addComment"; //添加评论
  static const LIKE = HOST + "/api/common/like"; //点赞
  static const UNLIKE = HOST + "/api/common/unlike"; //取消点赞
  static const CHECK_LIKE = HOST + "/api/common/checkLike"; //检查是否点赞
  static const GET_POST_DETAIL = HOST + '/api/bbs/getBBSDetail'; //获取帖子详情
  static const GET_COMMENT_LIST = HOST + '/api/bbs/getBBSComment'; //获取帖子评论
  static const UPDATE_USER = HOST + "/api/user/updateUserInfo"; //更新用户
  static const EDIT_PASSWORD = HOST + "/api/user/editPassword"; //更新密码
  static const GET_MESSAGE_LIST = HOST + "/api/message/getMessageList"; //获取消息列表
  static const GET_UNREAD_MESSAGE = HOST + "/api/message/getUnReadMessage"; //获取未读的消息数量
  static const READ_MESSAGE = HOST + "/api/message/readMessage"; //已读消息
  static const SEND_MESSAGE = HOST + "/api/message/sendMessgae"; //发送消息
  static const GET_USER_DETAIL = HOST + "/api/user/getUserDetail"; //获取用户信息
  static const GET_USER_CHAT = HOST + "/api/message/getUserMessage"; //获取指定用户的聊天记录

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

  static Future<Map> addBBS(String title, String content, int type, String images) async {
    Map _res = await Http.request(ADD_BBS, HttpType.POST, {
      "title": title,
      "content": content,
      "type": type,
      "images": images,
    });
    return _res;
  }

  ///获取论坛列表 不传type默认全部类型
  static Future<Map> getBBSList(int startIndex, {int type = 0, int pageSize = 10}) async {
    Map _res = await Http.request(GET_BBS_LIST, HttpType.GET, {"type": type, "startIndex": startIndex, "pageSize": pageSize});
    return _res;
  }

  ///检查是否点赞
  static Future<bool> checkLike(int likeType, int likeId) async {
    Map _res = await Http.request(CHECK_LIKE, HttpType.GET, {"likeType": likeType, "likeId": likeId});
    if (_res['code'] == 200) {
      return _res['result']['delete_time'] == null;
    } else {
      return false;
    }
  }

  ///点赞
  static Future<bool> like(int likeType, int likeId) async {
    Map _res = await Http.request(LIKE, HttpType.POST, {"up_type": likeType, "up_id": likeId});
    if (_res['code'] == 200) {
      return true;
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
      return false;
    }
  }

  ///撤销点赞
  static Future<bool> unlike(int likeType, int likeId) async {
    Map _res = await Http.request(UNLIKE, HttpType.POST, {"up_type": likeType, "up_id": likeId});
    if (_res['code'] == 200) {
      return true;
    } else {
      Toast.showToast(_res['msg'] ?? "出错了");
      return false;
    }
  }

  ///获取帖子/文章/问答详情
  static Future<Map> getPostDetail(int id) async {
    Map _res = await Http.request(GET_POST_DETAIL, HttpType.GET, {"id": id});
    return _res;
  }

  ///获取评论列表
  static Future<Map> getCommentList(int startIndex, int id, {int pageSize = 10}) async {
    Map _res = await Http.request(GET_COMMENT_LIST, HttpType.POST, {"id": id, "startIndex": startIndex, "pageSize": pageSize});
    return _res;
  }

  ///添加评论
  static Future<Map> addComment(int commendId, int commentType, String comment, [int subCommentId = 0]) async {
    Map<String, dynamic> _postData = {
      "comment": comment,
      "comment_id": commendId,
      "type": commentType,
    };
    if (commentType == CommentModel.TYPE_COMMENT) {
      if (subCommentId == 0) {
        subCommentId = commendId;
      }
      _postData['sub_comment_id'] = subCommentId;
    }
    Map _res = await Http.request(ADD_COMMENT, HttpType.POST, _postData);
    return _res;
  }

  ///更新有用户信息
  static Future<bool> updateUser({String? userName, String? avatar}) async {
    if (userName == null && avatar == null) return false;
    Map<String, dynamic> _postData = {
      "username": userName,
      "avatar": avatar,
    };

    Map _res = await Http.request(UPDATE_USER, HttpType.POST, _postData);
    return _res['code'] == 200;
  }

  static Future<bool> editPassword(String old, String newP, String newA) async {
    Map _res = await Http.request(EDIT_PASSWORD, HttpType.POST, {
      "oldPwd": old,
      "newPwd": newP,
      "twoPwd": newA,
    });

    return _res['code'] == 200;
  }

  ///获取消息列表
  static Future<Map> getMessageList() async {
    return await Http.request(GET_MESSAGE_LIST, HttpType.GET, null);
  }

  ///获取未读消息数量
  static Future<int> getUnReadMessage() async {
    Map _res = await Http.request(GET_UNREAD_MESSAGE, HttpType.GET, null);
    return _res['COUNT(*)'] ?? 0;
  }

  ///已读消息
  static Future<bool> readMessage(int senderId) async {
    Map _res = await Http.request(READ_MESSAGE, HttpType.POST, {"sender_id": senderId});
    return _res['code'] == 200;
  }

  ///发送消息
  static Future<bool> sendMesaage(int receiverId, String message) async {
    Map _res = await Http.request(SEND_MESSAGE, HttpType.POST, {"message": message, "receiver_id": receiverId});
    return _res['code'] == 200;
  }

  ///用户详情
  static Future<(UserModel? user, int? subscribe, int? fans, bool? isSubscribe, List<BBSModel>? posts)> getUserDetail(int userId) async {
    Map _res = await Http.request(GET_USER_DETAIL, HttpType.POST, {"user_id": userId});
    if (_res['code'] == 200) {
      Map _result = _res['result'];
      UserModel _user = UserModel.fromJson(_result['user']);
      int _subscribe = _result['subPostCount'];
      int _fans = _result['subUserCount'];
      bool _isSubscribe = _result['isSubscribe'];
      List<BBSModel> _list = [];
      for (final _json in _result['posts']) {
        _list.add(BBSModel.fromJson(_json));
      }
      return (_user, _subscribe, _fans, _isSubscribe, _list);
    } else {
      return (null, null, null, null, null);
    }
  }

  static Future<List<MessageModel>> getUserChat(int userId) async {
    Map _res = await Http.request(GET_USER_CHAT, HttpType.POST, {"user_id": userId});
    if (_res['code'] == 200) {
      List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res['result']['list']);
      List<MessageModel> _messages = [];
      for (final _json in _list) {
        _messages.add(MessageModel.fromJson(_json));
      }
      return _messages;
    } else {
      return [];
    }
  }
}
