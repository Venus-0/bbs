# bbs

论坛、问答、即时通信

## 编译环境

> Flutter 3.10.6 channel stable
> Dart 3.0.6
---

### 项目结构

#### [main.dart](./lib/main.dart) - 程序入口

#### http目录 - 网络请求及接口

##### [api.dart](./lib/http/api.dart) - 接口

##### [http.dart](./lib/http/http.dart) - 请求方法

##### [socket.dart](./lib/http/socket.dart) - socket方法

#### model目录 - 数据模型相关

##### [bbs_model.dart](./lib/model/bbs_model.dart) - 论坛数据类

##### [comment_model.dart](./lib/model/comment_model.dart) - 评论数据类

##### [global_model.dart](./lib/model/global_model.dart) - 全局数据类

##### [message_model.dart](./lib/model/message_model.dart) - 私信数据类

##### [socket_model.dart](./lib/model/socket_data_model.dart) - socket数据类

##### [user_bean.dart](./lib/model/user_bean.dart) - 用户数据类

#### utils目录 - 基础方法

##### [event_bus.dart](./lib/utils/event_bus.dart) - eventBus方法

##### [sharedPreferenceUtil.dart](./lib/utils/sharedPreferenceUtil.dart) - 本地缓存方法

##### [toast.dart](./lib/utils/toast.dart) toast方法

#### views目录 - 页面

##### bbs目录 - 论坛相关页面

###### [add_bbs.dart](./lib/views/bbs/add_bbs.dart) - 添加帖子

###### [bbs_detail.dart](./lib/views/bbs/bbs_detail.dart) - 帖子详情

###### [bbs_item.dart](./lib/views/bbs/bbs_item.dart) - 帖子item

###### [bbs_page.dart](./lib/views/bbs/bbs_page.dart) - 论坛页入口

###### [bbs.dart](./lib/views/bbs/bbs.dart) - 论坛、WIKI、问答区板块

###### [comment_item.dart](./lib/views/bbs/comment_item.dart) - 评论item

###### [digest.dart](./lib/views/bbs/digest.dart) - 精华区板块

##### boot目录 - 启动页面

###### [boot.dart](./lib/views/boot/boot.dart) - 启动页

##### first目录 - 首页

###### [first_page.dart](./lib/views/first/first_page.dart) - 首屏页

###### [popular.dart](./lib/views/first/popular.dart) - 热门板块

###### [recent.dart](./lib/views/first/recent.dart) - 最近板块

###### [recommand.dart](./lib/views/first/recommand.dart) - 推荐板块

###### [subscribe.dart](./lib/views/first/subscribe.dart) - 关注板块

##### home目录 - 底层页

###### [home_page.dart](./lib/views/home/home_page.dart) - 首页入口

##### login目录 - 登录页

###### [login.dart](./lib/views/login/login.dart) - 登录页

###### [register.dart](./lib/views/login/register.dart) - 注册页

##### message目录 - 消息页

###### [caht.dart](./lib/views/message/chat.dart) - 即时通讯页

###### [message_page.dart](./lib/views/message/message_page.dart) - 消息页

##### user目录 - 用户页

###### [my_post.dart](./lib/views/user/my_post.dart) - 我的帖子页

###### [user_detail.dart](./lib/views/user/user_detail.dart) - 个人信息

###### [user_edit_password.dart](./lib/views/user/user_edit_pawssword.dart) - 编辑密码

###### [user_info.dart](./lib/views/user/user_info.dart) 用户信息页

###### [user_page.dart](./lib/views/user/user_page.dart) - 个人信息入口

##### widget目录 - 通用组件

###### [image_preview.dart](./lib/views/widgets/image_preview.dart) - 图片预览
