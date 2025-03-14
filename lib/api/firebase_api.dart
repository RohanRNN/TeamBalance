import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add shared_preferences
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/settings/notification_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/main.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {  
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
    print('handleBackgroundMessage ========>>>>>>>>>');
    // Save notification data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_title', message.notification?.title ?? '');
    await prefs.setString('notification_body', message.notification?.body ?? '');
    await prefs.setBool('has_notification', true);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotifications(message);
      }
    });
  }

  Future<void> initLocalNotifications(BuildContext context, RemoteMessage message) async {
    print('message ---->>>  ${message.toString()}');
    print('message.data ---->>>  ${message.data.toString()}');
    var androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(context, response, message);
      }
    );
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    try {
    final fcmToken = await _firebaseMessaging.getToken();
    await GSAPIHeaders.writeDeviceToken(fcmToken!);
    print('FCM token=====>>>>>>${fcmToken}');    
} catch (e) {
  print('Error fetching FCM token: $e');
}
    // final fcmToken = await _firebaseMessaging.getToken();
    // await GSAPIHeaders.writeDeviceToken(fcmToken!);
    // print('FCM token=====>>>>>>${fcmToken}');       
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) { 
      if (kDebugMode) {
        GS.userData.value!.isnewnotification = true;
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }      
      showNotifications(message);
    });

    // Check for notification data when app resumes
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
       print('RemoteMessage message ----->>>  ${message.messageType}');
        // handleNotificationNavigation(message);
       UserModel? user = await GS.readUserData(); 
       if (await GS.readRememberMe() == true && user != null) {
          if (message != null) {   
          if(message.data['noti_type'] == AppConstants.notiTypePostlike )
    { 
      await Future.delayed(Duration(seconds: 2));
      PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
      //  Get.to(
      Get.to(
            () => CommentScreen(
                  postModelData: postModel,
                ),
            arguments: {
                "postId": postModel.id,
                "index": 1,
                "postModel": postModel,
              });
    } else if(message.data['noti_type'] == AppConstants.notiTypePostcomment)
    {
      await Future.delayed(Duration(seconds: 2));
      PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
      CommentModel commentModel = CommentModel.fromJson(jsonDecode(message.data['noti_comment_data'])[0]);
      //  Get.to(
      Get.to(
            () => CommentScreen(
                  postModelData: postModel,
                ),
            arguments: {
                "postId": postModel.id,
                "index": 1,
                "postModel": postModel,
                "postCommentModel": commentModel,
              });
    }
    else if(message.data['noti_type'] == AppConstants.notiTypeNewmessage)
    {
      await Future.delayed(Duration(seconds: 2));
      Map<String, dynamic> notiData = jsonDecode(message.data['noti_data']);
      if(notiData['is_new_conversation'] == 1){
      int senderId = notiData['data']['getNewMessageFromConvo']['sender_id'];
      int messageId = notiData['data']['getNewMessageFromConvo']['id'];
      int conversationId = notiData['data']['getNewMessageFromConvo']['conversation_id'];
      var conversationData =  ConversationModel(
            id: notiData['data']['getNewMessageFromConvo']['conversation_id'],
            createdby: notiData['data']['getNewMessageFromConvo']['sender_id'],
            receiverid: notiData['data']['getNewMessageFromConvo']['receiver_id'],
            conversationid: notiData['data']['getNewMessageFromConvo']['conversation_id'],
            senderid: notiData['data']['getNewMessageFromConvo']['sender_id'],
            messagecontent: notiData['data']['getNewMessageFromConvo']['message_content'],
            readat: true,
            profileuserid: notiData['data']['getNewMessageFromConvo']['sender_id'],
            fullname:notiData['data']['getNewMessageFromConvo']['full_name'],
            profileimage: notiData['data']['getNewMessageFromConvo']['profile'],
            createdAt:notiData['data']['getNewMessageFromConvo']['message_created_at'],
            isDelete: false,
          );
      Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        messageIdFromNotification: messageId,
        ),arguments: {
          "conversationData":conversationData
  });
      }else{
      int senderId = notiData['data']['sender_id'];
      int messageId = notiData['data']['message_id'];
      int conversationId = notiData['data']['conversation_id'];
      var conversationData =  ConversationModel(
            id: notiData['data']['conversation_id'],
            createdby: notiData['data']['sender_id'],
            receiverid: notiData['data']['receiver_id'],
            conversationid: notiData['data']['conversation_id'],
            senderid: notiData['data']['sender_id'],
            messagecontent: notiData['data']['message_content'],
            readat: true,
            profileuserid: notiData['data']['sender_id'],
            fullname:notiData['data']['full_name'],
            profileimage: notiData['data']['profile'],
            createdAt:notiData['data']['message_created_at'],
            isDelete: false,
          );
      Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        messageIdFromNotification: messageId,
        ),arguments: {
          "conversationData": conversationData
  });
      }
      // int senderId = notiData['data']['sender_id'];
      // int messageId = notiData['data']['message_id'];
      // chatWithAdmin(userId: senderId, messageId :messageId);

    }  
  }
        // Get.to(() => HomeScreen(
        //     isFromContinueAsGuest: false,
        //     isFromChatScreen: false,
        //     indexForScreen: 0,
        //     message: message,
        //   ));
        // Get.to(() =>  NotificationScreen(
        //   message: message,
        // ));
       }else{
        Get.to(() => const LoginScreen());
       }
          
              });

