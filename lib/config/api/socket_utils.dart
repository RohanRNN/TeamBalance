import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/notification_controller.dart';
import 'package:team_balance/app/views/chats/chat_message_controller.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/chat_tables/blocked_user_tbl.dart';
import 'package:team_balance/utils/chat_tables/conversations_tbl.dart';
import 'package:team_balance/utils/chat_tables/message_tbl.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/message_model.dart';
import 'package:team_balance/utils/notification_center.dart';


abstract class SocketUtils {

  static late IO.Socket socket;

  // * INIT SOCKET
  static void initSocket({VoidCallback? onConnect}) {   
    

  bool isInitialConversationFetched = false;
    Log.info('initSocket Runs');
    socket = IO.io(
      SocketPaths.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .enableForceNewConnection() // necessary because otherwise it would reuse old connection
          .enableReconnection()
          .setReconnectionDelay(500)
          .setReconnectionAttempts(100)
          .build(),
    );
    // print('this is socket status --->   ${socket.connected}');
// if(socket.connected == null) {
    socket.connect();
    socket.onConnect((_) async {
      Log.success('*** Connected to websocket ***');
      if (onConnect != null) {       
        onConnect();
                    var userId = GS.userData.value!.id;
                    var isTestdata = AppConfig.isTestData; 
                         SocketUtils.socket.emit(SocketPaths.getUserId, {
                       'userId': userId,
                       'isTestdata': isTestdata
                     });    
                    //  await fetchInitialConversation();    
                   }
                 });

    socket.onDisconnect((_) async {
      Log.error('*** Socket disconnected ***');
      // await Future.delayed(const Duration(milliseconds: 500));
      // socket.connect();
    });

    socket.onError((data) {
      Log.error('*** Socket ERROR ***');
      Log.error(data);
    });
    socket.onConnecting((_) {
      Log.error('*** Socket Connecting ***');
    });
    socket.onReconnect((_) {
      Log.error('*** Socket Reconnect ***');
      SocketUtils.joinSocket();
    });
    socket.onReconnecting((_) {
      Log.error('*** Socket Reconnecting ***');
    });
// }
  }



  static void joinSocket() {
    
     SocketUtils.initSocket(onConnect: () {
      Log.success('** onConnect runs **');
      try {  
        Log.warning('SOCKET ADDED LISTNER : $isSocketListnerAdded');

        if (isSocketListnerAdded) {
          isSocketListnerAdded = false;
        }

        if (!isSocketListnerAdded) {
          isSocketListnerAdded = true;
          addSocketListenEvent();
          Log.warning('SOCKET ADDED LISTNER : $isSocketListnerAdded');
        }

        Log.warning('SOCKET ADDED LISTNER : $isSocketListnerAdded');
      } catch (e) {
        Log.error("*** Socket emit JoinSocket error ***");
        Log.error(e.toString());
      }
    });
  }

  static void disconnetSocket() {
    Log.success('** disconnetSocket **');
    try {
      SocketUtils.socket.emit(SocketPaths.disconnectSocket, {
        // GS.userData.value!.id,
        //   AppConfig.isTestData,
      });
      isSocketListnerAdded = false;
      SocketUtils.socket.clearListeners();
    } catch (e) {
      Log.error("*** Socket emit JoinSocket error ***");
      Log.error(e.toString());
    }
  }

  // * LISTEN EVENT
  static void listenEvent(
      {required String eventName, required ValueChanged<dynamic> onEvent}) {
        print('new======');
    socket.on(eventName, (data) {
      Log.success('** Socket on Event - $eventName **');
      onEvent(data);
    });
  }

  // * EMIT
  static void emit({required String emitName, Map<String, dynamic>? emitData}) {
    socket.emit(emitName, emitData);
  }

//=============== Socket APIs ===============//

  // Socket api - Fetch Initial Conversatoin
  static Future<void> fetchInitialConversation() async {
    var userId = GS.userData.value!.id;
    var isTestData = AppConfig.isTestData;
    var page = 1;
    var pageSize = 10;
    final emitData = 
      { 
      'userId':userId, 
      'isTestdata':isTestData, 
      'page':page, 
      'pageSize':pageSize }
    ;
    Log.info('FETCH CONVERSATION PARAM $emitData'); 
      //////////////   Socket event for conversation call
      socket.emit(
     'get_conversation_list',
      { 
      'userId':userId, 
      'isTestdata':isTestData, 
      'page':page, 
      'pageSize':pageSize });
  }

  // Socket api - Fetch All Message
  static Future<void> fetchAllMessage({
    required sender_id,
    required recipient_id,
    required istestdata,
    required page,
    required pageSize
  }) async {

    var senderId = sender_id;
    var recipientId = recipient_id; 
    var isTestdata = istestdata; 
    var pageRes = page; 
    var pageSizeRes = pageSize;
     

    final emitData = {
      'senderId' : senderId, 
      'recipientId' : recipientId, 
      'isTestdata' : isTestdata, 
      'page' : pageRes, 
      'pageSize' : pageSizeRes
    };

//     SocketUtils.listenEvent(
//         eventName: SocketPaths.previousConversations,
//         onEvent: (data) async {
//           print('this is new previousConversations ======>>>>${data}');
//             try {
//         Log.info('MESSAGE ACK: $data');
//         if (data['status'] == SocketStatus.success) {
//           var arrayOfMessage = <MessageModel>[];
//           final messageData = data['data'];          
//           Log.info('MESSAGE DATA ${data['data']}');

//        await data['data'].forEach((currentData) {
//   var newMessage = MessageModel(
//     id: currentData['id'],
//     conversationid: currentData['conversation_id'],
//     messagecontent: currentData['message_content'],
//     createdat: currentData['created_at'],
//     updatedat: currentData['updated_at'],
//     readat: currentData['read_at']? true: false ,
//     istestdata: AppConfig.isTestData.toString(),
//     senderid: currentData['sender_id'].toString(),
//     isdelete: "0",
//   );
//   arrayOfMessage.add(newMessage);
// });

//           /*  === INSERT MESSAGE DATA IN LOCAL DB === */
//           await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
//         }
//       } catch (e) {
//         Log.error("While fetch messages socket event");
//         Log.error(e);
//       }
//         });

    Log.info('FETCH MESSAGE PARAM $emitData');
    socket.emit('get_conversation', emitData);
  }


