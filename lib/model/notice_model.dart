import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class NoticeModel {
  int id;
  int admin_id;
  String title;
  String content;
  String? image;
  DateTime? create_time;
  DateTime? delete_time;
  NoticeModel({
    this.id = 0,
    this.admin_id = 0,
    this.title = "",
    this.content = "",
    this.create_time,
    this.delete_time,
    this.image,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'],
      admin_id: json['admin_id'],
      title: json['title'],
      content: json['content'],
      image: json['image'] ?? "",
      create_time: DateTime.tryParse(json['create_time'] ?? ''),
      delete_time: DateTime.tryParse(json['create_time'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'admin_id': admin_id,
        'title': title,
        'content': content,
        'image': image,
        'create_time': create_time == null ? null : DateFormat("yyyy-MM-dd HH:mm:ss").format(create_time!),
        'delete_time': delete_time == null ? null : DateFormat("yyyy-MM-dd HH:mm:ss").format(delete_time!),
      };

  Image? getImage({BoxFit? fit}) {
    if (image?.isEmpty ?? true) {
      return null;
    } else {
      return Image.memory(base64Decode(image!.split(",").last), fit: fit);
    }
  }
}
