
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/otp_verification_screen.dart';
import 'package:team_balance/app/views/settings/privacy_policy_screen.dart';
import 'package:team_balance/app/views/settings/terms_and_conditions_screen.dart';
import 'package:team_balance/app/views/signup_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/user_model.dart';


class LoginController extends GetxController {
    final user = UserModel(
          )
      .obs;
   final TextEditingController txtControllerPhoneNumber = TextEditingController();
    var rememberMe = false.obs;
   var dialCode = ''.obs;
  var contactNumber = ''.obs;




final flashMessageController = FlashMessageController();
void toggleRememberMe() async {
    rememberMe.value = !rememberMe.value;
    await GS.writeRememberMe(rememberMe.value);
    print('thit is remember me value =====> ${rememberMe.value}');
  }

   void verifyOtpScreen() async{
    if (await networkInfo.checkIsConnected) {
            await GS.writeGuestLogin(false);   
    if (isFormValid()) {
      postLoginApi();
    }      
               }  else {                
                flashMessageController.showMessage(ToastType.info, APIErrorMsg.noInternetMsg);
                //  showTopFlashMessage(
                //      ToastType.info, APIErrorMsg.noInternetMsg);
               }
    
  }

  bool isFormValid() {
    if (txtControllerPhoneNumber.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter mobile number.',
          context: Get.context);
      return false;
    }
    return true;
  }

  void guestAccount() async{
   await GS.clearUserData();
    //  showTopFlashMessage(ToastType.failure, "This feature is coming soon...");
   await GS.writeGuestLogin(true); 
   
  //  postLoginApi();
    getGuetsLoginApi();   
  }
  
  void webViewPP() {
    Get.to(() => const PrivacyPolicyScreen());
  }

    void webViewTC() {
    Get.to(() => const TermsAndConditionsScreen());
  }


void signupScreen() {
    Get.to(() => const SignupScreen());
  }

  RxBool isLoading = false.obs;
  Future<void> postLoginApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "login_otp",
      endPoint: ApiPaths.login_otp,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "country_code": dialCode.value,
      "phone_number": contactNumber.value,
    }, isFormData: true);


    print('this is testing 11111111========>');
    print(result);


    Log.info("result: $result");
    await result.fold((l) {
      final status = l['status'];
        final message = l['message']==null || l['message']=="null" ? APIErrorMsg.somethingWentWrong : l['message'];
             Log.warning("Error message: ${message}");
       showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        final data = r['data'];
        print('this is new testign ==========>');          
        if (status == ApiStatus.success) {
          await GSAPIHeaders.writeLoginToken(r['data']['login_token']);
          Get.to(() =>  OtpVerificationScreen(isFromProfileScreen: false,isFromSignUpScreen: true,
          phoneNumber: contactNumber.value,
          countryCode: dialCode.value,),
          arguments: {
                      // "phoneOtp":data['new_otp'],
                    });
        } else if(status == ApiStatus.failed){
          showTopFlashMessage(ToastType.failure, ConstantString.loginOtpApiResMsg);
        }else {
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


   
  Future<void> getGuetsLoginApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;
    final apiHelper = ApiHelper(
      serviceName: "guest_login_token",
      endPoint: ApiPaths.guest_login_token,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.get();


    print('this is testing 11111111========>');
    print(result);


    Log.info("result: $result");
    await result.fold((l) {
      final status = l['status'];
        final message = l['message'];
       showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        final data = r['data'];
        print('this is new testign ==========>');          
        if (status == 1) {
          final userToken = r['data']['token'];
          await GSAPIHeaders.writeUserToken(userToken);
           Get.to(() =>  HomeScreen(isFromContinueAsGuest:true,isFromChatScreen: false,indexForScreen: 0,));
        } else if(status == ApiStatus.success){
          showTopFlashMessage(ToastType.failure, message.toString());
        }else {
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