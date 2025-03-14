class ConversationsTbl {
  final int id;
  final int conversationId;
  final int createdBy;
  final int receiverId;
  final int senderId;
  final int profileUserId;
  final String messageContent;
  final String fullName;
  final String profileImage;
  final int isDelete;
  final String updatedAt;
  final int newMessage;
  final int profileuserisDelete;
  

  const ConversationsTbl({
    required this.id,
    required this.conversationId,
    required this.createdBy,
    required this.receiverId,
    required this.senderId,
    required this.profileUserId,
    required this.profileImage,
    required this.fullName,
    required this.isDelete,
    required this.updatedAt,
    required this.messageContent,
    required this.newMessage,
    required this.profileuserisDelete
  });

  // Convert a ConversationsTbl into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'createdBy': createdBy,
      'receiverId': receiverId,
      'senderId': senderId,
      'profileUserId': profileUserId,
      'profileImage': profileImage,
      'fullName': fullName,
      'isDelete': isDelete,
      'updatedAt': updatedAt,
      'messageContent': messageContent,
      'newMessage': newMessage,
      'profileuserisDelete': profileuserisDelete
    };
  }

  // Implement toString to make it easier to see information about
  // each ConversationsTbl when using the print statement.
  // @override
  // String toString() {
  //   return 'ConversationsTbl{conversationId: $conversationId, conversationUniqueId: $conversationUniqueId, conversationUniqueId: $userId, firstName: $firstName, lastName: $lastName, userName: $userName, userProfile: $userProfile, lastMessageDate: $lastMessageDate, is_member_access: $isMemberAccess, createdDate: $createdDate, modifiedDate: $modifiedDate}';
  // }
}
