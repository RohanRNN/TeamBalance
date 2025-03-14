import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/config/api/sqflite_database/sqflite_table_name.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/chat_tables/blocked_user_tbl.dart';
import 'package:team_balance/utils/chat_tables/conversations_tbl.dart';
import 'package:team_balance/utils/chat_tables/message_tbl.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/message_model.dart';

class DatabaseHelper {
  static const _databaseName = "TeamBalance.db";
  static const _databaseVersion = 1;

  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    Log.info('============== DATABASE _onCreate ==============');

    await db.execute('''
          CREATE TABLE ${SqfliteTableName.tableConversation} (
            id INTEGER PRIMARY KEY, 
            conversationId INTEGER, 
            createdBy INTEGER, 
            receiverId INTEGER, 
            senderId INTEGER, 
            profileUserId INTEGER, 
            messageContent TEXT, 
            fullName TEXT, 
            profileImage TEXT,
            isDelete INTEGER,
            updatedAt TEXT,
            newMessage INTEGER,
            profileuserisDelete INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE ${SqfliteTableName.tableMessage} (
            id INTEGER PRIMARY KEY, 
            messageId INTEGER, 
            conversationId INTEGER, 
            senderId INTEGER, 
            content TEXT,
            isTestdata INTEGER,
            isDelete INTEGER,
            createdAt TEXT,
            currentstatus INTEGER,
            updatedAt TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE ${SqfliteTableName.tableBlockedUserMessage} (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            userId INTEGER, 
            blockedBy INTEGER, 
            isTestData INTEGER, 
            isDelete INTEGER, 
            createdAt TEXT
          )
          ''');
  }

  // Helper methods

  // =============== INSERT METHODS =============== //

  // =============== INSERT CONVERSATION =============== //
  Future<int> insertConversation(ConversationsTbl conversations) async {
  Log.info('============== In insertConversation ==============');
  
  // Check if a conversation with the same conversationId already exists
  final existingConversations = await _db.query(
    SqfliteTableName.tableConversation,
    where: 'conversationId = ?',
    whereArgs: [conversations.conversationId],
  );
  
  if (existingConversations.isNotEmpty) {
    Log.info('Conversation with conversationId ${conversations.conversationId} already exists. Skipping insertion.');
    return -1; // Return -1 or a custom value to indicate that the insert was skipped
  }
print('Conversation with conversationId ===111   ');
  // Insert the new conversation
  return await _db.insert(
    SqfliteTableName.tableConversation,
    conversations.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  // Future<int> insertConversation(ConversationsTbl conversations) async {
  //   Log.info('============== In insertConversation ==============');
  //   return await _db.insert(
  //     SqfliteTableName.tableConversation,
  //     conversations.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // =============== INSERT BLOCKED USER =============== //
  Future<int> insertBlockedUser(BlockedUserTbl blockedUser) async {
    Log.info('============== In insertBlockedUser ==============');
    Map<String, dynamic> blockedUserMap = blockedUser.toMap();
    blockedUserMap.remove('id');
    return await _db.insert(
      SqfliteTableName.tableBlockedUserMessage,
      blockedUserMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =============== INSERT BLOCKED USER =============== //
  Future<int> deleteBlockedUser(int loginUserId, int userId) async {
    Log.info('============== In deleteBlockedUser ==============');
    print('loginid${loginUserId}  and  userid${userId}');
    return await _db.delete(
      SqfliteTableName.tableBlockedUserMessage,
      where: 'userId = ? AND blockedBy = ?',
      whereArgs: [userId, loginUserId],
    );
  }

// =============== UPDATE CONVERSATION =============== //
Future<void> updateConversationIsDelete(
    {required String conversationId, required int isDelete}) async {  
  await _db.update(
    SqfliteTableName.tableConversation,
    {'profileuserisDelete': isDelete},
    where: 'conversationId = ?',
    whereArgs: [conversationId],
  );
}

  // =============== UPDATE CONVERSATION =============== //
  Future<int> updateConversation({
    required ConversationsTbl conversations,
    required int uniqueId,
  }) async {
    try {
      Map<String, dynamic> conversationMap = conversations.toMap();
      if (GS.userData.value!.id.toString() ==
          conversationMap['senderId'].toString()) {
        conversationMap.remove('fullName');
        conversationMap.remove('profileImage');
      }
      // Remove the id key from the Map
      conversationMap.remove('id');
      conversationMap.remove('conversationId');
      // conversationMap.remove('fullName');
      // conversationMap.remove('profileImage');
      conversationMap.remove('profileUserId');
      conversationMap.remove('createdby');
      conversationMap.remove('receiverid');
      conversationMap.remove('senderId');
      Log.info('============== In updateConversation123 ==============');
      Log.info('============== ${conversationMap} ==============');

      return await _db.update(
          SqfliteTableName.tableConversation, conversationMap,
          where: "conversationId = ?", whereArgs: [uniqueId]);
    } catch (error) {
      Log.info('============== Error occured ==============');
      Log.info(error);
      return 0;
    }
  }

  // =============== UPDATE CONVERSATION =============== //
  Future<int> updateConversationReadStatus({
    required int conversationStatus,
    required int uniqueId,
  }) async {
    try {
      return await _db.update(SqfliteTableName.tableConversation,
          {"newMessage": conversationStatus},
          where: "conversationId = ?", whereArgs: [uniqueId]);
    } catch (error) {
      Log.info('============== Error occured ==============');
      Log.info(error);
      return 0;
    }
  }

  // =============== INSERT MESSAGE =============== //
  Future<int> insertMessage(MessagesTbl message) async {
    Log.info('============== In insertMessage ==============');
    return await _db.insert(
      SqfliteTableName.tableMessage,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =============== UPDATE MESSAGE =============== //
  Future<int> updateMessage({
    required int conversationId,
    required int messageId,
    required int currentStatus,
  }) async {
    Log.info('============== In updateMessage ==============');
    final List<Map<String, dynamic>> previousMessage = await _db.query(
      SqfliteTableName.tableMessage,
      columns: ['currentstatus'],
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
    if (previousMessage.isNotEmpty) {
      int currentStatusForMessage = previousMessage.first['currentstatus'];
      if (currentStatus > currentStatusForMessage) {
        return await _db.update(
          SqfliteTableName.tableMessage,
          {'currentstatus': currentStatus},
          where: 'messageId = ? OR conversationId = ?',
          whereArgs: [messageId, conversationId],
        );
      }
    }
    return 0;

    // Map<String, dynamic> updatedFields = {
    //   'currentstatus': currentStatus,
    // };

    // return await _db.update(
    //   SqfliteTableName.tableMessage,
    //   updatedFields,
    //   where:  'messageId = ? OR conversationId = ?',
    //   whereArgs: [messageId, conversationId],
    // );
  }

  // =============== DELETE MESSAGE =============== //
  Future<int> deleteMessages({
    required int conversationId,
  }) async {
    Log.info('============== In deleteMessage ==============');
    return await _db.delete(
      SqfliteTableName.tableMessage,
      where: 'conversationId = ?',
      whereArgs: [conversationId],
    );
  }

  // =============== Custom Query Function =============== //

  // Get latest modification date of conversation
  Future<String> getLatestModifiedDateOfConversation() async {
    String modifiedDate = '';
    var result = await _db.rawQuery(
        'SELECT MAX(updatedAt) as modified_date FROM ${SqfliteTableName.tableConversation}');

    Log.info('RESULT : $result');
    for (var element in result) {
      var updatedAt = element['modified_date'].toString();
      if (updatedAt == 'null') {
        modifiedDate = '1900-01-01 00:00:00';
      } else {
        modifiedDate = updatedAt;
      }
    }
    return modifiedDate;
  }

// Get latest modification date of participant
  Future<int> getLastMessageId() async {
    int id = 0;
    var result = await _db.rawQuery(
        'SELECT MAX(id) as messageId FROM ${SqfliteTableName.tableMessage}');
    for (var element in result) {
      var lastmessageId = int.parse(element['messageId'].toString());
      if (lastmessageId == 'null') {
        id = 0;
      } else {
        id = lastmessageId;
      }
    }
    return id;
  }

  // Get latest modification date of conversation
  Future<int> getConversationId({required int userID}) async {
    Log.info('============== In get single conversation id ==============');
    int conversationId = 0;
    var result = await _db.rawQuery(
        'SELECT id FROM ${SqfliteTableName.tableConversation} WHERE (senderId = $userID OR receiverId = $userID) AND isDelete = 0 LIMIT 1');

    if (result.isNotEmpty) {
      conversationId = int.parse(result[0]['id'].toString());
    }
    return conversationId;
  }

  // Get latest modification date of conversation
  Future<int> getConversationBySenderOrReciver(
      {required int loginUserId,
      required int oppositUserId,
      required int conversationIdRes}) async {
    Log.info('============== getConversationBySenderOrReciver ==============');
    int conversationId = 0;
    if (conversationIdRes != 0) {
      conversationId = conversationIdRes;
    }
    var result = await _db.rawQuery(
        // 'SELECT * FROM ${SqfliteTableName.tableConversation} WHERE 1 ');
        // 'SELECT conversationId FROM ${SqfliteTableName.tableConversation} WHERE ((senderId = $loginUserId AND receiverId = $oppositUserId) OR (senderId = $oppositUserId AND receiverId = $loginUserId))  AND isDelete = 0 ');
        'SELECT conversationId FROM ${SqfliteTableName.tableConversation} WHERE ((createdBy = $loginUserId AND receiverId = $oppositUserId) OR (createdBy = $oppositUserId AND receiverId = $loginUserId))  AND isDelete = 0 ');

    if (result.isNotEmpty) {
      conversationId = int.parse(result[0]['conversationId'].toString() ?? '');
    }
    Log.info(
        '============== conversationId......... ===  ${result} ====   sendeer: ${loginUserId}======   recier: ${oppositUserId}====');
    return conversationId;
  }

  // Get record if the user is blocked
  Future<bool> getBlockedUser(
      {required int loginUserId,
      required int oppositUserId,
      required int isTestdata}) async {
    Log.info('============== getBlockedUser ==============');
    bool isBlocked = false;
    var result = await _db.rawQuery(
        'SELECT * FROM ${SqfliteTableName.tableBlockedUserMessage} WHERE userId = ${oppositUserId} AND blockedBy = ${loginUserId} AND isTestData = ${isTestdata} AND isDelete = 0 LIMIT 1');
    if (result.isNotEmpty) {
      isBlocked = true;
    }
    return isBlocked;
  }

  Future<ConversationModel?> getSingleConversationByConversationId(
      {required int conversationId}) async {
    Log.info(
        '============== In singleConversationByConversationId ==============');
    ConversationModel? conversationObject;
    try {
      List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
        'SELECT c.*, m.readat, m.createdAt FROM ${SqfliteTableName.tableConversation} c LEFT JOIN ${SqfliteTableName.tableMessage} m ON m.conversationId = c.conversationId WHERE c.conversationId = $conversationId',
      );

      Log.info('GET SINGLE CONVERSATION ${conversationMaps.length}');
      if (conversationMaps.isNotEmpty) {
        for (final data in conversationMaps) {
          final ConversationModel messageItem = ConversationModel(
            id: data['id'],
            createdby: data['createdBy'],
            receiverid: data['receiverId'],
            conversationid: data['conversationId'],
            senderid: data['senderId'],
            messagecontent: data['messageContent'],
            readat: data['readat'],
            profileuserid: data['profileUserId'],
            fullname: data['fullName'],
            profileimage: data['profileImage'] ?? '',
            createdAt: data['createdAt'] ?? '',
            isDelete: data['isDelete'] == 1 ? true : false,
          );
          conversationObject = messageItem;
        }
        Log.info('GET SINGLE CONVERSATION ID ${conversationObject!.id ?? 0}');
        return conversationObject;
      } else {
        return null;
      }
    } catch (error) {
      Log.error(error.toString());
    }
    return null;
  }

  // A method that retrieves all the message by conversations
  Future<List<MessageModel>> getAllMessagesByConversationId({
    required int conversationId,
  }) async {
    Log.info(
        '============== In getAllMessagesByConversationId ==============  wheer conversationId :${conversationId}');
    try {
      //  List<Map<String, dynamic>>? messageMaps = await _db.rawQuery(
      //     'SELECT * FROM ${SqfliteTableName.tableMessage}');
      List<Map<String, dynamic>>? messageMaps = await _db.rawQuery(
          'SELECT * FROM ${SqfliteTableName.tableMessage}  WHERE conversationId = ${conversationId} ORDER BY createdAt DESC');

      Log.info('GET CONVERSATION MESSAGE LENGTH: ${messageMaps.length}');
      var arrayOfMessage = <MessageModel>[];
      Log.success("Log path===> ${_db.path}");
      for (final data in messageMaps) {
        Log.info('GET CONVERSATION READ AT: ${data}');
        final MessageModel messageItem = MessageModel(
            conversationid: data['conversationId'],
            createdat: data['createdAt'],
            id: data['messageId'],
            isdelete: data['isDelete'] == 1 ? "1" : "0",
            istestdata: data['isTestdata'] == 1 ? "1" : "0",
            messagecontent: data['content'],
            currentstatus: data['currentstatus'],
            senderid: data['senderId'],
            updatedat: data['updatedAt']);
        arrayOfMessage.add(messageItem);
      }
      return arrayOfMessage;
    } catch (error) {
      Log.error(error.toString());
    }
    return [];
  }

  // Get all the conversations.
  Future<List<ConversationModel>> getAllConversationData() async {
    Log.info('============== In getAllConversationData ==============');
    try {
      // List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
      //   // 'WITH UniqueConversations AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY conversationId ORDER BY updateAt DESC) AS rn FROM ${SqfliteTableName.tableConversation} WHERE isDelete = 0)SELECT * FROM UniqueConversations WHERE rn = 1 ORDER BY conversationId DESC;'
      //   // 'SELECT * FROM ${SqfliteTableName.tableConversation} AS t WHERE isDelete = 0 AND conversationId IN ( SELECT MAX(conversationId)  FROM ${SqfliteTableName.tableConversation}  WHERE isDelete = 0  GROUP BY conversationId ) AND profileUserId NOT IN (SELECT userId FROM ${SqfliteTableName.tableBlockedUserMessage} WHERE blockedBy = ${GS.userData.value!.id} AND isDelete = 0) GROUP BY conversationId ORDER BY updatedAt DESC;'
      //   // 'SELECT * FROM ${SqfliteTableName.tableConversation} AS t WHERE isDelete = 0 AND profileUserId NOT IN (SELECT userId FROM ${SqfliteTableName.tableBlockedUserMessage} WHERE blockedBy = ${GS.userData.value!.id} AND isDelete = 0) ORDER BY updatedAt DESC;'

      //   // '  SELECT t.* FROM ${SqfliteTableName.tableConversation} AS t WHERE t.isDelete = 0 AND t.profileUserId NOT IN (SELECT userId FROM ${SqfliteTableName.tableBlockedUserMessage} WHERE blockedBy = ${GS.userData.value!.id} AND isDelete = 0)AND t.updatedAt = (SELECT MAX(updatedAt) FROM ${SqfliteTableName.tableConversation} WHERE conversationId = t.conversationId) ORDER BY t.updatedAt DESC;'
      //    'SELECT * FROM ${SqfliteTableName.tableConversation}  WHERE isDelete = 0 ',
      // );

      List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery('''
  SELECT t.*
  FROM ${SqfliteTableName.tableConversation} AS t
  WHERE t.isDelete = 0 
    AND t.profileUserId NOT IN (
      SELECT userId 
      FROM ${SqfliteTableName.tableBlockedUserMessage} 
      WHERE blockedBy = ${GS.userData.value!.id} 
        AND isDelete = 0
    )
    AND t.updatedAt = (
      SELECT MAX(updatedAt)
      FROM ${SqfliteTableName.tableConversation}
      WHERE conversationId = t.conversationId
    )
  GROUP BY t.conversationId
  ORDER BY t.updatedAt DESC;
  ''');

      Log.info('GET ALL CONVERSATION ${conversationMaps}');
      var arrayOfConversation = <ConversationModel>[];
      for (final data in conversationMaps) {
        Log.info('data ${data}');
        final ConversationModel conversationItem = ConversationModel(
          id: data['id'],
          conversationid: data['conversationId'],
          createdby: data['createdBy'],
          isDelete: data['isDelete'] == 1 ? true : false,
          senderid: data['senderId'],
          receiverid: data['receiverId'],
          updatedAt: data['updatedAt'],
          messagecontent: data['messageContent'] != null
              ? data['messageContent'] ?? ''
              : '',
          profileuserid: data['profileUserId'],
          fullname: data['fullName'],
          profileimage: data['profileImage'],
          newMessage: data['newMessage'],
          // profileuserisDelete :0
          profileuserisDelete: data['profileuserisDelete'],
        );
        if (data['messageContent'] != null) {
          arrayOfConversation.add(conversationItem);
        }
      }
      return arrayOfConversation;
    } catch (error) {
      Log.error(error.toString());
    }
    return [];
  }

  // Get all the conversations.
  // Future<List<ConversationModel>> getAllConversationData() async {
  //   Log.info('============== In getAllConversationData ==============');
  //   try {
  //     List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
  //       'SELECT c.*, m.id as messageId, m.content, m.type as messageType, m.updatedAt as lastMessgeTime, gp.isBlocked, u.memberId as userId, u.username, u.profile FROM ${SqfliteTableName.tableConversation} c LEFT JOIN ${SqfliteTableName.tableMessage} m ON m.conversationId = c.id AND m.id = (SELECT MAX(id) FROM ${SqfliteTableName.tableMessage} WHERE conversationId = c.id AND isDelete = 0) LEFT JOIN ${SqfliteTableName.tableParticipant} gp ON gp.conversationId = c.id AND gp.memberId != ${GS.userData.value?.id} LEFT JOIN ${SqfliteTableName.tableUser} u ON u.memberId = gp.memberId WHERE c.isDelete = 0 GROUP BY c.id ORDER BY m.updatedAt DESC',
  //     );
  //     Log.info('GET ALL CONVERSATION ${conversationMaps.length}');
  //     var arrayOfConversation = <ConversationModel>[];
  //     for (final data in conversationMaps) {
  //       final ConversationModel conversationItem = ConversationModel(
  //         id: data['id'],
  //         conversationUniqueId: data['conversationUniqueId'],
  //         addedBy: data['addedBy'],
  //         createdBy: data['createdBy'],
  //         description: data['description'],
  //         isGroup: data['isGroup'],
  //         isMemberAccess: data['isMemberAccess'],
  //         maxMember: data['maxNumber'],
  //         name: data['name'],
  //         photo: data['photo'],
  //         receiverId: data['receiverId'],
  //         updatedBy: data['updatedBy'],
  //         isDelete: data['isDelete'] == 1 ? true : false,
  //         senderId: data['senderId'],
  //         updatedAt: data['updatedAt'],
  //         messageId: data['messageId'] != null ? data['messageId'] ?? 0 : 0,
  //         messageType:
  //             data['messageType'] != null ? data['messageType'] ?? '' : '',
  //         content: data['content'] != null ? data['content'] ?? '' : '',
  //         userId: data['userId'],
  //         username: data['username'],
  //         profile: data['profile'],
  //         isBlocked: data['isBlocked'],
  //         lastMessgeTime: data['lastMessgeTime'] != null
  //             ? data['lastMessgeTime'] ?? ''
  //             : '',
  //       );
  //       if (data['content'] != null) {
  //         arrayOfConversation.add(conversationItem);
  //       }
  //     }
  //     return arrayOfConversation;
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return [];
  // }

  // Future<ConversationModel?> getSingleConversationByReceiverId(
  //     {required int userId}) async {
  //   Log.info('============== In singleConversationByReceiverId ==============');
  //   ConversationModel? conversationObject;
  //   try {
  //     List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
  //         'SELECT c.*, gp.isBlocked, u.memberId as userId, u.username, u.profile FROM ${SqfliteTableName.tableConversation} c LEFT JOIN ${SqfliteTableName.tableParticipant} gp ON gp.conversationId = c.id AND gp.memberId != ${GS.userData.value?.id} LEFT JOIN ${SqfliteTableName.tableUser} u ON u.memberId = gp.memberId WHERE (c.createdBy = $userId OR c.receiverId = $userId) AND c.isGroup = 0 AND c.isDelete = 0 LIMIT 1');

  //     Log.info('GET SINGLE CONVERSATION ${conversationMaps.length}');
  //     if (conversationMaps.isNotEmpty) {
  //       for (final data in conversationMaps) {
  //         Log.success('User ID: ${data['userId']}');
  //         Log.success('User Name: ${data['username']}');
  //         Log.success('User Profile: ${data['profile']}');
  //         Log.success('IS BLOCKED: ${data['isBlocked']}');
  //         final ConversationModel messageItem = ConversationModel(
  //           id: data['id'],
  //           conversationUniqueId: data['conversationUniqueId'],
  //           isGroup: data['isGroup'],
  //           name: data['name'],
  //           photo: data['photo'],
  //           description: data['description'],
  //           maxMember: data['maxNumber'],
  //           isMemberAccess: data['isMemberAccess'],
  //           createdBy: data['createdBy'],
  //           addedBy: data['addedBy'],
  //           updatedBy: data['updatedBy'],
  //           senderId: data['senderId'],
  //           receiverId: data['receiverId'],
  //           isDelete: data['isDelete'] == 1 ? true : false,
  //           updatedAt: data['updatedAt'],
  //           userId: data['userId'],
  //           username: data['username'],
  //           profile: data['profile'],
  //           isBlocked: data['isBlocked'],
  //         );
  //         conversationObject = messageItem;
  //       }
  //       Log.info('GET SINGLE CONVERSATION ID ${conversationObject!.id ?? 0}');
  //       return conversationObject;
  //     } else {
  //       return null;
  //     }
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return null;
  // }

  // Future<ConversationModel?> getSingleConversationByConversationId(
  //     {required int conversationId}) async {
  //   Log.info(
  //       '============== In singleConversationByConversationId ==============');
  //   ConversationModel? conversationObject;
  //   try {
  //     List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
  //       'SELECT c.*, gp.isBlocked, u.memberId as userId, u.username, u.profile FROM ${SqfliteTableName.tableConversation} c LEFT JOIN ${SqfliteTableName.tableParticipant} gp ON gp.conversationId = c.id AND gp.memberId != ${GS.userData.value?.id} LEFT JOIN ${SqfliteTableName.tableUser} u ON u.memberId = gp.memberId WHERE c.id = $conversationId',
  //     );

  //     Log.info('GET SINGLE CONVERSATION ${conversationMaps.length}');
  //     if (conversationMaps.isNotEmpty) {
  //       for (final data in conversationMaps) {
  //         // Log.success('User ID: ${data['userId']}');
  //         // Log.success('User Name: ${data['username']}');
  //         // Log.success('User Profile: ${data['profile']}');
  //         // Log.success('IS BLOCKED: ${data['isBlocked']}');
  //         final ConversationModel messageItem = ConversationModel(
  //           id: data['id'],
  //           conversationUniqueId: data['conversationUniqueId'],
  //           isGroup: data['isGroup'],
  //           name: data['name'],
  //           photo: data['photo'],
  //           description: data['description'],
  //           maxMember: data['maxNumber'],
  //           isMemberAccess: data['isMemberAccess'],
  //           createdBy: data['createdBy'],
  //           addedBy: data['addedBy'],
  //           updatedBy: data['updatedBy'],
  //           senderId: data['senderId'],
  //           receiverId: data['receiverId'],
  //           isDelete: data['isDelete'] == 1 ? true : false,
  //           updatedAt: data['updatedAt'],
  //           userId: data['userId'],
  //           username: data['username'],
  //           profile: data['profile'],
  //           isBlocked: data['isBlocked'],
  //         );
  //         conversationObject = messageItem;
  //       }
  //       Log.info('GET SINGLE CONVERSATION ID ${conversationObject!.id ?? 0}');
  //       return conversationObject;
  //     } else {
  //       return null;
  //     }
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return null;
  // }

  Future<List<ConversationModel>> fetchConversationWhere(
      {required int conversationId}) async {
    Log.info('============== In getAllConversationData ==============');
    try {
      List<Map<String, dynamic>>? conversationMaps = await _db.rawQuery(
        'SELECT * FROM ${SqfliteTableName.tableConversation} WHERE conversationId = $conversationId',
      );
      // Log.info('GET FETCH CONVERSATION QUERY ${await _db.rawQuery(
      //   'SELECT * FROM ${SqfliteTableName.tableConversation} WHERE receiverId = $conversationId',
      // )}');

      var arrayOfConversation = <ConversationModel>[];
      arrayOfConversation = conversationMaps
          .map((map) => ConversationModel.fromJson(map))
          .toList();
      return arrayOfConversation;
    } catch (error) {
      Log.error(error.toString());
    }
    return [];
  }

  // // Get all the conversation ids in comma separated string
  // Future<String> getAllConversationIds() async {
  //   Log.info('============== In getAllConversationIds ==============');
  //   try {
  //     List<Map<String, dynamic>>? conversationIds = await _db.rawQuery(
  //       'SELECT id FROM ${SqfliteTableName.tableConversation}',
  //     );
  //     var arrayOfIds = <int>[];
  //     for (var i = 0; i < conversationIds.length; i++) {
  //       int convId = conversationIds[i]['id'];
  //       arrayOfIds.add(convId);
  //     }
  //     Log.info('GET ALL CONVERSATION IDS ${arrayOfIds.join(',')}');
  //     return arrayOfIds.join(',');
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return '';
  // }

  // // A method that retrieves all the message by conversations
  // Future<List<MessageModel>> getAllMessagesByConversationId({
  //   required int senderId,
  //   required int receiverId,
  // }) async {
  //   Log.info('============== In getAllConversationData ==============');
  //   try {
  //     List<Map<String, dynamic>>? messageMaps = await _db.rawQuery(
  //         'SELECT m.*, u.memberId as userId, u.username, u.profile, r.deliveredAt, r.readAt FROM ${SqfliteTableName.tableMessage} m LEFT JOIN ${SqfliteTableName.tableUser} u ON u.memberId = m.senderId LEFT JOIN ${SqfliteTableName.tableReceipts} r ON r.messageId = m.id WHERE m.conversationId = $conversationId GROUP BY m.messageUniqueId ORDER By m.createdAt ASC');

  //     Log.info('GET CONVERSATION MESSAGE LENGTH: ${messageMaps.length}');
  //     var arrayOfMessage = <MessageModel>[];
  //     for (final data in messageMaps) {
  //       // Log.info('GET CONVERSATION READ AT: ${data['readAt']}');
  //       final MessageModel messageItem = MessageModel(
  //         id: data['id'],
  //         messageUniqueId: data['messageUniqueId'],
  //         conversationId: data['conversationId'],
  //         senderId: data['senderId'],
  //         parentId: data['parentId'],
  //         content: data['content'],
  //         isForwarded: data['isForwarded'],
  //         type: data['type'],
  //         isTestdata: data['isTestData'] == 1 ? true : false,
  //         isDelete: data['isDelete'] == 1 ? true : false,
  //         createdAt: data['createdAt'],
  //         updatedAt: data['updatedAt'],
  //         userId: data['userId'],
  //         username: data['username'],
  //         profile: data['profile'],
  //         deliveredAt: data['deliveredAt'],
  //         readAt: data['readAt'] ?? '',
  //       );
  //       arrayOfMessage.add(messageItem);
  //     }
  //     return arrayOfMessage;
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return [];
  // }

  // A method that retrieves all the message by conversations
  // Future<List<MessageModel>> searchMessages({
  //   required String messageText,
  // }) async {
  //   Log.info('============== In getAllSearchMessages ==============');
  //   try {
  //     List<Map<String, dynamic>>? messageMaps = await _db.rawQuery(
  //         "SELECT m.*, c.isGroup, c.name as group_name, c.photo as group_photo, gp.isBlocked, u.memberId as userId, u.username, u.profile, ur.memberId as receiverId, ur.username as receiverUsername, ur.profile as receiverProfile, r.receiverId, r.deliveredAt, r.readAt FROM ${SqfliteTableName.tableMessage} m LEFT JOIN ${SqfliteTableName.tableConversation} c ON c.id = m.conversationId LEFT JOIN ${SqfliteTableName.tableParticipant} gp ON gp.conversationId = m.conversationId LEFT JOIN ${SqfliteTableName.tableReceipts} r ON r.messageId = m.id LEFT JOIN ${SqfliteTableName.tableUser} u ON u.memberId = m.senderId LEFT JOIN user ur ON ur.memberId = r.receiverId WHERE m.content LIKE '%$messageText%' GROUP BY m.messageUniqueId ORDER By m.createdAt ASC");

  //     // Log.info('GET SEARCH MESSAGE LENGTH: ${messageMaps.length}');
  //     var arrayOfMessage = <MessageModel>[];
  //     for (final data in messageMaps) {
  //       Log.info('USER ID : ${data['userId']}');
  //       Log.info('SENDER ID : ${data['senderId']}');
  //       Log.info('PARENT ID : ${data['parentId']}');
  //       Log.info('RECEIVER ID : ${data['receiverId']}');
  //       Log.info('USERNAME : ${data['username']}');
  //       final MessageModel messageItem = MessageModel(
  //         id: data['id'],
  //         messageUniqueId: data['messageUniqueId'],
  //         conversationId: data['conversationId'],
  //         senderId: data['senderId'],
  //         parentId: data['parentId'],
  //         content: data['content'],
  //         isForwarded: data['isForwarded'],
  //         type: data['type'],
  //         isTestdata: data['isTestData'] == 1 ? true : false,
  //         isDelete: data['isDelete'] == 1 ? true : false,
  //         createdAt: data['createdAt'],
  //         updatedAt: data['updatedAt'],
  //         isGroup: data['isGroup'],
  //         name: data['group_name'],
  //         photo: data['group_photo'],
  //         userId: data['userId'],
  //         username: data['userId'] == GS.userData.value?.id
  //             ? data['receiverUsername']
  //             : data['username'],
  //         profile: data['userId'] == GS.userData.value?.id
  //             ? data['receiverProfile']
  //             : data['profile'],
  //         isBlocked: data['isBlocked'],
  //         deliveredAt: data['deliveredAt'],
  //         readAt: data['readAt'] ?? '',
  //       );
  //       arrayOfMessage.add(messageItem);
  //     }
  //     return arrayOfMessage;
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return [];
  // }

  // A method that retrieves all the unread messages count
  // Future<int> getUnreadMessageCount() async {
  //   Log.info('============== In getUnreadMessageCount ==============');
  //   int unreadMsgCount = 0;
  //   try {
  //     var result = await _db.rawQuery(
  //         "SELECT COUNT(m.id) as msgCount, r.readAt FROM ${SqfliteTableName.tableMessage} m LEFT JOIN ${SqfliteTableName.tableReceipts} r ON r.messageId = m.id WHERE r.receiverId == ${GS.userData.value?.id} AND r.readAt = ''");

  //     Log.info('GET CONVERSATION MESSAGE LENGTH: ${result[0]}');
  //     Log.info('UNREAD MESSAGE: ${result[0]['msgCount'] ?? ''}');
  //     unreadMsgCount = int.parse(result[0]['msgCount'].toString());
  //     return unreadMsgCount;
  //   } catch (error) {
  //     Log.error(error.toString());
  //   }
  //   return unreadMsgCount;
  // }

  // Save conversation in local database
  Future<void> saveConversation({
    required List<ConversationModel> arrayOfConversation,
  }) async {
    for (var i = 0; i < arrayOfConversation.length; i++) {
      Log.info(
          'CONVERSATION ID: ${arrayOfConversation[i].conversationid ?? 0}');
      final conversation = ConversationsTbl(
        id: arrayOfConversation[i].id ?? 0,
        conversationId: arrayOfConversation[i].conversationid ?? 0,
        senderId: arrayOfConversation[i].senderid ?? 0,
        receiverId: arrayOfConversation[i].receiverid ?? 0,
        createdBy: arrayOfConversation[i].createdby ?? 0,
        updatedAt: arrayOfConversation[i].updatedAt ?? '',
        isDelete: arrayOfConversation[i].isDelete == true ? 1 : 0,
        fullName: arrayOfConversation[i].fullname ?? '',
        profileUserId: arrayOfConversation[i].profileuserid ?? 0,
        profileImage: arrayOfConversation[i].profileimage ?? '',
        messageContent: arrayOfConversation[i].messagecontent ?? '',
        newMessage: arrayOfConversation[i].newMessage ?? 0,
        profileuserisDelete: arrayOfConversation[i].profileuserisDelete ?? 0,
      );

      await dbHelper.insertConversation(conversation);
    }
  }

  // Save message in local database
  Future<void> saveMessage({
    required List<MessageModel> arrayOfMessage,
    // required MessageModel arrayOfMessage,
  }) async {
    for (var i = 0; i < arrayOfMessage.length; i++) {
      final message = MessagesTbl(
        id: arrayOfMessage[i].id ?? 0,
        conversationId: arrayOfMessage[i].conversationid ?? 0,
        senderId: arrayOfMessage[i].senderid! ?? 0,
        content: arrayOfMessage[i].messagecontent ?? '',
        isTestdata: arrayOfMessage[i].istestdata == true ? 1 : 0,
        isDelete: arrayOfMessage[i].isdelete == true ? 1 : 0,
        createdAt: arrayOfMessage[i].createdat ?? '',
        updatedAt: arrayOfMessage[i].updatedat ?? '',
        messageId: arrayOfMessage[i].id ?? 0,
        currentStatus: arrayOfMessage[i].currentstatus ?? 0,
      );
      print('this is inserting in db ---->>${message.conversationId}');
      await dbHelper.insertMessage(message);
    }
  }

  Future<void> saveNewConversation(
      {required int id,
      required int conversationId,
      required int createdBy,
      required int receiverId,
      required int senderId,
      required int profileUserId,
      required String profileImage,
      required String fullName,
      required bool isDelete,
      required String updatedAt,
      required String messageContent}) async {
    var conversationData =
        await dbHelper.fetchConversationWhere(conversationId: conversationId);
    Log.info("FETCH CON WHERE: ${conversationData.length}");
    Log.info("===== conversationId: $conversationId");
    Log.info("===== senderId: $senderId");
    Log.info("===== receiverId: $receiverId");
    if (conversationData.isEmpty) {
      final conversation = ConversationsTbl(
          id: 0,
          conversationId: conversationId,
          senderId: senderId,
          receiverId: receiverId,
          createdBy: 0,
          updatedAt: DateTime.now().toString(),
          isDelete: 0,
          profileUserId: profileUserId,
          profileImage: profileImage,
          fullName: fullName,
          messageContent: messageContent,
          newMessage: 1,
          profileuserisDelete: 0);
      await dbHelper.insertConversation(conversation);
    }
  }

  Future<MessageModel> saveNewMessage({
    required int id,
    required int messageId,
    required int conversationId,
    required int senderId,
    required String content,
    required int isTestdata,
    required int isDelete,
    required String createdAt,
    required int currentstatus,
    required String? updatedAt,
  }) async {
    // final message = MessagesTbl(
    //   id: 0,
    //   messageId: messageId,
    //   conversationId: conversationId,
    //   senderId: senderId,
    //   content: content,
    //   isTestdata: isTestdata,
    //   isDelete: 0,
    //   createdAt: DateTime.now().toUtc().toString(),
    //   updatedAt: DateTime.now().toUtc().toString(),
    //    currentStatus: 0,
    // );
    // await dbHelper.insertMessage(message);
    final MessageModel messageItem = MessageModel(
      id: messageId,
      conversationid: conversationId,
      senderid: senderId,
      messagecontent: content,
      istestdata: isTestdata.toString(),
      isdelete: "0",
      createdat: DateTime.now().toUtc().toString(),
      updatedat: DateTime.now().toUtc().toString(),
      currentstatus: currentstatus,
    );
    return messageItem;
  }

  // Clear database
  Future<void> clearDatabase() async {
    Log.info('============== In clearDatabase ==============');

    // Execute SQL statements to truncate all tables
    await _db.execute('DELETE FROM ${SqfliteTableName.tableConversation}');
    await _db.execute('DELETE FROM ${SqfliteTableName.tableMessage}');
    // Add more delete statements for other tables if needed
  }

  Future<void> deleteMessageAndReceiptsTable() async {
    Log.info('============== In clearDatabase ==============');
    // Execute SQL statements to truncate all tables
    await _db.execute('DELETE FROM ${SqfliteTableName.tableMessage}');
  }

  Future<void> blockUser(
      {required int loginId,
      required int otherUserId,
      required int isTestData}) async {
    Log.info("===== loginId: $loginId");
    Log.info("===== otherUserId: $otherUserId");
    Log.info("===== isTestData: $isTestData");

    final blockedUser = BlockedUserTbl(
        id: 0,
        userId: otherUserId,
        blockedBy: loginId,
        isDelete: 0,
        isTestData: isTestData,
        createdAt: DateTime.now().toString());
    await dbHelper.insertBlockedUser(blockedUser);
  }
}
