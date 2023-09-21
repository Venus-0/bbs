import 'package:intl/intl.dart';

///文章 帖子 问题数据模型
class BBSModel {
  static const int TYPE_QUESTION = 1; //问题
  static const int TYPE_WIKI = 2; //文章
  static const int TYPE_POST = 3; //文章

  int id; //帖子id
  int user_id; //发帖人id
  String title; //标题
  String content; //正文
  int question_type; //类型 1问题 2文章帖子
  int reply_count; //回复数量
  int up_count; //点赞数量
  DateTime? last_reply_time; //最后回复时间
  DateTime? create_time; //创建时间
  DateTime? delete_time; //删除时间
  DateTime? update_time; //更新时间

  BBSModel({
    this.id = 0,
    this.user_id = 0,
    this.title = '',
    this.content = '',
    this.question_type = 0,
    this.reply_count = 0,
    this.up_count = 0,
    this.last_reply_time,
    this.create_time,
    this.delete_time,
    this.update_time,
  });

  factory BBSModel.fromJson(Map<String, dynamic> json) {
    return BBSModel(
      id: json['id'],
      user_id: json['user_id'],
      title: json['title'],
      content: json['content'],
      question_type: json['question_type'],
      reply_count: json['reply_count'],
      up_count: json['up_count'],
      last_reply_time: DateTime.tryParse(json['last_reply_time'] ?? ""),
      create_time: DateTime.tryParse(json['create_time'] ?? ""),
      delete_time: DateTime.tryParse(json['delete_time'] ?? ""),
      update_time: DateTime.tryParse(json['update_time'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': user_id,
        'title': title,
        'content': content,
        'question_type': question_type,
        'reply_count': reply_count,
        'up_count': up_count,
        'last_reply_time': last_reply_time == null ? null : DateFormat("yyyy-MM-dd").format(last_reply_time!),
        'create_time': create_time == null ? null : DateFormat("yyyy-MM-dd").format(create_time!),
        'delete_time': delete_time == null ? null : DateFormat("yyyy-MM-dd").format(delete_time!),
        'update_time': update_time == null ? null : DateFormat("yyyy-MM-dd").format(update_time!),
      };
}
