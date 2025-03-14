
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/app/views/chats/chat_screen.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/user_model.dart';


class OtherUserProfileController extends GetxController {

  var isProfileAPICalled = true;
  var isGuestLogin = false;
   var userModel = UserModel();
   var loggedInUserId = GS.userData.value == null ? 0: GS.userData.value!.id!;
   final List<String> gender = [
  '---',
  'Male',
  'Female',
  ];

 var isFromChatScreen = false;

   Future<void> chatWithUserScreen() async {
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

          Get.off(() => ChatMessageScreen(
        // Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        ),arguments: {
          "conversationData":conversationData
  });
    // Get.to(() =>  HomeScreen(isFromChatScreen: true,isFromContinueAsGuest: false,));
  }
  void loadUserData(int userId) {
  getOtherUserProfileApi(userid: userId);
}
   void blockUserClicked(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.blockmodal,
            title: ConstantString.blockUserMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () {
              if(isFromChatScreen){
                print('this is is cliecker');
                Get.back(result: userId);
                Get.back(result: userId);
              }else{
                postblockUserApi(userId: userId);  
              }
                           
            },
            option1: ConstantString.noText.toUpperCase(),
            option2: ConstantString.yesText.toUpperCase());
      },
    );
  }

  //Post report API
  Future<void> postblockUserApi(
      {bool handleErrors = true, String userId = "0"}) async {
    // update([GetBuilderIds.likePost]);
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.block_user,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "blocked_user_id": userId,
    }, isFormData: true);
    Log.info("result: $result");
    await result.fold((l) {
       final status = l['status'];
      final message = l['message'];
      showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {                 
            showTopFlashMessage(ToastType.success, ConstantString.blockUserApiResMsg);
              //  Get.back(result: userId);
               Get.back(result: userId);
                Get.back(result: userId); 
          //  Get.offAll(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen: false,indexForScreen: 0,));
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
            Get.back();
        }
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }




       RxBool isLoading = false.obs;
  Future<void> getOtherUserProfileApi({bool handleErrors = true, int userid = 0}) async {
    print('this is testinf    ======>');
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "get_post_user_profile",
      endPoint: ApiPaths.get_post_user_profile + ("user_id=$userid"),
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.get();

    Log.info("result: $result");
    await result.fold((l) {
      final status = l['status'];
      final message = l['message'];
      showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
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
        isLoading.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    isLoading.value = false;
  } 

}
