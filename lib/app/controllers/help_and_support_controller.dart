
import 'dart:io';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpAndSupportController extends GetxController {
  static const screenImage = AppImages.helpillustrationimage; 
  static const screenTitle = "Hello,\nHow can we assist you today?";
  static const screenBody = "It seems you are encountering issues or need help with the usage of app. Please feel free to reach out us via email, or using chat option available as TeamBalance Support.";

  var contact_email = GS.helpAndSupport.value?.contactemail!;
  var contact_phone_number = GS.helpAndSupport.value?.contactphonenumber!;
  var subject = 'Assistance Needed';
  int adminUserId = 4;
  var userModel = UserModel();
  var loggedInUserId = GS.userData.value == null ? 0: GS.userData.value!.id!;
  RxBool isLoading = false.obs;
  

 void helpAndSupportCall() {
     
  }

  // void helpAndSupportEmail() {
  //    launchEmail();
  // }

// Future launchEmail() async{
// final url = 'mailto:rrn@narola.email?subject=${Uri.encodeFull(subject)}';
// if(await canLaunchUrlString(url)){
// await launchUrlString(url);
// }
// }

//////// for email
Future<void> sendEmail(String emailAddress) async {
  if(Platform.isAndroid){
      final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
    queryParameters: {
      'subject': '${subject}', 
      'body': '', 
    },
  );

  try {
    await launchUrl(emailLaunchUri);
  } catch (e) {
    print('Could not launch email client: $e');
  }
  }else{
    final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
    query: 'subject=${subject}&body=',
  );
  
  if (await canLaunchUrlString(emailLaunchUri.toString())) {
    await launchUrlString(emailLaunchUri.toString());
  } else {
    throw 'Could not launch $emailLaunchUri';
  }
  }  
}

//////////// for call
Future<void> makePhoneCall(String phoneNumber) async {
  final Uri phoneCallUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  
  if (await canLaunch(phoneCallUri.toString())) {
    await launch(phoneCallUri.toString());
  } else {
    throw 'Could not launch $phoneCallUri';
  }
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

//////////// for chat
 Future<void> chatWithAdmin() async {
  isLoading.value = true;
  await getOtherUserProfileApi(userid: adminUserId);
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
  isLoading.value = false;
          Get.off(() => ChatMessageScreen(
        // Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        ),arguments: {
          "conversationData":conversationData
  });
    // Get.to(() =>  HomeScreen(isFromChatScreen: true,isFromContinueAsGuest: false,));
  }
// }  





  // Future<void> getHelpAndSupportApi({bool handleErrors = true}) async {
  //   await GetStorage.init();
  //   final apiHelper = ApiHelper(
  //     serviceName: "help_and_support",
  //     endPoint: ApiPaths.help_and_support,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //   final result = await apiHelper.post(body: {}, isFormData: false);
  //   print("result: $result");
  //   await result.fold((l) {
  //     // if (l['msg'] == "Invalid token") {
  //     //   clearDataAndNavigateToLogin();
  //     // }
  //   }, (r) async {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       final data = r['date'];
  //       if (status == ApiStatus.success) {
  //         contact_email = data.contact_email;
  //         contact_phone_number = data.contact_phone_number;
  //         print('Helps api res');
  //         print(contact_email);
  //         print(contact_phone_number);
  //       } else {
  //          showTopFlashMessage(ToastType.success, r['message'],);
  //       }
  //       print("message: $message");
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  // }

}
