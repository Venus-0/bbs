import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bbs/model/global_model.dart';
import 'package:bbs/model/message_model.dart';
import 'package:bbs/model/socket_data_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:bbs/utils/event_bus.dart';

class SocketClient {
  static const String SOCKET_ADDR = "192.168.31.188";
  // static const String SOCKET_ADDR = "192.168.1.3";
  static const int SOCKET_PORT = 8082; //socket端口
  Socket? _socket;
  static const int MAX_HEART_TIME = 10; //最大心跳包等待时长
  static const int HEART_DURATION = 30; //心跳包间隔时长
  Timer? _heartTimer; //心跳定时器
  Timer? _heartWaitTimer; //心跳包等待延时

  static SocketClient? _instance;
  static SocketClient get instance {
    if (_instance == null) {
      _instance = SocketClient();
    }
    return _instance!;
  }

  Future<void> init() async {
    _socket = await Socket.connect(SOCKET_ADDR, SOCKET_PORT);
    var tmpData = "";
    _socket!.cast<List<int>>().transform(utf8.decoder).listen((event) {
      print(DateTime.now().toString() + " - socket - $event");
      tmpData = _parseSocketJson(tmpData, event);
    });
    send("connect", SocketCommand.connect);
  }

  void startTimer() {
    _heartTimer?.cancel();

    ///每30s发送一次心跳包
    _heartTimer = Timer.periodic(Duration(seconds: HEART_DURATION), (timer) {
      send("test", SocketCommand.heartBeat);
      _heartWaitTimer = Timer(Duration(seconds: MAX_HEART_TIME), () {
        ///超时
        close().then((_) {
          init();
        });
      });
    });
  }

  Future<void> send(String data, SocketCommand comm, {Map<String, dynamic> extra = const {}, bool retry = false}) async {
    ///处理消息
    SocketDataModel _body = SocketDataModel(
      user_id: GlobalModel.user?.user_id ?? 0,
      command: comm,
      message: data,
      extra: extra,
      snedTime: DateTime.now(),
    );
    try {
      _socket!.write(jsonEncode(_body.toJson()));
    } catch (e) {
      print(DateTime.now().toString() + "[socket] error $e");

      ///尝试close之后重新发一次
      await close();
      await Future.delayed(Duration(milliseconds: 500));
      await init();
      if (!retry) {
        await Future.delayed(Duration(milliseconds: 500));
        await send(data, comm, extra: extra, retry: true);
      }
    }
  }

  Future<void> close() async {
    print(DateTime.now().toString() + "socket 断开连接");
    await _socket?.flush();
    await _socket?.close();
    print(DateTime.now().toString() + "socket 已断开连接");
    _heartTimer?.cancel();
    _heartWaitTimer?.cancel();
    _heartTimer = null;
    _heartWaitTimer = null;
    _socket = null;
  }

  String _parseSocketJson(String sData, String s) {
    var tmpData = sData + s;

    print(s);
    print("-----------------------------------------");
    print(tmpData);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    // 找这个串里有没有相应的JSON符号
    // 没有的话，将数据返回等下一个包
    var bHasJSON = tmpData.contains("{") && tmpData.contains("}");
    if (!bHasJSON) {
      return tmpData;
    }

    //找有类似JSON串，看"{"是否在"}"的前面，
    //在前面，则解析，解析失败，则继续找下一个"}"
    //解析成功，则进行业务处理
    //处理完成，则对剩余部分递归解析，直到全部解析完成（此项一般用不到，仅适用于一次发两个以上的JSON串才需要，
    //每次只传一个JSON串的情况下，是不需要的）
    int idxStart = tmpData.indexOf("{");
    int idxEnd = 0;
    while (tmpData.contains("}", idxEnd)) {
      idxEnd = tmpData.indexOf("}", idxEnd) + 1;
      print('{}=>' + idxStart.toString() + "--" + idxEnd.toString());
      if (idxStart >= idxEnd) {
        continue; // 找下一个 "}"
      }

      var sJSON = tmpData.substring(idxStart, idxEnd);
      print("解析 JSON ...." + sJSON);
      try {
        var jsondata = jsonDecode(sJSON); //解析成功，则说明结束，否则抛出异常，继续接收
        print("解析 JSON OK :" + jsondata.toString());

        ///处理业务
        _handleSocketData(jsondata);

        tmpData = tmpData.substring(idxEnd); //剩余未解析部分
        idxEnd = 0; //复位

        if (tmpData.contains("{") && tmpData.contains("}")) {
          tmpData = _parseSocketJson(tmpData, "");
          break;
        }
      } catch (err) {
        print("解析 JSON 出错:" + err.toString() + ' waiting for next "}"....'); //抛出异常，继续接收，等下一个}
      }
    }
    return tmpData;
  }

  void _handleSocketData(Map<String, dynamic> jsonData) {
    //检查数据完整性
    if (!SocketDataModel.checkJson(jsonData)) {
      print("信息不完整");
    } else {
      ///处理数据
      SocketDataModel _data = SocketDataModel.fromJson(jsonData);
      switch (_data.command) {
        case SocketCommand.unknow:
          print("未知信息");
          break;
        case SocketCommand.heartBeat:
          print(DateTime.now().toString() + "接收到心跳包回复");

          ///收到心跳包之后重置计时器
          _heartWaitTimer?.cancel();
          break;
        case SocketCommand.message:
          Map<String, dynamic> _extra = _data.extra;
          if (_extra['sender'] != null && _extra['message'] != null) {
            try {
              UserModel _user = UserModel.fromJson(_extra['sender']);
              MessageModel _msg = MessageModel.fromJson(_extra['message']);
              eventBus.fire(Message(_msg, _user));
            } catch (e) {
              print(DateTime.now().toString() + "解析接收到的消息错误：$e");
            }
          }

          break;
        case SocketCommand.error:
          break;
        case SocketCommand.connect:

          ///收到连接的返回信息后开始发心跳包
          startTimer();
          break;
      }
    }
  }
}
