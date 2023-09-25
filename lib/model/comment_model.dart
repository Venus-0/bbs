import 'package:bbs/model/user_bean.dart';
import 'package:intl/intl.dart';

class CommentModel {
  static const int TYPE_QUESTION = 1;
  static const int TYPE_WIKI = 2;
  static const int TYPE_POST = 3;
  static const int TYPE_COMMENT = 4;

  UserModel? user;
  int id;
  int comment_type;
  int comment_id;
  int? sub_comment_id;
  int user_id;
  String comment;
  int up_count;
  DateTime? delete_time;

  CommentModel({
    this.user,
    this.id = 0,
    this.comment_type = 0,
    this.comment_id = 0,
    this.sub_comment_id,
    this.user_id = 0,
    this.comment = "",
    this.up_count = 0,
    this.delete_time,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    UserModel _user = UserModel.fromJson(json['user']);

    return CommentModel(
      user: _user,
      id: json['comment']['id'],
      comment_type: json['comment']['comment_type'],
      comment_id: json['comment']['comment_id'],
      sub_comment_id: json['comment']['sub_comment_id'],
      user_id: json['comment']['user_id'],
      comment: json['comment']['comment'],
      up_count: json['comment']['up_count'],
      delete_time: DateTime.tryParse(json['comment']['delete_time'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson() ?? {},
        'id': id,
        'comment_type': comment_type,
        'comment_id': comment_id,
        'sub_comment_id': sub_comment_id,
        'user_id': user_id,
        'comment': comment,
        'up_count': up_count,
        'delete_time': delete_time == null ? null : DateFormat("yyyy-MM-dd HH:mm:ss").format(delete_time!),
      };
}
