import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/app/views/settings/post/create_post_screen.dart';
import 'package:team_balance/app/views/settings/post/create_text_post_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class HomeController extends GetxController {
  static const imageScale = 2.6;
  var residenceModel = ResidenceModel();
  final currentIndex = 0.obs;
  var userModel = UserModel();
  var loggedInUserId = GS.userData.value == null ? 0: GS.userData.value!.id!;
  RxBool isLoadingScreen = false.obs;

  void changePage(int index) {
    if (index == 2) {
      // _showAlertDialog(context);
    } else {
      currentIndex.value = index;
    }
    print(currentIndex.value);
  }

  Future<void> createPostClicked(BuildContext context) async {
    var deviceSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          alignment: Alignment.bottomCenter,
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstantString.continueWith,
                  style: TextStyle(
                      fontSize: 20, fontFamily: FontFamilyName.montserrat),
                ),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(
                      AppImages.select,
                      scale: imageScale,
                    ))
              ],
            ),
          ),
          insetPadding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SizedBox(
            height: 180,
            width: deviceSize.width,
            // height: Platform.isAndroid?deviceSize.height*.25: deviceSize.height*.22,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Get.back();
                          bool isPostCreated =
                              await Get.to(() => const CreatePostScreen());
                          if (isPostCreated) {
                            print(
                                'this is isPostCreated =====>>>>  ${isPostCreated}');
                            changePage(1);
                          }
                        },
                        child: Image.asset(
                          AppImages.photovideoicon,
                          scale: imageScale,
                        ),
                      ),
                      SizedBox(
                        height: AppSizes.double10,
                      ),
                      Text(
                        ConstantString.photoVideo,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: FontFamilyName.montserrat,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Get.back();
                          bool isPostCreated =
                              await Get.to(() => const CreateTextPostScreen());
                          if (isPostCreated) {
                            print(
                                'this is isPostCreated =====>>>>  ${isPostCreated}');
                            changePage(1);
                          }
                        },
                        child: Image.asset(AppImages.text, scale: imageScale),
                      ),
                      SizedBox(
                        height: AppSizes.double10,
                      ),
                      Text(
                        ConstantString.text,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: FontFamilyName.montserrat,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void guestLoginClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.guestpopup,
            title: ConstantString.guestAccountMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () async {
              var deviceToke = '';
              if (GSAPIHeaders.fcmToken!.isNotEmpty) {
                deviceToke = GSAPIHeaders.fcmToken ?? '';
              }
              await GS.clearAll();
              Log.info('LOGOUT TOKE: $deviceToke');
              GSAPIHeaders.fcmToken = deviceToke;
              Get.offAll(() => const LoginScreen());
            },
            option1: ConstantString.cancel.toUpperCase(),
            option2: ConstantString.continueTitle.toUpperCase());
      },
    );
  }

 void _launchURL() async {

  final url = Platform.isAndroid ? AppConfig.androidUrl : AppConfig.iosUrl;
  // final url = 'https://teambalance.uk/';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

  Future<void> updateAppClicked(BuildContext context, bool forceUpdate) async {
    var deviceSize = MediaQuery.of(context).size;
    forceUpdate
        ? showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                insetPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                backgroundColor: AppColors.primaryColor,
                content: SizedBox(
                  height: deviceSize.height * 0.25,
                  width: deviceSize.width * 0.65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: AppSizes.double50,
                        backgroundColor: AppColors.fantedBlueColor,
                        child: Image.asset(
                          AppImages.appversion,
                          scale: 1.0,
                        ),
                      ),
                      SizedBox(height: AppSizes.double10),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: 5, right: 5),
                        child: Text(
                          ConstantString.forceUpdateMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: FontFamilyName.montserrat,
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      SizedBox(height: AppSizes.double10),
                    ],
                  ),
                ),
                actions: <Widget>[
                  const Divider(height: 0, color: AppColors.lightGrey),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Get.back();
                        _launchURL();
                      },
                      child: Text(
                        ConstantString.update.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.lightBlueThemeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              );
            },
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                insetPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                backgroundColor: AppColors.primaryColor,
                content: SizedBox(
                  height: deviceSize.height * 0.25,
                  width: deviceSize.width * 0.65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: AppSizes.double50,
                        backgroundColor: AppColors.fantedBlueColor,
                        child: Image.asset(
                          AppImages.appversion,
                          scale: 1.0,
                        ),
                      ),
                      SizedBox(height: AppSizes.double10),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: 5, right: 5),
                        child: Text(
                          ConstantString.normalUpdateMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: FontFamilyName.montserrat,
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                      SizedBox(height: AppSizes.double10),
                    ],
                  ),
                ),
                actions: <Widget>[
                  const Divider(height: 0, color: AppColors.lightGrey),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            ConstantString.cancel.toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.mediumGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: 1.0,
                          height: AppSizes.double25,
                          color: AppColors.lightGrey,
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            _launchURL();
                          },
                          child: Text(
                            ConstantString.update.toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.lightBlueThemeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
  }

  UserModel? userData;
  Future<void> getProfileApi(
      {bool handleErrors = true, required BuildContext context}) async {
    await GetStorage.init();
    // var isLoading;
    // isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "get_profile",
      endPoint: ApiPaths.get_profile,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    var txtControllerOtp;
    final result = await apiHelper.get();
    Log.info("result: $result");
    await result.fold((l) {
      final status = l['status'];
      final message = l['message'] == null || l['message'] == "null"
          ? APIErrorMsg.somethingWentWrong
          : l['message'];
      showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          print('data  -===========>   ${r['data']}');
          getHelpAndSupportApi();
          getMasterDataApi();
          final userToken = r['data']['token'];
          print('this is userToken =====>  ${userToken}');
          if (userToken != null) {
            await GSAPIHeaders.writeUserToken(userToken);
          }
          final data = r['data']['return_data'];

          // final data = r['data'];
          Log.info("USER DATA: $data");
          final userData = UserModel.fromJson(data);
          if (r['data']['return_data']['is_active'] == false) {
            showTopFlashMessage(
                ToastType.failure, ConstantString.accountIsBlocked);
            postLogoutApi();
          }
          userData.updateavailable = r['data']['update_available'];
          userData.isforceupdate = r['data']['is_force_update'];
          userData.isnewnotification =
              r['data']['is_new_notification'] == 1 ? true : false;
          Log.success("userData: $userData");
          await GS.clearUserData();
          await GS.writeUserData(userData);
          // updateAppClicked(context,true);
          if (r['data']['update_available'] == true) {
            print(
                'this is update_available ---->>>  ${r['data']['update_available']}');
            updateAppClicked(
                context, r['data']['is_force_update'] == true ? true : false);
          }
          // if(userData.isresidencecreated!){
          //   // Get.offAll(() =>  HomeScreen(isFromContinueAsGuest: false,));
          // }else{
          //   // Get.offAll(() =>  AddResidenceScreen(isForEditResidenceAddress: false,isFromSignUpScreen: true, residenceModel: residenceModel));
          // }
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        // isLoading.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    // isLoading.value = false;
  }

  void getHelpAndSupportApi({bool handleErrors = true}) {
    // Use async API call without blocking the UI
    ApiHelper(
      serviceName: "help_and_support",
      endPoint: ApiPaths.help_and_support,
      showErrorDialog: handleErrors,
      showTransparentOverlay: false, // Set to false to prevent UI blocking
    ).post(body: {}, isFormData: false).then((result) {
      Log.info("result: $result");

      result.fold((l) {
        // Handle API error here if needed
        Log.error('Error in getHelpAndSupportApi: $l');
      }, (r) {
        try {
          final status = r['status'];
          final message = r['message'];
          if (status == ApiStatus.success) {
            final data = r['data'];
            Log.info("Help and Support: $data");
            final helpAndSupport = HelpAndSupport.fromJson(data);
            GS.writeHelpAndSupportData(
                helpAndSupport); // Save Help and Support data
          } else {
            showTopFlashMessage(ToastType.failure, message.toString());
          }
        } catch (e, stacktrace) {
          Log.error('\n******** $e ********\n$stacktrace');
        }
      });
    });
  }

  //   Future<void> getHelpAndSupportApi({bool handleErrors = true}) async {
  //     print('this is inside getHelpAndSupportApi =========>');
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

  //   }, (r) async {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //       final data = r['data'];
  //         Log.info("Help and Support: $data");
  //         final helpAndSupport = HelpAndSupport.fromJson(data);
  //         // Log.success("userData: $userData");
  //         await GS.writeHelpAndSupportData(helpAndSupport);
  //       }
  //       print("message: $message");
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  // }

  void getMasterDataApi({bool handleErrors = true}) {
    // Make API call asynchronously
    ApiHelper(
      serviceName: "get_master_data",
      endPoint: ApiPaths.get_master_data,
      showErrorDialog: handleErrors,
      showTransparentOverlay: false, // Disable blocking overlay
    ).get().then((result) {
      print("result: $result");

      result.fold((l) {
        // Handle error case here if needed
      }, (r) {
        try {
          final status = r['status'];
          final message = r['message'];
          if (status == ApiStatus.success) {
            final data = r['data'];
            Log.info("Master data: $data");
            final masterApiData = MasterDataModel.fromJson(data);
            GS.writeMasterApiData(masterApiData); // Save data asynchronously
          } else {
            showTopFlashMessage(ToastType.failure, message.toString());
          }
        } catch (e, stacktrace) {
          Log.error('\n******** $e ********\n$stacktrace');
        }
      });
    });
  }

  //     Future<void> getMasterDataApi({bool handleErrors = true}) async {
  //     print('this is inside getMasterDataApi =========>');
  //   await GetStorage.init();
  //   final apiHelper = ApiHelper(
  //     serviceName: "get_master_data",
  //     endPoint: ApiPaths.get_master_data,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //   final result = await apiHelper.get();
  //   print("result: $result");
  //   await result.fold((l) {

  //   }, (r) async {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //       final data = r['data'];
  //         Log.info("Master data: $data");
  //         final masterApiData = MasterDataModel.fromJson(data);
  //         // Log.success("userData: $userData");
  //         await GS.writeMasterApiData(masterApiData);
  //       }
  //       print("message: $message");
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  // }
  // void verifyOtpScreen() {
  //   Get.to(() =>  OtpVerificationScreen(isFromProfileScreen: false,));
  // }

  RxBool logOutLoader = false.obs;
  Future<void> postLogoutApi({bool handleErrors = true}) async {
    logOutLoader.value = true;
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "user_logout",
      endPoint: ApiPaths.user_logout,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {}, isFormData: false);
    print("result: $result");
    await result.fold((l) {
      if (l['msg'] == "No JWT-Token found.") {
        logOutLoader.value = false;
        clearDataAndNavigateToLogin();
      }
      logOutLoader.value = false;
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          logOutLoader.value = false;
          clearDataAndNavigateToLogin();
        } else {
          logOutLoader.value = false;
          clearDataAndNavigateToLogin();
        }
        print("message: $message");
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }
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
      Get.off(
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
      await Future.delayed(Duration(seconds: 2));
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
}
