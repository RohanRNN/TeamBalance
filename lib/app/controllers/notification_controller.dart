import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/settings/help_and_support_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/models/notification_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/main.dart';


class NotificationController extends GetxController {
 static const isListEmpty = true;
     var refreshKey = GlobalKey<RefreshIndicatorState>();
       late ScrollController scrollController;
   int currPage = 1;
  var userModel = UserModel();
  var loggedInUserId = GS.userData.value == null ? 0: GS.userData.value!.id!;
  RxBool isLoadingScreen = false.obs;

  void saveAndGoHome() {
   Get.offAll(() =>  HomeScreen(isFromContinueAsGuest:false,isFromChatScreen: false,indexForScreen: 0,));
  }

   void save() {
   Get.back();
  }
  RxBool isLoadingMore= false.obs;

   RxBool isLoading = false.obs;
   RxBool hasMoreData=true.obs;
  var arrayOfNotification = <NotificationModel>[].obs;
  Future<void> getAllNotification({
    bool fromRefresh = false,
    int page = 1,
    int pageSize = 15,
  }) async {
    if (fromRefresh) {
      isLoading.value = false;
    } else {
      isLoading.value = true;
    }

    final apiHelper = ApiHelper(
      serviceName: "get_notifications" ,
      endPoint: ApiPaths.get_notifications+ ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    if(page == 1){
      arrayOfNotification.clear();
    }
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {
      Log.info("Left:===> $l");
      final status = l['status'];
      if(status==0){
        hasMoreData.value=false;
      }

    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1) {
            arrayOfNotification.clear();
          }
          final data = r['data']['notificationData'];

          arrayOfNotification.addAll(
              List<NotificationModel>.from(data.map((x) => NotificationModel.fromJson(x))));
          isLoading.value = false;
          GS.userData.value!.isnewnotification = false;
          Log.info("Notification Model : ${arrayOfNotification}");

          if(data.length < 15){
            Log.error("arrayOfNotification.length < data.length ==> True");
            hasMoreData.value=false;
          }else{
         
            Log.error("arrayOfNotification.length < data.length (${data.length})==> False");
            hasMoreData.value=true;
          }

        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    isLoading.value = true;
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
      currPage = 1;
      await getAllNotification(
        fromRefresh: false,
        page: currPage,
        pageSize: 15,
      );
      // isLoading.value = false;
    
  }

  void onLoadMore() async {
    if (isLoadingMore.value) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isLoadingMore.value = true;
        currPage = currPage + 1;
        await getAllNotification(
          fromRefresh: true,
          page: currPage,
          pageSize: 15,
        ).whenComplete((){
isLoadingMore.value = false;
        });
      
      
    }
  }

