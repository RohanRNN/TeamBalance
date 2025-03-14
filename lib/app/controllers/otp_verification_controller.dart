
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/api/socket_utils.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/models/user_model.dart';


class OtpVerificationController extends GetxController {
    final TextEditingController txtControllerOtp = TextEditingController();
      var phoneTimerIsOn = true.obs;
      var phoneOtp = '0000';
      var residenceModel = ResidenceModel();
  var dialCode = ''.obs;
  var contactNumber = ''.obs;


  void resendPhoneOTPClicked() async {
    phoneTimerIsOn.value = true;
    postResendApi();
  }

    void resendPhoneOTPClickedForUpdate() async {
    phoneTimerIsOn.value = true;
    print('dialCode --->>>  ${dialCode.value}');
    print('contactNumber --->>>  ${contactNumber.value}');
    postResendForUpdateApi();
  }

  Future<void> homeScreen() async {
    if(txtControllerOtp.text.isNotEmpty){
      postLoginApi();
    }else{
       showTopFlashMessage(ToastType.failure, "Please enter OTP recived on your number.");
    }
      
  }

    Future<void> verifyPhoneToUpdate() async {
    if(txtControllerOtp.text.isNotEmpty){
      postUpdatePhoneNumberApi();
    }else{
       showTopFlashMessage(ToastType.failure, "Please enter OTP recived on your number.");
    }      
  }

 void addResidenceScreen() {
 Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isFromSignUpScreen: true,isForEditResidenceAddress: false, residenceModel: residenceModel,));
  }


  RxBool isLoading = false.obs;
  UserModel? userData;
  Future<void> postLoginApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "verify_loggin_account",
      endPoint: ApiPaths.verify_loggin_account,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      // "phone": txtControllerEmail.text,
         "otp":txtControllerOtp.text 
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
        if (status == ApiStatus.success) {
          await GS.clearUserData();
          final userToken = r['data']['token'];
          await GSAPIHeaders.writeUserToken(userToken);
          final data = r['data']['user_info'];
          Log.info("USER DATA: $data");
          final userData = UserModel.fromJson(data);
          userData.updateavailable = r['data']['update_available'];
          userData.isforceupdate = r['data']['is_force_update'];
           userData.isnewnotification = r['data']['is_new_notification'] ==1 ? true:false;
          // Log.success("userData: $userData");
          await GS.writeUserData(userData);
          // await GS.writeRememberMe(true);
           await GS.writeGuestLogin(false); 
            await getMasterDataApi();
             SocketUtils.joinSocket();
          if(userData.isresidencecreated!){
            Get.offAll(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen: false,indexForScreen: 0,));
          }else{
            Get.offAll(() =>  AddResidenceScreen(isFormHomeScreen:false, isForEditResidenceAddress: false,isFromSignUpScreen: true, residenceModel: residenceModel));
          }
          
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

        Future<void> getMasterDataApi({bool handleErrors = true}) async {
      print('this is inside getMasterDataApi =========>');
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "get_master_data",
      endPoint: ApiPaths.get_master_data,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.get();
    print("result: $result");
    await result.fold((l) {
     
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
        final data = r['data'];
          Log.info("Master data: $data");
          final masterApiData = MasterDataModel.fromJson(data);
          // Log.success("userData: $userData");
          await GS.writeMasterApiData(masterApiData);
        } 
        print("message: $message");
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }


  Future<void> postResendApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "resend_otp",
      endPoint: ApiPaths.resend_otp,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: { 
    }, isFormData: true);


    print('this is testing 11111111========>');
    print(result);


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
        if (status == ApiStatus.success) {
          await GSAPIHeaders.writeLoginToken(r['data']['login_token']);  
          // txtControllerOtp.text = r['data']['new_otp'];       
        } else if(status == ApiStatus.failed){
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

  Future<void> postResendForUpdateApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "resend_otp_for_profile_update",
      endPoint: ApiPaths.resend_otp_for_profile_update,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: { 
    
    }, isFormData: true);

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
        if (status == ApiStatus.success) {
          // await GSAPIHeaders.writeLoginToken(r['data']['login_token']);  
          // txtControllerOtp.text = r['data']['new_otp'];       
        } else if(status == ApiStatus.failed){
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


  Future<void> postUpdatePhoneNumberApi({bool handleErrors = true}) async {
    await GetStorage.init();
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "phone_number_otp",
      endPoint: ApiPaths.phone_number_otp,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      // "phone": txtControllerEmail.text,
         "otp":txtControllerOtp.text 
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
          print('This is success message');
          final userToken = r['data']['token'];
          await GSAPIHeaders.writeUserToken(userToken);
          final data = r['data']['user_info'];
          Log.info("USER DATA: $data");
          final userData = UserModel.fromJson(data);
          // Log.success("userData: $userData");
          await GS.writeUserData(userData);   
          // Get.back();  
          Get.back(result: true);        
          
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