  // Socket api - typingStart
  static Future<void> typingStarted({
    required int loginId,
    required int otherUserId, 
    required int typingStatus,
  }) async {  
    var loginIdRes = loginId;
    var otherUserIdRes = otherUserId;
    var isTestDataRes = AppConfig.isTestData;

      final emitData = {
    'senderId': loginIdRes, 
    'recipientId':otherUserIdRes,
    };
  Log.info('typingStarted $emitData');
  socket.emit(SocketPaths.typing,{
    'senderId': loginIdRes, 
    'recipientId':otherUserIdRes,
    'typingStatus':typingStatus 
    });    
  }



// for message read status
  static Future<void> messageReadStatus({
    required int loginId,
    required int otherUserId, 
    required int typingStatus,
  }) async {  
    var loginIdRes = loginId;
    var otherUserIdRes = otherUserId;
    var isTestDataRes = AppConfig.isTestData;

      final emitData = {
    'senderId': loginIdRes, 
    };
  Log.info('typingStarted $emitData');
  socket.emit(SocketPaths.typing,{
    'senderId': loginIdRes, 
    'recipientId':otherUserIdRes,
    'typingStatus':typingStatus 
    });    
  }

  // Socket api - typingStart
  // static Future<void> typingStartedListner({
  //   required int loginId,
  //   required int otherUserId, 
  // }) async { 
  //  SocketUtils.listenEvent(
  //       eventName: SocketPaths.typingResult,
  //       onEvent: (data) async {
  //         print('this is new typingResult ======>>>>${data}');          
  //       });     
  // }

    // Socket api - typingStart
  // static Future<void> typingStopedListner({
  //   required int loginId,
  //   required int otherUserId, 
  // }) async {  
  //   var loginIdRes = loginId;
  //   var otherUserIdRes = otherUserId;

  //     final emitData = {
  //   'senderId': loginIdRes, 
  //   'recipientId':otherUserIdRes,
  //   };
  // Log.info('typingStarted $emitData');
  // socket.emit(SocketPaths.stopTyping,{
  //   'senderId': loginIdRes, 
  //   'recipientId':otherUserIdRes, 
  //   });       
  // }

  // Socket api - block User
  static Future<void> blockUser({
    required int loginId,
    required int otherUserId,
    required int isTestData  
  }) async {
  
    var loginIdRes = loginId;
    var otherUserIdRes = otherUserId;
    var isTestDataRes = AppConfig.isTestData;

      final emitData = {
    'blockerUserId': loginIdRes, 
    'blockedUserId':otherUserIdRes, 
    'isTestdata':isTestDataRes
    };
  Log.info('Blocked User PARAM $emitData');
  socket.emit(SocketPaths.blockUnblockUser,{
    'blockerUserId': loginIdRes, 
    'blockedUserId':otherUserIdRes,  
    'isTestdata':isTestDataRes
    });       
  }


 // Socket api - Send New Message
  static Future<void> sendNewMessage({
     required int conversationId,
     required int senderId,
     required int receiverId,
     required int id, 
     required int createdBy, 
     required int profileUserId, 
     required String profileImage, 
     required String fullName, 
     required bool isDelete, 
     required String updatedAt, 
     required String messageContent 
  }) async {
  
    var senderIdRes = senderId;
    var receiverIdRes = receiverId;
    var messageContentRes = messageContent;
    var isTestDataRes = AppConfig.isTestData;
     var arrayOfMessage = <MessageModel>[];

     var conversationObj = ConversationsTbl(
     id: id, 
     conversationId: conversationId, 
     createdBy: createdBy, 
     receiverId: receiverId, 
     senderId: senderId, 
     profileUserId: profileUserId, 
     profileImage: profileImage, 
     fullName: fullName, 
     isDelete: 0, 
     updatedAt: updatedAt, 
     messageContent: messageContent,
     newMessage: 1,
     profileuserisDelete: 0);
    
    //  SocketUtils.listenEvent(
    //     eventName: SocketPaths.newMessage,
    //     onEvent: (data) async {
    //       print('this is new new_message ======>>>>${data}');
    //       try{
    //     if (data['latestMessage']['status'] == SocketStatus.success) {
    //       if(data['latestMessage']['is_new_conversation'] == 0){
    //           var newMessage = MessageModel(
    //            id: data['latestMessage']['data']['id'],
    //            conversationid: data['latestMessage']['data']['conversation_id'],
    //            messagecontent: data['latestMessage']['data']['message_content'],
    //            createdat: data['latestMessage']['data']['created_at'],
    //            updatedat: data['latestMessage']['data']['updated_at'],
    //            readat: data['latestMessage']['data']['read_at'],
    //            istestdata: AppConfig.isTestData.toString(),
    //            senderid: data['latestMessage']['data']['sender']['id'].toString(),
    //            isdelete: "0",
    //          );
    //          arrayOfMessage.add(newMessage);
    //           await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
    //              if (newMessage != null) { 
    //           await updateConversation(conversationObject:conversationObj, isNewConversion: false);        
    //         }
    //       }else{
    //            print('this is new new_message ======>>>>${data['latestMessage']['data']['conversation_id']}');
    //            var conversationObj = ConversationsTbl(
    //                     id: data['latestMessage']['data']['id'], 
    //                    conversationId: data['latestMessage']['data']['conversation_id'], 
    //                    createdBy: data['latestMessage']['data']['created_by'], 
    //                    receiverId: data['latestMessage']['data']['receiver_id'], 
    //                    senderId: data['latestMessage']['data']['sender_id'], 
    //                    profileUserId: data['latestMessage']['data']['sender']['id'], 
    //                    profileImage: data['latestMessage']['data']['sender']['profile_image'],
    //                    fullName: data['latestMessage']['data']['sender']['profile_image'], 
    //                    isDelete: 0, 
    //                    updatedAt: data['latestMessage']['data']['created_at'], 
    //                    messageContent: data['latestMessage']['data']['message_content']);
    //         await updateConversation(conversationObject:conversationObj, isNewConversion: true); 
    //            var newMessage = MessageModel(
    //            id: data['latestMessage']['data']['id'],
    //            conversationid: data['latestMessage']['data']['conversation_id'],
    //            messagecontent: data['latestMessage']['data']['message_content'],
    //            createdat: data['latestMessage']['data']['created_at'],
    //            updatedat: data['latestMessage']['data']['updated_at'],
    //            readat: data['latestMessage']['data']['read_at'],
    //            istestdata: AppConfig.isTestData.toString(),
    //            senderid: data['latestMessage']['data']['sender']['id'].toString(),
    //            isdelete: "0",
    //          );
    //          arrayOfMessage.add(newMessage);
    //           await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
    //       }
    //     }
    //   } catch (e) {
    //     Log.error("While send new message socket event");
    //     Log.error(e);
    //   }
    //     });

      final emitData = {
        'conversationId':conversationId,
    'senderId': senderIdRes, 
    'recipientId':receiverIdRes, 
    'message':messageContentRes, 
    'isTestdata':isTestDataRes
    };
  Log.info('SEND NEW MESSAGE PARAM $emitData');

  socket.emit(SocketPaths.newMessage,{
    'conversationId':conversationId,
    'senderId': senderIdRes, 
    'recipientId':receiverIdRes, 
    'message':messageContentRes, 
    'isTestdata':isTestDataRes,
    });
       
  }


//=============== Other Method ===============//
  static Future<void> updateConversation(
      {required ConversationsTbl conversationObject,
      required bool isNewConversion}) async {

    Log.info('CONVERSATION SEND DATA: ${conversationObject.conversationId}');
 try{
  if(isNewConversion){    
    await dbHelper.insertConversation(conversationObject);
   }else{
    print('this is dbHelper.updateConversation ====> ');
     await dbHelper.updateConversation(
      conversations: conversationObject,
      uniqueId: conversationObject.conversationId!,
    );
   } 
 }catch(error){
  Log.error(error);
    print('An error occured ::: ${error}');
 }       
  }


static Future<void> updateConversationIsDelete(
    {required String conversationId, required int isDelete}) async {
  try {
    await dbHelper.updateConversationIsDelete(
      conversationId: conversationId,
      isDelete: isDelete,
    );
    Log.info('Updated is_delete for conversationId: $conversationId');
  } catch (error) {
    Log.error(error);
    print('An error occurred while updating is_delete: $error');
  }
}


