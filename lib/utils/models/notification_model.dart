/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class NotificationModel {
  int? id;
  int? userid;
  String? notification;
  String? notificationtype;
  String? createdat;
  String? updatedat;
  bool? isread;
  int? postId;
  int? commentId;
  int? messageId;
  int? conversationId;

  NotificationModel({
    this.id,
    this.userid,
    this.notification,
    this.notificationtype,
    this.createdat,
    this.updatedat,
    this.isread,
    this.postId,
    this.commentId,
    this.messageId,
    this.conversationId,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['user_id'];
    notification = json['notification'];
    notificationtype = json['notification_type'];
    createdat = json['created_at'];
    updatedat = json['updated_at'];
    isread = json['is_read'];
    postId = json['post_id'];
    commentId = json['comment_id'];
    messageId = json['message_id'];
    conversationId = json['conversation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['user_id'] = userid;
    data['notification'] = notification;
    data['notification_type'] = notificationtype;
    data['created_at'] = createdat;
    data['updated_at'] = updatedat;
    data['is_read'] = isread;
    data['post_id'] = postId;
    data['comment_id'] = commentId;
    data['message_id'] = messageId;
    data['conversation_id'] = conversationId;
    return data;
  }
}


