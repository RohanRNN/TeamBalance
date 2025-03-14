
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/otp_verification_screen.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/app/views/settings/privacy_policy_screen.dart';
import 'package:team_balance/app/views/settings/terms_and_conditions_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/residence_model.dart';


class SignupController extends GetxController {
  final TextEditingController txtControllerFullname = TextEditingController();
  final TextEditingController txtControllerEmail = TextEditingController();
  final TextEditingController txtControllerPhoneNumber = TextEditingController();
  final TextEditingController txtControllerCountryCode = TextEditingController();
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode mobileFocus = FocusNode();

var residenceModel = ResidenceModel();

   bool isFormValid() {
     if (txtControllerFullname.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter your name.',
          context: Get.context);
      return false;
    }
     if (txtControllerEmail.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter your email.',
          context: Get.context);
      return false;
    }
    if(txtControllerEmail.text.isNotEmpty){
        final bool isValid = EmailValidator.validate(txtControllerEmail.text);
        if(isValid == false){
          showTopFlashMessage(ToastType.info, 'Please enter valid email.',
          context: Get.context);
      return false;
        }
    }
    if (txtControllerPhoneNumber.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter mobile number.',
          context: Get.context);
      return false;
    }
    // if (txtControllerPhoneNumber.text.length != 11) {
    //   showTopFlashMessage(ToastType.info, 'Please enter an valid mobile number.',
    //       context: Get.context);
    //   return false;
    // }
    return true;
  }


   RxBool isLoading = false.obs;
  Future<void> postSignUpApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "register",
      endPoint: ApiPaths.register,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "full_name":txtControllerFullname.text,
      "email_id":txtControllerEmail.text,
      "country_code":txtControllerCountryCode.text,
      "phone_number": txtControllerPhoneNumber.text,
    }, isFormData: true);


    Log.info("result: $result");
    await result.fold((l) {
       final status = l['status'];
        final message = l['message']==null || l['message']=="null" ? APIErrorMsg.somethingWentWrong : l['message'];
        showTopFlashMessage(ToastType.failure, message.toString());
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        final data = r['data'];
        print('this is new testign ==========>');  
        print(r['status']);        
        if (status == ApiStatus.success) {
           await GSAPIHeaders.writeLoginToken(r['data']['login_token']);
           await GS.writeRememberMe(true);
          Get.to(() =>  OtpVerificationScreen(
            isFromProfileScreen: false,isFromSignUpScreen: true,
            phoneNumber: txtControllerPhoneNumber.text,
            countryCode: txtControllerCountryCode.text,
            ));
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

final flashMessageController = FlashMessageController();
  void verifyOtpScreen() async { 
     if (await networkInfo.checkIsConnected) {
                  await GS.writeGuestLogin(false);   
    if (isFormValid()) {
      print('txtControllerPhoneNumber.tex ----- > ${txtControllerPhoneNumber.text}');
      print('txtControllerCountryCode.tex ----- > ${txtControllerCountryCode.text}');
      // postSignUpApi();
    }  
               }  else {
                flashMessageController.showMessage(ToastType.info, APIErrorMsg.noInternetMsg);
                //  showTopFlashMessage(
                //      ToastType.info, APIErrorMsg.noInternetMsg);
               }
   
  }
  void addResidence() {
    Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isFromSignUpScreen: true,isForEditResidenceAddress: false, residenceModel: residenceModel,));
  }
  

     void guestAccount() async{
   await GS.clearUserData();
    //  showTopFlashMessage(ToastType.failure, "This feature is coming soon...");
   await GS.writeGuestLogin(true); 
   
  //  postLoginApi();
    getGuetsLoginApi();   
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

  //  void guestAccount() async{
  //       //  showTopFlashMessage(ToastType.failure, "This feature is coming soon...");
  //  await GS.writeGuestLogin(true); 
  //   Get.to(() =>  HomeScreen(isFromContinueAsGuest:true,isFromChatScreen: false,indexForScreen: 0,));
  // }

   
  void webViewPP() {
    Get.to(() => const PrivacyPolicyScreen());
  }

    void webViewTC() {
    Get.to(() => const TermsAndConditionsScreen());
  }

}