  // Socket api - Fetch All Message
  // static Future<void> fetchAllMessage() async {
  //   final emitData = {
  //     "userId": GS.userData.value!.id,
  //     "Last_message_id": await dbHelper.getLastMessageId(),
  //     "testdata": AppConfig.isTestData
  //   };
  //   Log.info('FETCH MESSAGE PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.fetchMessages, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('MESSAGE ACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         var arrayOfMessage = <MessageModel>[];
  //         final messageData = ackData['data'];
  //         Log.info('MESSAGE DATA ${ackData['data']}');
  //         arrayOfMessage.addAll(List<MessageModel>.from(
  //             messageData.map((x) => MessageModel.fromJson(x))));
  //         Log.info('MESSAGE DATA Length: ${arrayOfMessage.length}');

  //         /*  === INSERT MESSAGE DATA IN LOCAL DB === */
  //         await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
  //       }
  //     } catch (e) {
  //       Log.error("While fetch messages socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

  // static Future<void> updateMessage({
  //   required MessageModel messageData,
  // }) async {
  //   final messageItem = MessagesTbl(
  //     id: messageData.id ?? 0,
  //     conversationId: messageData.conversationid ?? 0,
  //     senderId: int.parse(messageData.senderid!) ?? 0,
  //     content: messageData.messagecontent ?? '',
  //     isTestdata: messageData.istestdata == true ? 1 : 0,
  //     isDelete: messageData.isdelete == true ? 1 : 0,
  //     createdAt: messageData.createdat ?? '',
  //     updatedAt: messageData.updatedat ?? '', 
  //     messageId: messageData.id!, 
  //     readat: messageData.readat! ??'',
  //   );

  //   await dbHelper.updateMessage(
  //       message: messageItem, uniqueId: messageData.id.toString() ?? '');
  // }


