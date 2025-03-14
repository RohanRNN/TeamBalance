import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/user_list_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';


class BlockedUserController extends GetxController {
 static const isNotification = true;
 
  void saveAndGoHome() {
   Get.offAll(() =>  HomeScreen(isFromContinueAsGuest:false,isFromChatScreen: false,indexForScreen: 0,));
  }

   void save() {
   Get.back();
  }

var loginUserId = GS.userData.value!.id;
   RxBool isLoading = false.obs;
  var arrayOfUsers = <UserListModel>[].obs;
  Future<void> getAllBlockedUser({
    bool fromRefresh = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (fromRefresh) {
      isLoading.value = false;
    } else {
      isLoading.value = true;
    }

    final apiHelper = ApiHelper(
      serviceName: "get_blocked_users" ,
      endPoint: ApiPaths.get_blocked_users  + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    if(page == 1){
      arrayOfUsers.clear();
    }
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1) {
            arrayOfUsers.clear();
          }
          final data = r['data'];
          arrayOfUsers.addAll(
              List<UserListModel>.from(data.map((x) => UserListModel.fromJson(x))));
          isLoading.value = false;
          Log.info("User List Model : ${arrayOfUsers}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isLoading.value = false;
  }

   void blockUserClicked(BuildContext context,int userId,String userName,int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.blockmodal,
            title: "Are you sure you want to unblock ${userName} ?",
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () {
               postUnblockUserApi(
                    userId: userId,
                    index: index                    
                  ).then((value) => Get.back());
                
            },
            option1: ConstantString.noText.toUpperCase(),
            option2: ConstantString.yesText.toUpperCase());
      },
    );
  }

  //  void blockUserClicked(BuildContext context,int userId,String userName,int index) {
  //     var dynamicSize = MediaQuery.of(context).size;
  //   showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return AlertDialog(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     insetPadding: EdgeInsets.zero,
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
  //     backgroundColor: AppColors.primaryColor,
  //     content: SizedBox(
  //       height: dynamicSize.height * 0.2,
  //       width: dynamicSize.width * 0.65,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(height: AppSizes.double10),
  //           Padding(
  //             padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
  //             child: Text(
  //               ConstantString.unblockuser,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                   color: AppColors.black,
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 24),
  //             ),
  //           ),
  //           SizedBox(height: AppSizes.double10),
  //             Padding(
  //             padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
  //             child: Text(
  //              "Are you sure you want to unblock ${userName} ?",
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                   color: AppColors.black,
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 16),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     actions: <Widget>[
  //       const Divider(height: 0, color: AppColors.lightGrey),
  //       Padding(
  //         padding: const EdgeInsets.only(left:15.0,right: 15.0,),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //               TextButton(
  //                 onPressed:() {
  //                 Get.back();
  //               },
  //                 child: Text(
  //                   ConstantString.noText,
  //                   style: const TextStyle(
  //                       color: AppColors.mediumGrey,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 15),
  //                 ),
  //               ),
  //               Container(
  //                 width: 1.0,
  //                 height: AppSizes.double25,
  //                 color: AppColors.lightGrey,
  //               ),
  //             TextButton(
  //                 onPressed:() {
  //                 postUnblockUserApi(
  //                   userId: userId,
  //                   index: index                    
  //                 ).then((value) => Get.back());
  //               },
  //               child: Text(
  //                  ConstantString.yesText,
  //                 style: const TextStyle(
  //                     color: AppColors.textButtonBlueColor,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 15),
  //               ),
  //             ),
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  //   },
  // );
  // }

  Future<void> postUnblockUserApi(
      {bool handleErrors = true, int userId = 0, int index = 0}) async {
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.block_user,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "blocked_user_id": userId.toString(),
    }, isFormData: true);
    isLoading.value = true;
    Log.info("result: $result");
    await result.fold((l) {}, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) { 
          arrayOfUsers.removeAt(index);
             dbHelper.deleteBlockedUser(
              loginUserId!,
              userId
             );            
            showTopFlashMessage(ToastType.success, ConstantString.unblockUserApiResMsg);
             
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          
        }
        isLoading.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }


}
