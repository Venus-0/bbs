import 'package:bot_toast/bot_toast.dart';

class Toast {
  static showToast(String msg, {Duration duration = const Duration(milliseconds: 2000)}) {
    BotToast.showText(text: msg, duration: duration);
  }
}