  // Save message in local database
  Future<void> saveMessage({
    required List<MessageModel> arrayOfMessage,
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
        messageId: arrayOfMessage[i].id!, 
        currentStatus: 1,
      );
      await dbHelper.insertMessage(message);
    }
  }

  // Socket api - send Privatel Message
  static Future<void> sendPrivatelMessage({
    required String message,
    required int senderId,
    required int receiverId,
    required int isTestdata,
  }) async {
    // final emitData = {
    //   "senderId": senderId,
    //   "receiverId": receiverId,
    //   "message": message,
    //   "isTestdata": isTestdata,
    // };
    //  final emitData = {
    //   senderId,
    //   receiverId,
    //   message,
    //   isTestdata,
    // };
    // Log.info('SEND 123 NEW MESSAGE PARAM $emitData');
    // socket.emit('private_message', { senderId, receiverId, message, isTestdata });
    // print('this is socket response===>${response}');
    // socket.emitWithAck(SocketPaths.privateMessage, emitData,
    //     ack: (ackData) async {
    //       print('this is123456789 =====>>>');
    //   try {
    //     Log.info('MESSAGE CALLBACK: $ackData');
    //     // if (ackData['status'] == SocketStatus.success) {
    //     //   if (ackData['isNewConversion'] == true) {
    //     //     ConversationModel? conversationObject;
    //     //     final conversationData = ackData['data'];

    //     //     if (conversationData != null) {
    //     //       conversationObject = ConversationModel.fromJson(conversationData);
              // await updateConversation(
    //     //         conversationObject: conversationObject,
    //     //         isFromNewMsgSocketEvent: false,
    //     //       );
    //     //       CustomeNotificationCenter.instance.post(
    //     //           NotifyNotificationName.notifySendNewMsgEvent,
    //     //           userInfo: {
    //     //             SocketPaths.conversationIdKey: conversationObject.id
    //     //           });
    //     //     }
    //     //   } else {
    //     //     final messageData = ackData['data'];
    //     //     if (messageData != null) {
    //     //       final messageObject = MessageModel.fromJson(messageData);
    //     //       await updateMessage(messageData: messageObject);
    //     //       CustomeNotificationCenter.instance.post(
    //     //           NotifyNotificationName.notifySendNewMsgEvent,
    //     //           userInfo: {
    //     //             SocketPaths.conversationIdKey: messageObject.conversationId
    //     //           });
    //     //     }
    //     //   }
    //     // }
    //   } catch (e) {
    //     Log.error("While send new message socket event");
    //     Log.error(e);
    //   }
    // });
  }

  // Socket api - Update message status
  // static Future<void> updateMessageStatus({
  //   required int conversationId,
  //   required int isTestdata,
  // }) async {
  //   final emitData = {
  //     "conversion_id": conversationId,
  //     "userId": GS.userData.value?.id,
  //     "testdata": isTestdata
  //   };
  //   Log.info('UPDATE MESSAGE STATUS PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.updateMessageStatus, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('UPDATE MESSAGE STATUS ACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         final data = ackData['data'] as List<dynamic>;
  //         if (data.isNotEmpty) {
  //           var arrayOfReceipt = <ReceiptsModel>[];
  //           final receiptData = ackData['data'];

  //           arrayOfReceipt.addAll(List<ReceiptsModel>.from(
  //               receiptData.map((x) => ReceiptsModel.fromJson(x))));

  //           for (var i = 0; i < arrayOfReceipt.length; i++) {
  //             Log.info('IPHONE 1333333333');
  //             Log.info('MSG READ AT DATE : ${arrayOfReceipt[i].readAt}');
  //             final receiptItem = ReceiptsTbl(
  //                 id: arrayOfReceipt[i].id ?? 0,
  //                 conversationId: arrayOfReceipt[i].conversationId ?? 0,
  //                 messageId: arrayOfReceipt[i].messageId ?? 0,
  //                 messageUniqueId: arrayOfReceipt[i].messageUniqueId ?? '',
  //                 receiverId: arrayOfReceipt[i].receiverId ?? 0,
  //                 deliveredAt: arrayOfReceipt[i].deliveredAt ?? '',
  //                 readAt: arrayOfReceipt[i].readAt ?? '',
  //                 isBlocked: arrayOfReceipt[i].isBlocked == true ? 1 : 0,
  //                 createdAt: arrayOfReceipt[i].createdAt ?? '',
  //                 updatedAt: arrayOfReceipt[i].updatedAt ?? '');
  //             await dbHelper.updateReceipts(
  //                 receipts: receiptItem,
  //                 msgUniqueId: arrayOfReceipt[i].messageUniqueId ?? '',
  //                 receiverId: arrayOfReceipt[i].receiverId ?? 0);
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       Log.error("While update message socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

  // Socket api - Get unread notification count
  // static Future<void> getUnreadNotificationCount() async {
  //   final emitData = {
  //     "userId": GS.userData.value?.id ?? 0,
  //     "testdata": AppConfig.isTestData
  //   };
  //   Log.info('UNREAD NOTIFICATION COUNT PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.getNotificationCount, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('UNREAD NOTIFICATION ACK $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         final data = ackData['data'];
  //         int notificaitonCount = data['count'];
  //         Log.info('UNREAD NOTIFICATION COUNT: $notificaitonCount');
  //         CustomeNotificationCenter.instance.post(
  //             NotifyNotificationName.notifyNotificationCount,
  //             userInfo: data);
  //       }
  //     } catch (e) {
  //       Log.error("While get unread notification count socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

// Socket api - New conversation join in room
  // static Future<void> newConversationJoinInRoom({
  //   required int conversationId,
  // }) async {
  //   final emitData = {
  //     "conversion_id": conversationId,
  //   };
  //   Log.info('NEW CONVERSATION JOIN PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.newConversionJoinInRoom, emitData,
  //       ack: (ackData) async {});
  // }

// Socket api - Create group
  // static Future<void> createGroup({
  //   required int userId,
  //   required String groupName,
  //   required String description,
  //   required String memberIds,
  //   required String conversationUniqueId,
  //   required int isTestdata,
  // }) async {
  //   final emitData = {
  //     "userId": userId,
  //     "name": groupName,
  //     "description": description,
  //     "selected_members": memberIds,
  //     "conversation_unique_id": conversationUniqueId,
  //     "testdata": isTestdata
  //   };
  //   Log.info('CREATE GROUP PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.createGroup, emitData, ack: (ackData) async {
  //     try {
  //       Log.info('CREATE GROUP CALLBACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         ConversationModel? conversationObject;
  //         if (ackData['data'] != null) {
  //           final conversationData = ackData['data'];
  //           Log.info('GROUP DATA: $conversationData');
  //           if (conversationData != null) {
  //             conversationObject = ConversationModel.fromJson(conversationData);
  //             await dbHelper.saveConversation(
  //               arrayOfConversation: [conversationObject],
  //               isCreateGroup: true,
  //             );

  //             CustomeNotificationCenter.instance
  //                 .post(NotifyNotificationName.notifyGetNewMsgEvent);

  //             CustomeNotificationCenter.instance.post(
  //                 NotifyNotificationName.notifyCreateNewGroup,
  //                 userInfo: {'conversationId': conversationObject.id});
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       Log.error("While create group socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

// Socket api - Clear chat
  // static Future<void> clearChat({
  //   required int userId,
  //   required int conversationId,
  //   required int isTestdata,
  // }) async {
  //   final emitData = {
  //     "userId": userId,
  //     "conversion_id": conversationId,
  //     "testdata": isTestdata
  //   };
  //   Log.info('CLEAR CHAT PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.clearChat, emitData, ack: (ackData) async {
  //     try {
  //       Log.info('CLEAR CHAT CALLBACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         await dbHelper.deleteMessages(conversationId: conversationId);
  //         CustomeNotificationCenter.instance
  //             .post(NotifyNotificationName.notifyClearChat);
  //       }
  //     } catch (e) {
  //       Log.error("While clear chat socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

// Socket api - Clear chat history
  // static Future<void> clearChatHistory({
  //   required int userId,
  //   required int isTestdata,
  // }) async {
  //   final emitData = {"userId": userId, "testdata": isTestdata};
  //   Log.info('CLEAR CHAT HISTORY PARAM $emitData');
  //   socket.emitWithAck(SocketPaths.clearChatHistory, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('CLEAR CHAT HISTORY CALLBACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         await dbHelper.deleteMessageAndReceiptsTable();
  //         CustomeNotificationCenter.instance
  //             .post(NotifyNotificationName.notifyClearChatHistory);
  //       }
  //     } catch (e) {
  //       Log.error("While clear chat socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

  // Socket api - Follow user
  // static Future<void> removeFollowUser({
  //   required int userId,
  //   required int followingId,
  // }) async {
  //   final emitData = {
  //     "userId": userId,
  //     "following_id": followingId,
  //     "testdata": AppConfig.isTestData
  //   };
  //   Log.info('REMOVE FOLLOW USER PARAM $emitData');
  //   SocketUtils.socket.emitWithAck(SocketPaths.removeUserFromFollower, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('REMOVE FOLLOW ACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         CustomeNotificationCenter.instance
  //             .post(NotifyNotificationName.notifyRemoveFollower);
  //       } else {
  //         showTopFlashMessage(ToastType.failure, ackData['message'].toString());
  //       }
  //     } catch (e) {
  //       Log.error("While remove follower socket event");
  //       Log.error(e);
  //     }
  //   });
  // }

  // // Socket api - Follow user
  // Future<void> socketApiFollowUser({required int followingId}) async {
  //   final emitData = {
  //     "userId": GS.userData.value?.id,
  //     "following_id": followingId,
  //     "testdata": AppConfig.isTestData
  //   };
  //   Log.info('FOLLOW USER PARAM $emitData');
  //   SocketUtils.socket.emitWithAck(SocketPaths.followUser, emitData,
  //       ack: (ackData) async {
  //     try {
  //       Log.info('FOLLOW ACK: $ackData');
  //       if (ackData['status'] == SocketStatus.success) {
  //         final data = ackData['data'];
  //         CustomeNotificationCenter.instance
  //             .post(NotifyNotificationName.notifyFollowUser, userInfo: data);
  //       } else {
  //         showTopFlashMessage(ToastType.failure, ackData['message'].toString());
  //       }
  //     } catch (e) {
  //       Log.error("While send follow request socket event");
  //       Log.error(e);
  //     }
  //   });
  // }
//=============== Socket Listen Event ===============//

// Socket listen event
  static Future<void> addSocketListenEvent() async {
    bool isInitialConversationFetched = false;
    SocketUtils.socket.clearListeners();
    Log.success('*** listen socket event ***');

      SocketUtils.listenEvent(
        eventName: SocketPaths.socketMapping,
        onEvent: (data) async {
          print('this is new socketMapping ======>>>>${data}');
            if (!isInitialConversationFetched) {
          isInitialConversationFetched = true;
          await fetchInitialConversation();
          Log.success('Initial conversation fetched from event listener');
        }
        });

        SocketUtils.listenEvent(
        eventName: SocketPaths.typingResult,
        onEvent: (data) async {
          CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyIsTyping,
                        userInfo: {
                    'typing_status' : data['resposne']['data']['is_typing'],
                    'sender_user_id' : data['resposne']['data']['senderId'],
                  }
                      );
          print('this is new typingResult in chat module ======>>>>${data}');          
        });    

           SocketUtils.listenEvent(
        eventName: SocketPaths.blockUnblockResult,
        onEvent: (data) async {
           if (data['status'] == SocketStatus.success) {
            
            // var isBlockedUser =  await dbHelper.getBlockedUser(loginUserId: data['data']['blocker_user_id'], oppositUserId: data['data']['blocked_user_id'], isTestdata: AppConfig.isTestData);

            // if(isBlockedUser){
            //   dbHelper.deleteBlockedUser(data['data']['blocker_user_id'], data['data']['blocked_user_id']);
            // }

            // await dbHelper.insertBlockedUser(BlockedUserTbl(
            // id: 0, 
            // userId: data['data']['blocked_user_id'], 
            // blockedBy: data['data']['blocker_user_id'], 
            // isTestData: AppConfig.isTestData, 
            // isDelete: 0, 
            // createdAt: DateTime.now().toString()));
           }
          
          print('this is new blockUnblockResult ======>>>>${data}');
            if (!isInitialConversationFetched) {
          isInitialConversationFetched = true;
          Log.success('blockUnblockResult socket event listener');
        }
        });

         SocketUtils.listenEvent(
        eventName: SocketPaths.getConversationListEvent,
        onEvent: (data) async {
          print('this is new getConversationListEvent ======>>>>${data}');
            try {
          Log.info('CONVERSATION ACK: $data');
          if (data['status'] == SocketStatus.success) {
            var arrayOfConversation = <ConversationModel>[];
            // var conversationData = data['data'];

             var futures = data['data'].map<Future<void>>((item) async {
    print('this is new profileuserisDelete: item[] ======>>>>${item['profile_user_is_delete']}');
    var newConversation = ConversationModel(
      id: item['id'],
      conversationid: item['conversation_id'],
      messagecontent: item['message_content'],
      createdAt: item['created_at'],
      createdby: item['created_by'],
      readat: item['read_at'],
      receiverid: item['receiver_id'],
      senderid: item['sender_id'],
      profileimage: item['profile_image'],
      profileuserid: item['profile_user_id'],
      fullname: item['full_name'],
      isDelete: false,
      updatedAt: item['created_at'],
      // profileuserisDelete:0
      profileuserisDelete: item['profile_user_is_delete'].toString() == "true" ? 1 : 0,
    );
    arrayOfConversation.add(newConversation);
    if(item['is_blocked'] == 1){ 
       List blockedDetails = item['blocked_details'];

      for (var blockedItem in blockedDetails) {
         var result = await dbHelper.insertBlockedUser(BlockedUserTbl(
            id: 0, 
            userId: blockedItem['blocked_user_id'], 
            blockedBy: blockedItem['blocker_user_id'], 
            isTestData: AppConfig.isTestData, 
            isDelete: 0, 
            createdAt: DateTime.now().toString()));
            
      }        
      
    }else{
      print('in am outside the loop');
    }
    await fetchAllMessage(
      sender_id: item['sender_id'],
      recipient_id: item['receiver_id'],
      istestdata: AppConfig.isTestData,
      page: 1,
      pageSize: 50,
    );
  }).toList();

  await Future.wait(futures);

             if (arrayOfConversation.isNotEmpty) {
              /*  === INSERT CONVERSATION DATA IN LOCAL DB === */
              await dbHelper.saveConversation(
                  arrayOfConversation: arrayOfConversation,);
              /*  === FETCH MESSAGES FROM THE SERVER === */
         
            }
          }
        } catch (e) {
          Log.error("While fetch initial conversation socket event");
          Log.error(e);
        }
        });

           SocketUtils.listenEvent(
        eventName: SocketPaths.previousConversations,
        onEvent: (data) async {
          var conversationId = 0;
          print('this is new previousConversations ======>>>>${data}');
            try {
        Log.info('MESSAGE ACK: $data');
        if (data['status'] == SocketStatus.success) {
          var arrayOfMessage = <MessageModel>[];
          final messageData = data['data'];          
          Log.info('MESSAGE DATA ${data['data']}');

       await data['data'].forEach((currentData) {
        conversationId = currentData['conversation_id'];
  var newMessage = MessageModel(
    id: currentData['id'],
    conversationid: currentData['conversation_id'],
    messagecontent: currentData['message_content'],
    createdat: currentData['created_at'],
    updatedat: currentData['updated_at'],
    currentstatus: int.parse(currentData['current_status']) ?? 1 ,
    istestdata: AppConfig.isTestData.toString(),
    senderid: currentData['sender_id'],
    isdelete: "0",
  );
  arrayOfMessage.add(newMessage);
});

updateConversationIsDelete(conversationId: conversationId.toString(), isDelete: int.parse(data['isUserAccountDeleted'].toString()));
          /*  === INSERT MESSAGE DATA IN LOCAL DB === */
          await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
          CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyGetNewMsgEvent,    userInfo: {
                    'isUserAccountDeleted' : data['isUserAccountDeleted'].toString(),
                  });
        }
      } catch (e) {
        Log.error("While fetch messages socket event");
        Log.error(e);
      }
        });

   var arrayOfMessage = <MessageModel>[];
             SocketUtils.listenEvent(
        eventName: SocketPaths.newMessage,
        onEvent: (data) async {
          print('this is new new_message12345798 ======>>>>${data}');
          try{
        if (data['latestMessage']['status'] == SocketStatus.success) {
          final loginUserId = GS.userData.value!.id;
          fetchInitialConversation();
          if(data['latestMessage']['is_new_conversation'] == 0){
            print('this is old new_message ======>>>>  ${data['latestMessage']['data']['conversation_id']}');
            
             var conversationObj = await ConversationsTbl(
                       id: data['latestMessage']['data']['conversation_id'], 
                       conversationId: data['latestMessage']['data']['conversation_id'], 
                       createdBy: data['latestMessage']['data']['sender_id'], 
                       receiverId: data['latestMessage']['data']['receiver_id'], 
                       senderId: data['latestMessage']['data']['sender_id'], 
                       profileUserId: data['latestMessage']['data']['sender_id'], 
                       profileImage:  data['latestMessage']['data']['profile'] ?? '',
                       fullName:  data['latestMessage']['data']['full_name'] ?? '', 
                       isDelete: 0, 
                      //  updatedAt:data['latestMessage']['data']['created_at'], 
                       updatedAt: data['latestMessage']['data']['message_created_at'] ?? '', 
                       messageContent: data['latestMessage']['data']['message_content'] ?? '',
                       newMessage:  loginUserId == data['latestMessage']['data']['sender_id'] ? 0 : 1,
                      //  profileuserisDelete:  data['latestMessage']['data']['profile_user_is_delete'] == true ? 1 : 0,
                       profileuserisDelete: 0
                       );
                  print('this is dbHelper.conversationObj ======>>>>   ${conversationObj}');     
              var newMessage = await MessageModel(
               id: data['latestMessage']['data']['message_id'],
               conversationid: data['latestMessage']['data']['conversation_id'],
              //  messagecontent: 'This is testing',
               messagecontent: data['latestMessage']['data']['message_content'],
               createdat: data['latestMessage']['data']['message_created_at'],
              //  updatedat: '',
               updatedat: data['latestMessage']['data']['message_created_at'],
               currentstatus: int.parse(data['latestMessage']['data']['message_current_status']),
               istestdata: AppConfig.isTestData.toString(),
               senderid: data['latestMessage']['data']['sender_id'],
               isdelete: "0",
             );
              print('this is dbHelper.arrayOfMessage ======>>>>   ${arrayOfMessage}');
               print('this is dbHelper.saveMessage ======>>>>   ${newMessage}');
             arrayOfMessage.add(newMessage);
            
              await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
                 if (newMessage != null) { 
                   print('this is updateConversation ======>>>>');
              await updateConversation(conversationObject:conversationObj, isNewConversion: false);        
            }
            // CustomeNotificationCenter.instance
            //           .post(NotifyNotificationName.notifyGetNewMsgEvent);
            CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyGetNewMsgEvent,
                         userInfo: {
                    'conversationId': data['latestMessage']['data']['conversation_id'],
                  });  
          }else{
               print('this is new new_message ======>>>>${data['latestMessage']['data']['getNewMessageFromConvo']['conversation_id']}');
               var conversationObj = ConversationsTbl(
                         id: data['latestMessage']['data']['conversation_id'], 
                       conversationId: data['latestMessage']['data']['conversation_id'], 
                       createdBy: data['latestMessage']['data']['sender_id'], 
                       receiverId: data['latestMessage']['data']['receiver_id'], 
                       senderId: data['latestMessage']['data']['sender_id'], 
                       profileUserId: data['latestMessage']['data']['receiver_id'], 
                       profileImage: '',
                       fullName: '', 
                       isDelete: 0, 
                      //  updatedAt:data['latestMessage']['data']['created_at'], 
                       updatedAt: data['latestMessage']['data']['updated_at'], 
                       messageContent: data['latestMessage']['data']['message_content'],
                       newMessage: loginUserId == data['latestMessage']['data']['sender_id'] ? 0 : 1,
                      //  profileuserisDelete: item['profile_user_is_delete'] == true ? 1 : 0,
                       profileuserisDelete: 0
                       );
            await updateConversation(conversationObject:conversationObj, isNewConversion: true); 
               var newMessage = MessageModel(
               id: data['latestMessage']['data']['message_id'],
               conversationid: data['latestMessage']['data']['conversation_id'],
               messagecontent: data['latestMessage']['data']['message_content'],
               createdat: data['latestMessage']['data']['message_created_at'],
              //  updatedat: '',
               updatedat: data['latestMessage']['data']['message_created_at'],
               currentstatus: int.parse(data['latestMessage']['data']['message_current_status']),
               istestdata: AppConfig.isTestData.toString(),
               senderid: data['latestMessage']['data']['sender_id'],
               isdelete: "0",
             );
             arrayOfMessage.add(newMessage);
              await dbHelper.saveMessage(arrayOfMessage: arrayOfMessage);
             CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyGetNewMsgEvent,
                         userInfo: {
                    SocketPaths.conversationIdKey: data['latestMessage']['data']['conversation_id'],
                  });        
          }
          ///////////  for message Delivered status
          print('this is for testing socket reciver id :${data['latestMessage']['data']['receiver_id']}   ');
          print('this is for testing socket sender_id  :${data['latestMessage']['data']['sender_id']}   ');
           print('this is for testing socket login user  :${GS.userData.value!.id}   ');
    // if(data['latestMessage']['data']['receiver_id'] == GS.userData.value!.id &&  GS.userData.value!.isInConversationScreen == true){
       if(data['latestMessage']['data']['receiver_id'] == GS.userData.value!.id ){
      var messageId = data['latestMessage']['data']['message_id'];
  Log.info('messageDelivered ======> ${messageId}');  
   socket.emit(
     SocketPaths.messageDelivered,
      { 
        messageId,
      // 'messageId':messageId,
       }); 

        Log.info('getRecieverOnlineStatus ======> ${data['latestMessage']['data']['message_id']}');  
var onlineStatusOfReciever =   data['latestMessage']['data']['reciepient_online_status'];
    if(onlineStatusOfReciever == true){
            socket.emit(
     SocketPaths.updateReadStatusOfMsg,
      { 
         messageId,
      // 'messageId':int.parse(messageId),
       });
      }
    }      


 
 

        }
      } catch (e) {
        Log.error("While send new message socket event");
        Log.error(e);
      }

        });


 SocketUtils.listenEvent(
        eventName: SocketPaths.messageDeliveredResult,
        onEvent: (data) async {
          print('this is new messageDeliveredResult ======>>>>${data}');         
          dbHelper.updateMessage(messageId: data['message_id'], conversationId: data['conversion_id'], currentStatus: data['message_status']); 
           CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyUpdateMessageStatus);
          Log.success('this is new 123456798');        
        });

   SocketUtils.listenEvent(
        eventName: SocketPaths.updateMsgReadStatusResult,
        onEvent: (data) async {
          print('this is new updateMsgReadStatusResult ======>>>>${data}');         
          dbHelper.updateMessage(messageId: data['message_id'], conversationId: data['conversion_id'], currentStatus: data['message_status']); 
           CustomeNotificationCenter.instance
                      .post(NotifyNotificationName.notifyUpdateMessageStatus);
          Log.success('this is new updateMsgReadStatusResult');        
        });


  

      //===== Get new message event
    // SocketUtils.listenEvent(
    //     eventName: SocketPaths.privateMessage,
    //     onEvent: (data) async {
    //       print('this is new message123 ======>>>>${data}');
    //   // try {
    //   //   Log.info('MESSAGE CALLBACK: $data');
    //   //   if (data['status'] == SocketStatus.success) {
    //   //     if (data['isNewConversion'] == true) {
    //   //       ConversationModel? conversationObject;
    //   //       final conversationData = data['data'];

    //   //       if (conversationData != null) {
    //   //         conversationObject = ConversationModel.fromJson(conversationData);
    //   //         await updateConversation(
    //   //           conversationObject: conversationObject,
    //   //           isFromNewMsgSocketEvent: false,
    //   //         );
             
    //   //       }
    //   //     } else {
    //   //       final messageData = data['data'];
    //   //       if (messageData != null) {
    //   //         final messageObject = MessageModel.fromJson(messageData);
    //   //         await updateMessage(messageData: messageObject);             
    //   //       }
    //   //     }
    //   //   }
    //   // } catch (e) {
    //   //   Log.error("While send new message socket event");
    //   //   Log.error(e);
    //   // }
    //     });

