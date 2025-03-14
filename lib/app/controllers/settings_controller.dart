// ignore_for_file: avoid_print


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/settings/blocked_user_list_screen.dart';
import 'package:team_balance/app/views/settings/help_and_support_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_screen.dart';
import 'package:team_balance/app/views/settings/my_business/my_business_screen.dart';
import 'package:team_balance/app/views/settings/notification_screen.dart';
import 'package:team_balance/app/views/settings/privacy_policy_screen.dart';
import 'package:team_balance/app/views/settings/profile/profile_screen.dart';
import 'package:team_balance/app/views/settings/terms_and_conditions_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsController extends GetxController {
 var imageScale  = 2.6;
 var forceUpdate = GS.userData.value == null ? false : GS.userData.value!.isforceupdate!;    
 RxBool logOutLoader = false.obs;  

  RxBool isGuestLogin = false.obs;
  void setGuestAccount() async {
    isGuestLogin.value = await GS.readGuestLogin();
  }

Future<void> goToLoginScreen() async {
    var deviceToke = '';
              if (GSAPIHeaders.fcmToken!.isNotEmpty) {
                deviceToke = GSAPIHeaders.fcmToken ?? '';
              }
              await GS.clearAll();
              Log.info('LOGOUT TOKE: $deviceToke');
              GSAPIHeaders.fcmToken = deviceToke;
              Get.offAll(() => const LoginScreen());
}

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
          image: AppImages.logoutmodal,
          title: ConstantString.logoutMessage,
          option1: ConstantString.cancel.toUpperCase(),
          onTapOption1: () {
            Get.back();
          },
          option2: ConstantString.logout.toUpperCase(),
          onTapOption2: () async {    
            Get.back();        
            await postLogoutApi();
          },
        );
      },
    );
  }

  void deleteAccountClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.deleteaccountmodal,
            title: ConstantString.deleteAccountMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () {
              deleteAccountApi();
            },
            option1: ConstantString.cancel.toUpperCase(),
            option2: ConstantString.delete.toUpperCase());
      },
    );
  }


void guestLoginClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBGuestUserDialog();
        });
        }

  void myProfile() {
        Get.to(() => const ProfileScreen());
  }

  void myBusiness() {
    //  Get.to(() =>  AdsPlanScreen());
     Get.to(() => const MyBusinessScreen());
  }

  void notifications() {
     Get.to(() => const NotificationScreen(
      message: null,
     ));
  }  

  void blockedUserList() {
     Get.to(() => const BlockedUserScreen());
  }

  void privacyPolicyClicked() {
     Get.to(() => const PrivacyPolicyScreen());
  }

  void helpAndSupport() {
     Get.to(() => const HelpAndSupportScreen());
  }

  void termsAndConditionsClicked() {
     Get.to(() => const TermsAndConditionsScreen());
  }

  void appVersion(BuildContext context) {
       if(GS.userData.value!.updateavailable!){
        updateAppClicked(context);
       }else{
      Fluttertoast.showToast(
       msg: ConstantString.appIsUptodate,
       toastLength: Toast.LENGTH_SHORT,
       gravity: ToastGravity.BOTTOM,
       timeInSecForIosWeb: 1,
       backgroundColor: Colors.grey.shade300,
       textColor: Colors.black,
       fontSize: 16.0
     ); 

       }                    
                  
  }

  void _launchURL() async {
    if (await canLaunch(AppConfig.urlForUpdate)) {
      await launch(AppConfig.urlForUpdate);
    } else {
      throw 'Could not launch ${AppConfig.urlForUpdate}';
    }
  }

   Future <void> updateAppClicked(BuildContext context) async {
    var deviceSize = MediaQuery.of(context).size; 
    forceUpdate?  
    showDialog(
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
        height: deviceSize.height * 0.2,
        width: deviceSize.width * 0.65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: AppSizes.double50,
              backgroundColor: AppColors.fantedBlueColor,
              child:Image.asset(AppImages.appversion,scale: 1.0,),
            ),
            SizedBox(height: AppSizes.double10),
            Padding(
              padding: const EdgeInsets.only(top:8.0,left: 30,right: 30),
              child: Text(
                ConstantString.updateAppMessage,
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
       
          Center(
            child: TextButton(
              onPressed: (){
                //  Get.back();
                _launchURL();
              },
              child: Text(ConstantString.update.toUpperCase()   ,           
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
    ):showDialog(
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
        height: deviceSize.height * 0.2,
        width: deviceSize.width * 0.65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: AppSizes.double50,
              backgroundColor: AppColors.fantedBlueColor,
              child:Image.asset(AppImages.appversion,scale: 1.0,),
            ),
            SizedBox(height: AppSizes.double10),
            Padding(
              padding: const EdgeInsets.only(top:8.0,left: 30,right: 30),
              child: Text(
                ConstantString.updateAppMessage,
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
          padding: const EdgeInsets.only(left:15.0,right: 15.0,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
              onPressed: (){
                 Get.back();
              },
              child: Text(ConstantString.cancel.toUpperCase()   ,           
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
              onPressed: (){
                //  Get.back();
                _launchURL();
              },
              child: Text(ConstantString.update.toUpperCase()   ,           
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


  Future<void> deleteAccountApi({bool handleErrors = true}) async {
     logOutLoader.value = true;
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "delete_account",
      endPoint: ApiPaths.delete_account,
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


}
