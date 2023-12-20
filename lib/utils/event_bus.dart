import 'package:bbs/model/message_model.dart';
import 'package:bbs/model/user_bean.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class BBSBus {}

class User {}

class Message {
  final MessageModel message;
  final UserModel user;
  const Message(this.message, this.user);
}

class SubscribeChange {}