//     //===== Update message status event
//     SocketUtils.listenEvent(
//         eventName: SocketPaths.updateMessageStatusEvent,
//         onEvent: (data) async {
//           Log.info('==== ${SocketPaths.updateMessageStatusEvent} ====');
//           try {
//             Log.info('UPDATE MESSAGE LISTEN EVENT: $data');

//             if (data['status'] == SocketStatus.success) {
//               if (data['data'] != null) {
//                 var arrayOfReceipt = <ReceiptsModel>[];
//                 final receiptData = data['data'];

//                 arrayOfReceipt.addAll(List<ReceiptsModel>.from(
//                     receiptData.map((x) => ReceiptsModel.fromJson(x))));

//                 for (var i = 0; i < arrayOfReceipt.length; i++) {
//                   Log.info('IPHONE 11111111111');
//                   Log.info('READ AT : ${arrayOfReceipt[i].readAt ?? ''}');
//                   final receiptItem = ReceiptsTbl(
//                       id: arrayOfReceipt[i].id ?? 0,
//                       conversationId: arrayOfReceipt[i].conversationId ?? 0,
//                       messageId: arrayOfReceipt[i].messageId ?? 0,
//                       messageUniqueId: arrayOfReceipt[i].messageUniqueId ?? '',
//                       receiverId: arrayOfReceipt[i].receiverId ?? 0,
//                       deliveredAt: arrayOfReceipt[i].deliveredAt ?? '',
//                       readAt: arrayOfReceipt[i].readAt ?? '',
//                       isBlocked: arrayOfReceipt[i].isBlocked == true ? 1 : 0,
//                       createdAt: arrayOfReceipt[i].createdAt ?? '',
//                       updatedAt: arrayOfReceipt[i].updatedAt ?? '');
//                   await dbHelper.updateReceipts(
//                       receipts: receiptItem,
//                       msgUniqueId: arrayOfReceipt[i].messageUniqueId ?? '',
//                       receiverId: arrayOfReceipt[i].receiverId ?? 0);
//                 }
//                 CustomeNotificationCenter.instance
//                     .post(NotifyNotificationName.notifyUpdateMessageStatus);
//               }
//             }
//           } catch (e) {
//             Log.error("While listen update message socket event");
//             Log.error(e);
//           }
//         });

