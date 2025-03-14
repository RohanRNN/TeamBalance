class BlockedUserTbl {
  final int id;
  final int userId;
  final int blockedBy;
  final int isTestData;
  final int isDelete;
  final String createdAt;

  const BlockedUserTbl({
    required this.id,
    required this.userId,
    required this.blockedBy,
    required this.isTestData,
    required this.isDelete,
    required this.createdAt,
  });

  // Convert a ConversationsTbl into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'blockedBy': blockedBy,
      'isTestData': isTestData,
      'isDelete': isDelete,
      'createdAt': createdAt,
    };
  }

  // Implement toString to make it easier to see information about
  // each ConversationsTbl when using the print statement.
  // @override
  // String toString() {
  //   return 'ConversationsTbl{conversationId: $conversationId, conversationUniqueId: $conversationUniqueId, conversationUniqueId: $userId, firstName: $firstName, lastName: $lastName, userName: $userName, userProfile: $userProfile, lastMessageDate: $lastMessageDate, is_member_access: $isMemberAccess, createdDate: $createdDate, modifiedDate: $modifiedDate}';
  // }
}