 Future<void> chatWithAdmin({
  required int userId,
  required int messageId
 }) async {
  isLoadingScreen.value = true;
  await getOtherUserProfileApi(userid: userId);
     var conversationResponse =  await dbHelper.getConversationBySenderOrReciver(loginUserId:GS.userData.value!.id!,oppositUserId:userModel.id!,conversationIdRes: 0);
      if(conversationResponse == 0){
             conversationResponse =  await dbHelper.getConversationBySenderOrReciver(loginUserId:userModel.id!,oppositUserId:GS.userData.value!.id!,conversationIdRes: 0);
      }
    print('conversationResponse111    sended === ${GS.userData.value!.id!}   revicer :  ${userModel.id!}=====>${conversationResponse}');
      var conversationData = ConversationModel(
                id:conversationResponse,
                conversationid: conversationResponse,
                messagecontent: '',
                createdAt: '',
                createdby: loggedInUserId,
                senderid: loggedInUserId,
                receiverid: userModel.id,
                readat: false,
                profileuserid: userModel.id,
                profileimage: userModel.profileimage,
                fullname: userModel.fullname,
                updatedAt: '',
                isDelete: false,
                profileuserisDelete: 0,
  );
          var conversationId =  await dbHelper.getConversationBySenderOrReciver(loginUserId:GS.userData.value!.id!,oppositUserId:userModel.id!,conversationIdRes: 0);
  isLoadingScreen.value = false;
          Get.off(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        messageIdFromNotification: messageId,
        ),arguments: {
          "conversationData":conversationData
  });
  }

  Future<void> getOtherUserProfileApi({bool handleErrors = true, int userid = 0}) async {
    print('this is testinf    ======>');
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "get_post_user_profile",
      endPoint: ApiPaths.get_post_user_profile + ("user_id=$userid"),
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );
    final result = await apiHelper.get();

    Log.info("result: $result");
    await result.fold((l) {}, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        final data = r['data']['return_data'];
        print('this is new testign from getOtherUserProfileApi ==========>');  
        print(r['status']);        
        if (status == ApiStatus.success) {
           userModel = UserModel.fromJson(data);  
           print(userModel) ;
          // Get.to(() =>  OtpVerificationScreen(isFromProfileScreen: false,isFromSignUpScreen: true,));
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  } 

// navigation to the notification screen for push notification
   Future<void> goToScreen({
    required RemoteMessage message
  }) async {
    print('noti_type --->>>>.  ${message.data['noti_type']}');
    print('noti_data --->>>>.  ${message.data['noti_data']}');
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
      Get.off(
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
      await Future.delayed(Duration(milliseconds: 500));
      Map<String, dynamic> notiData = jsonDecode(message.data['noti_data']);
      if(notiData['is_new_conversation'] == 1){
      int senderId = notiData['data']['getNewMessageFromConvo']['sender_id'];
      int messageId = notiData['data']['getNewMessageFromConvo']['id'];
      chatWithAdmin(userId: senderId, messageId :messageId);
      }else{
      int senderId = notiData['data']['sender_id'];
      int messageId = notiData['data']['message_id'];
      chatWithAdmin(userId: senderId, messageId :messageId);
      }
      // int senderId = notiData['data']['sender_id'];
      // int messageId = notiData['data']['message_id'];
      // chatWithAdmin(userId: senderId, messageId :messageId);

    }  
  }


// navigation to the notification screen
  Future<void> goToScreenFromList({
    required NotificationModel notificationModel
  }) async {
    isLoadingScreen.value = true;
    print('goToScreenFromList --->>.  ${notificationModel.notificationtype}');
    if(notificationModel.notificationtype == AppConstants.notiTypePostlike )
    {
      await getPostDetails(
        postId: notificationModel.postId!,
        isFromCommentScreen: false
      );
    } else if(notificationModel.notificationtype == AppConstants.notiTypePostcomment)
    {
      await getPostDetails(
        postId: notificationModel.postId!,
        commentId: notificationModel.commentId!,
        isFromCommentScreen: true
      );
    }
    else if(notificationModel.notificationtype == AppConstants.notiTypeNewmessage)
    {
      await getMessageDetails(
        messageId: notificationModel.messageId!,
        conversationId: notificationModel.conversationId!
      );
    }  
  }


// API for post details
  Future<void> getPostDetails({
    int postId = 0,
    int commentId = 0,
    bool isFromCommentScreen = false
  }) async {
    final apiHelper = ApiHelper(
      serviceName: "get_post_details" ,
      endPoint: ApiPaths.get_post_details+ "post_id=${postId}",
      showErrorDialog: false,
    );

    final result = await apiHelper.get();
    print("result: $result");
     print('getPostDetails --->>');
    result.fold((l) {
      Log.info("Left:===> $l");
      final status = l['status'];
      final message = l['message'];
      showTopFlashMessage(ToastType.failure, message.toString());
      isLoadingScreen.value = false;
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {         
          final data = r['data'];
           print('ths ihs isi his--->>>>> 123');
           PostModel postModel = PostModel.fromJson(data);
           print('ths ihs isi his--->>>>>');
           if(isFromCommentScreen){
            //  isLoadingScreen.value = false;
             await getCommentDetails(
               commentId: commentId!,
               postModel:postModel
             );
           }else{
            print('ths ihs isi his--->>>>>');
              //  Get.to(
      Get.off(
            () => CommentScreen(
                  postModelData: postModel,
                ),
            arguments: {
                "postId": postModel!.id!,
                "index": 1,
                "postModel": postModel,
              });
           }  
           isLoadingScreen.value = false;    
          } else {
            isLoadingScreen.value = false;
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
        isLoadingScreen.value = false;
      }
    });
    
  }
  


// API for comment details
  Future<void> getCommentDetails({
    int commentId = 0,
    PostModel? postModel,
  }) async {
    final apiHelper = ApiHelper(
      serviceName: "get_comment_details" ,
      endPoint: ApiPaths.get_comment_details+ "comment_id=${commentId}",
      showErrorDialog: false,
    );

    final result = await apiHelper.get();
    print("result: $result");
    print('getCommentDetails --->>');
    result.fold((l) {
      Log.info("Left:===> $l");
      final status = l['status'];
      final message = l['message'];
      isLoadingScreen.value = false;
      showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {         
          final data = r['data'];
      CommentModel commentModel = CommentModel.fromJson(data);
      isLoadingScreen.value = false;
      //  Get.to(
      Get.off(
            () => CommentScreen(
                  postModelData: postModel!,
                ),
            arguments: {
                "postId": postModel!.id!,
                "index": 1,
                "postModel": postModel,
                "postCommentModel": commentModel,
              });
          } else {
            isLoadingScreen.value = false;
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        isLoadingScreen.value = false;
        print('\n******** $e ********\n$stacktrace');
      }
    });
  }


// API for Message details
  Future<void> getMessageDetails({
    int messageId = 0, int conversationId = 0
  }) async {
    final apiHelper = ApiHelper(
      serviceName: "get_message_details" ,
      endPoint: ApiPaths.get_message_details+ "conversation_id=${conversationId}&message_id=${messageId}",
      showErrorDialog: false,
    );

    final result = await apiHelper.get();
    print("result: $result");
    print('getMessageDetails --->>');
    result.fold((l) {
      Log.info("Left:===> $l");
      final status = l['status'];
      final message = l['message'];
      isLoadingScreen.value = false;
      showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {         
          // final data = r['data'];

        Map<String, dynamic> data = r['data']; 
        int senderId = data['sender_id'];
        int messageId = data['id'];

      chatWithAdmin(userId: senderId, messageId :messageId);
          } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    
  }

}
  