//     //===== New group create event
//     SocketUtils.listenEvent(
//         eventName: SocketPaths.newGroupCreated,
//         onEvent: (data) async {
//           try {
//             Log.info('NEW GROUP CREATE LISTEN EVENT: $data');
//             if (data['status'] == SocketStatus.success) {
//               ConversationModel? conversationObject;
//               if (data['data'] != null) {
//                 final conversationData = data['data'];
//                 Log.info('GROUP DATA: $conversationData');

//                 if (conversationData != null) {
//                   conversationObject =
//                       ConversationModel.fromJson(conversationData);
//                   await dbHelper.saveConversation(
//                     arrayOfConversation: [conversationObject],
//                     isCreateGroup: true,
//                   );

//                   CustomeNotificationCenter.instance
//                       .post(NotifyNotificationName.notifyGetNewMsgEvent);

//                   CustomeNotificationCenter.instance.post(
//                       NotifyNotificationName.notifyCreateNewGroup,
//                       userInfo: {'conversationId': conversationObject.id});
//                 }
//               }
//             }
//           } catch (e) {
//             Log.error("While ReceiveMessage socket event");
//             Log.error(e);
//           }
//         });

//     //===== New follow request event
//     SocketUtils.listenEvent(
//       eventName: SocketPaths.followAckEvent,
//       onEvent: (data) async {
//         // print(data);
//         try {
//           Log.info('FOLLOW CALLBACK EVENT: $data');
//           if (data['status'] == SocketStatus.success) {
//             await SocketUtils.getUnreadNotificationCount();
//             CustomeNotificationCenter.instance
//                 .post(NotifyNotificationName.notifyNewFollowRequest);
//           }
//         } catch (e) {
//           Log.error("While ReceiveMessage socket event");
//           Log.error(e);
//         }
//       },
//     );

