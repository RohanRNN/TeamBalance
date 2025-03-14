class MessagesTbl {
  final int id;
  final int messageId;
  final int conversationId;
  final int senderId;
  final String content;
  final int isTestdata;
  final int isDelete;
  final String createdAt;
  final int currentStatus;
  final String? updatedAt;

  MessagesTbl({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.currentStatus,
    required this.isTestdata,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a MessagesTbl into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'isTestData': isTestdata,
      'currentstatus': currentStatus,
      'isDelete': isDelete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