//         // Check for notification data when app is killed
// FirebaseMessaging.instance.getInitialMessage().then((message) async {
//   await Future.delayed(Duration(seconds: 1));
//   if (message != null) {   
//       handleNotificationNavigation(message);
//   }
// });
            }

  Future<void> showNotifications(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      'TeamBalance',
      importance: Importance.max
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'TeamBalance Local Notification',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        1, 
        message.notification!.title.toString(), 
        message.notification!.body.toString(), 
        notificationDetails,
        payload: 'notification_screen' // Optional payload to pass additional data
      );
    });
  }

  // void _handleNotificationTap(BuildContext context, NotificationResponse response) {
  //   print('NotificationResponse response ----->>>  123 ${response.payload.toString()}');
  //  Get.to(() => const NotificationScreen());
   
  // }

void _handleNotificationTap(BuildContext context, NotificationResponse response, RemoteMessage message) {
    print('NotificationResponse response ----->>> $response');
    print('NotificationResponse message ----->>> $message');
    // Get.to(() => HomeScreen(
    //         isFromContinueAsGuest: false,
    //         isFromChatScreen: false,
    //         indexForScreen: 0,
    //         message: message,
    //       ));
      Get.to(() =>  NotificationScreen(
        message: message,
      ));   
}

  /// Handles navigation of notification
  Future<void> handleNotificationNavigation(RemoteMessage message) async {
    print("Navigating to NotificationScreen...");    
    UserModel? user = await GS.readUserData(); 
    if (await GS.readRememberMe() == true && user != null) {
      // Get.to(() => HomeScreen(
      //       isFromContinueAsGuest: false,
      //       isFromChatScreen: false,
      //       indexForScreen: 0,
      //       message: message,
      //     ));
      Get.to(() => NotificationScreen(
        message: message,
      ));
    } else {
      Get.to(() => const LoginScreen());
    }
  }

////////////. code for testing
  // Future<void> handleNotificationNavigation(RemoteMessage message) async {
  //   print("Navigating to NotificationScreen...");    
  //   UserModel? user = await GS.readUserData(); 
  //   if (await GS.readRememberMe() == true && user != null) {
  //       print('noti_type --->>>>.  ${message.data['noti_type']}');
  //   print('noti_data --->>>>.  ${message.data['noti_data']}');
  //   if(message.data['noti_type'] == AppConstants.notiTypePostlike )
  //   {
  //     PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
  //     //  Get.to(
  //     Get.off(
  //           () => CommentScreen(
  //                 postModelData: postModel,
  //               ),
  //           arguments: {
  //               "postId": postModel.id,
  //               "index": 1,
  //               "postModel": postModel,
  //             });
  //   } else if(message.data['noti_type'] == AppConstants.notiTypePostcomment)
  //   {
  //     PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
  //     CommentModel commentModel = CommentModel.fromJson(jsonDecode(message.data['noti_comment_data'])[0]);
  //     //  Get.to(
  //     Get.off(
  //           () => CommentScreen(
  //                 postModelData: postModel,
  //               ),
  //           arguments: {
  //               "postId": postModel.id,
  //               "index": 1,
  //               "postModel": postModel,
  //               "postCommentModel": commentModel,
  //             });
  //   }
  //   else if(message.data['noti_type'] == AppConstants.notiTypeNewmessage)
  //   {
      
  //     Map<String, dynamic> notiData = jsonDecode(message.data['noti_data']);
  //     if(notiData['is_new_conversation'] == 1){
  //     int senderId = notiData['data']['getNewMessageFromConvo']['sender_id'];
  //     int messageId = notiData['data']['getNewMessageFromConvo']['id'];
  //     chatWithAdmin(userId: senderId, messageId :messageId);
  //     }else{
  //     int senderId = notiData['data']['sender_id'];
  //     int messageId = notiData['data']['message_id'];
  //     chatWithAdmin(userId: senderId, messageId :messageId);
  //     }
  //     // int senderId = notiData['data']['sender_id'];
  //     // int messageId = notiData['data']['message_id'];
  //     // chatWithAdmin(userId: senderId, messageId :messageId);

  //   } 
  //   } else {
  //     Get.to(() => const LoginScreen());
  //   }
  // }