//     //===== Request accepted event
//     SocketUtils.listenEvent(
//       eventName: SocketPaths.followRrequestAcceptedEvent,
//       onEvent: (ackData) async {
//         // print(data);
//         try {
//           Log.info('REQUEST ACCEPT REJECT CALLBACK EVENT: $ackData');
//           if (ackData['status'] == SocketStatus.success) {
//             final data = ackData['data'];
//             await SocketUtils.getUnreadNotificationCount();
//             NotificationCenter().notify(
//                 NotifyNotificationName.notifyRequestAccepted,
//                 data: data);
//           }
//         } catch (e) {
//           Log.error("While ReceiveMessage socket event");
//           Log.error(e);
//         }
//       },
//     );
  }

// //=============== Other Method ===============//
//   static Future<void> updateConversation(
//       {required ConversationModel conversationObject,
//       required bool isFromNewMsgSocketEvent}) async {
//     final conversationItem = ConversationsTbl(
//       id: conversationObject.id ?? 0,
//       conversationUniqueId: conversationObject.conversationUniqueId ?? '',
//       name: conversationObject.name ?? '',
//       photo: conversationObject.photo ?? '',
//       description: conversationObject.description ?? '',
//       isGroup: conversationObject.isGroup ?? 0,
//       maxNumber: conversationObject.maxMember ?? 0,
//       isMemberAccess: conversationObject.isMemberAccess ?? 0,
//       senderId: conversationObject.senderId ?? 0,
//       receiverId: conversationObject.receiverId ?? 0,
//       createdBy: conversationObject.createdBy ?? 0,
//       addedBy: conversationObject.addedBy ?? 0,
//       updatedBy: conversationObject.updatedBy ?? 0,
//       updatedAt: conversationObject.updatedAt ?? '',
//       isDelete: conversationObject.isDelete == true ? 1 : 0,
//     );
//     Log.info('CONVERSATION SEND DATA: $conversationObject');
//     await dbHelper.updateConversation(
//       conversations: conversationItem,
//       uniqueId: conversationObject.conversationUniqueId.toString(),
//     );
//     if (conversationObject.groupParticipants != null) {
//       await updateParticipant(conversationObject: conversationObject);
//     }
//     if (conversationObject.message != null) {
//       if (isFromNewMsgSocketEvent) {
//         await dbHelper.saveMessage(arrayOfMessage: conversationObject.message!);
//       } else {
//         await updateMessage(messageData: conversationObject.message![0]);
//       }
//     }
//   }

