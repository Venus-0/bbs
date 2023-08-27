
///用户数据模型
class UserModel {
  int user_id; //用户id
  String password = ""; //用户密码（MD5）
  String email = ""; //用户邮箱
  String username = ""; //用户名
  String avatar = ""; //用户头像

  UserModel({
    this.user_id = 0,
    this.password = "",
    this.email = "",
    this.avatar = "",
    this.username = "",
  });

  factory UserModel.fromJson(Map<String, dynamic>? jsonRes) {
    if (jsonRes == null) {
      return UserModel();
    } else {
      return UserModel(
        user_id: jsonRes['user_id'],
        password: jsonRes['password'],
        email: jsonRes['email'],
        username: jsonRes['username'],
        avatar: jsonRes['avatar'],
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "password": password,
        "username": username,
        "email": email,
        "avatar": avatar,
      };
}