// var userModel = UserModel();
//  Future<void> chatWithAdmin({
//   required int userId,
//   required int messageId
//  }) async {
//   var loggedInUserId = GS.userData.value == null ? 0: GS.userData.value!.id!;
//   await getOtherUserProfileApi(userid: userId);
//      var conversationResponse =  await dbHelper.getConversationBySenderOrReciver(loginUserId:GS.userData.value!.id!,oppositUserId:userModel.id!,conversationIdRes: 0);
//       if(conversationResponse == 0){
//              conversationResponse =  await dbHelper.getConversationBySenderOrReciver(loginUserId:userModel.id!,oppositUserId:GS.userData.value!.id!,conversationIdRes: 0);
//       }
//     print('conversationResponse111    sended === ${GS.userData.value!.id!}   revicer :  ${userModel.id!}=====>${conversationResponse}');
//       var conversationData = ConversationModel(
//                 id:conversationResponse,
//                 conversationid: conversationResponse,
//                 messagecontent: '',
//                 createdAt: '',
//                 createdby: loggedInUserId,
//                 senderid: loggedInUserId,
//                 receiverid: userModel.id,
//                 readat: false,
//                 profileuserid: userModel.id,
//                 profileimage: userModel.profileimage,
//                 fullname: userModel.fullname,
//                 updatedAt: '',
//                 isDelete: false,
//                 profileuserisDelete: 0,
//   );
//           var conversationId =  await dbHelper.getConversationBySenderOrReciver(loginUserId:GS.userData.value!.id!,oppositUserId:userModel.id!,conversationIdRes: 0);
  
//           Get.off(() => ChatMessageScreen(
//           isFromConversationScreen: true, 
//         conversationId: conversationId,
//         messageIdFromNotification: messageId,
//         ),arguments: {
//           "conversationData":conversationData
//   });
//   }

//   Future<void> getOtherUserProfileApi({bool handleErrors = true, int userid = 0}) async {
//     print('this is testinf    ======>');
//     await GetStorage.init();
//     final apiHelper = ApiHelper(
//       serviceName: "get_post_user_profile",
//       endPoint: ApiPaths.get_post_user_profile + ("user_id=$userid"),
//       showErrorDialog: handleErrors,
//       showTransparentOverlay: true,
//     );
//     final result = await apiHelper.get();

//     Log.info("result: $result");
//     await result.fold((l) {}, (r) async {
//       try {
//         final status = r['status'];
//         final message = r['message'];
//         final data = r['data']['return_data'];
//         print('this is new testign from getOtherUserProfileApi ==========>');  
//         print(r['status']);        
//         if (status == ApiStatus.success) {
//            userModel = UserModel.fromJson(data);  
//            print(userModel) ;
//           // Get.to(() =>  OtpVerificationScreen(isFromProfileScreen: false,isFromSignUpScreen: true,));
//         } else {
//           showTopFlashMessage(ToastType.failure, message.toString());
//         }
//         return;
//       } catch (e, stacktrace) {
//         Log.error('\n******** $e ********\n$stacktrace');
//       }
//     });
//   } 
}