//   static Future<void> updateParticipant(
//       {required ConversationModel conversationObject}) async {
//     for (var i = 0; i < conversationObject.groupParticipants!.length; i++) {
//       final participantData = conversationObject.groupParticipants![i];
//       Log.info(
//           'UPDATE PARTICIPANT USERNAME: ${conversationObject.groupParticipants?[i].conversionId}');
//       final participantItem = ParticipantsTbl(
//         id: participantData.id ?? 0,
//         conversationId: participantData.conversionId ?? 0,
//         conversationUniqueId: participantData.conversationUniqueId ?? '',
//         isLeft: participantData.isLeft == true ? 1 : 0,
//         isLeftBy: participantData.isLeftBy,
//         isAdmin: participantData.isAdmin == true ? 1 : 0,
//         memberId: participantData.memberId ?? 0,
//         loadMessageFromId: participantData.loadMessageFromId ?? 0,
//         isMute: participantData.isMute == true ? 1 : 0,
//         isBlocked: participantData.isBlocked == true ? 1 : 0,
//         addedBy: participantData.addedBy ?? 0,
//         createdAt: participantData.createdAt ?? '',
//         updatedAt: participantData.updatedAt ?? '',
//       );
//       await dbHelper.updateParticipant(
//           participant: participantItem,
//           memberId: participantData.memberId ?? 0,
//           conversationUniqueId: participantData.conversationUniqueId ?? '');

//       final userItem = UserTbl(
//         memberId: participantData.memberId ?? 0,
//         firstname: participantData.firstname ?? '',
//         lastname: participantData.lastname ?? '',
//         username: participantData.username ?? '',
//         email: participantData.email ?? '',
//         profile: participantData.profile ?? '',
//       );
//       await dbHelper.updateUser(
//           user: userItem, memberId: participantData.memberId ?? 0);
//     }
//   }

//   static Future<void> updateMessage({
//     required MessageModel messageData,
//   }) async {
//     final messageItem = MessagesTbl(
//       id: messageData.id ?? 0,
//       messageUniqueId: messageData.messageUniqueId ?? '',
//       conversationId: messageData.conversationId ?? 0,
//       parentId: messageData.parentId ?? 0,
//       senderId: messageData.senderId ?? 0,
//       content: messageData.content ?? '',
//       isForwarded: messageData.isForwarded ?? 0,
//       type: messageData.type ?? '',
//       isTestdata: messageData.isTestdata == true ? 1 : 0,
//       isDelete: messageData.isDelete == true ? 1 : 0,
//       createdAt: messageData.createdAt ?? '',
//       updatedAt: messageData.updatedAt ?? '',
//     );

//     await dbHelper.updateMessage(
//         message: messageItem, uniqueId: messageData.messageUniqueId ?? '');

//     if (messageData.receipts != null) {
//       for (var i = 0; i < messageData.receipts!.length; i++) {
//         Log.info('READ AT TIME: ${messageData.receipts?[i].readAt ?? ''}');
//         final receiptItem = ReceiptsTbl(
//             id: messageData.receipts?[i].id ?? 0,
//             conversationId: messageData.conversationId ?? 0,
//             messageId: messageData.id ?? 0,
//             messageUniqueId: messageData.messageUniqueId ?? '',
//             receiverId: messageData.receipts?[i].receiverId ?? 0,
//             deliveredAt: messageData.receipts?[i].deliveredAt ?? '',
//             readAt: messageData.receipts?[i].readAt ?? '',
//             isBlocked: messageData.receipts?[i].isBlocked == true ? 1 : 0,
//             createdAt: messageData.receipts?[i].createdAt ?? '',
//             updatedAt: messageData.receipts?[i].updatedAt ?? '');
//         await dbHelper.updateReceipts(
//             receipts: receiptItem,
//             msgUniqueId: messageData.messageUniqueId ?? '',
//             receiverId: messageData.receipts?[i].receiverId ?? 0);
//       }
//     }
//   }

  // Socket api - typingStart
  static Future<void> sendUserStatus({
      required int userId,
     required int onlineStatus,
  }) async {  
    var userIdRes = userId;
    var onlineStatusRes = onlineStatus;
    var isTestDataRes = AppConfig.isTestData;

      final emitData = {
    'userId': userId, 
    'onlineStatus':onlineStatusRes,
    'isTestdata':isTestDataRes,
    };
  Log.info('onlineStatus $emitData');
  socket.emit(SocketPaths.onlineStatus,emitData);    
  socket.emit(SocketPaths.onlineStatus,emitData);    
  }


}
