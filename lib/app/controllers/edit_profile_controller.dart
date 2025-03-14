import 'dart:io';


import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/otp_verification_screen.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';


class EditProfileController extends GetxController {

  late UserModel tempUser;
  int selectGender = int.parse(GS.userData.value!.gender!);
   final TextEditingController txtControllerDateOfBirth = TextEditingController();
   final TextEditingController txtControllerPhoneNumber = TextEditingController();
   final TextEditingController txtControllerFullName = TextEditingController();
   final TextEditingController txtControllerBio = TextEditingController();
   String changedDOB = '';
   String chnagedGender = '';

Map<String, String> dialCodeToCountryCode = {
  '+91': 'IN', // India
  '+1': 'US', // United States
  '+44': 'GB', // United Kingdom
  '+225': 'CI', // Côte d'Ivoire
  '+33': 'FR', // France
  '+49': 'DE', // Germany
  '+39': 'IT', // Italy
  '+34': 'ES', // Spain
  '+31': 'NL', // Netherlands
  '+47': 'NO', // Norway
  '+46': 'SE', // Sweden
  '+41': 'CH', // Switzerland
  '+43': 'AT', // Austria
  '+32': 'BE', // Belgium
  '+45': 'DK', // Denmark
  '+420': 'CZ', // Czech Republic
  '+48': 'PL', // Poland
  '+351': 'PT', // Portugal
  '+353': 'IE', // Ireland
  '+30': 'GR', // Greece
  '+358': 'FI', // Finland
  '+36': 'HU', // Hungary
  '+352': 'LU', // Luxembourg
  '+356': 'MT', // Malta
  '+386': 'SI', // Slovenia
  '+372': 'EE', // Estonia
  '+370': 'LT', // Lithuania
  '+371': 'LV', // Latvia
  '+357': 'CY', // Cyprus
  '+381': 'RS', // Serbia
  '+380': 'UA', // Ukraine
  '+355': 'AL', // Albania
  '+373': 'MD', // Moldova
  '+375': 'BY', // Belarus
};


String? getCountryCodeFromDialCode(String dialCode) {
  return dialCodeToCountryCode[dialCode];
}

   
     var dialCode = ''.obs;
  var contactNumber = ''.obs;
  var selectedCountryCode = 'IN'.obs;
  File? profileFile;
  var changePhone = false.obs;
  String newPhone = '';
  String dateValueToSend = '';

 final List<String> gender = [
  '---',
  'Male',
  'Female',
  ];



  
  void addUserDetails(UserModel value) {
    tempUser = value;    
    if( tempUser.dateofbirth == ''){
      print('hello');
    }else{
        dateValueToSend = DateFormat("yyyy-MM-dd").format(DateTime.parse( tempUser.dateofbirth !));
    txtControllerDateOfBirth.text = DateFormat("dd-MM-yyyy").format(DateTime.parse( tempUser.dateofbirth !));
    }
  
  }

  void updateFullName(String value) {
    txtControllerFullName.text = value;
    // tempUser.fullname = value;
  }
    void updateGender(String value) {
      chnagedGender = value;
    // tempUser.gender = value;
  }
    void updateDateOfBirth(String value,) {
      changedDOB = value;
    // tempUser.dateofbirth = value;
     txtControllerDateOfBirth.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(value!));
  }
   void updateBio(String value) {
    txtControllerBio.text = value;
    // tempUser.bio = value;
  }



   void saveEditProfile() {    
   editProfile();
  }

  RxBool isLoading = false.obs; 
   Future<void> editProfile({bool handleErrors = true}) async {    
      update(['edit_details']);
      isLoading.value = true;
      await GetStorage.init();
      final apiHelper = ApiHelper(
        serviceName: "update_profile",
        endPoint: ApiPaths.update_profile,
        showErrorDialog: handleErrors,
        showTransparentOverlay: true,
      );
      
print(contactNumber.value);
      final result = await apiHelper.postMultipart(
        body: changePhone.value && contactNumber.value != tempUser.phonenumber && contactNumber.value != '' ? {
          "full_name": txtControllerFullName.text ?? '',
          "gender": chnagedGender ?? '',
          "country_code": dialCode.value,
          "phone_number": contactNumber.value,
          "date_of_birth": dateValueToSend ?? '',
          "bio": txtControllerBio.text ?? '',
        }:{
          "full_name": txtControllerFullName.text ?? '',
          "gender": chnagedGender ?? '',
          "date_of_birth": dateValueToSend ?? '',
          "bio": txtControllerBio.text ?? '',
        },
        imageFile: {
          "profile_image": profileFile == null ? [] : [profileFile!],
        },
      );

      Log.success("User Profile result: $result");
      await result.fold((l) {
        final status = l['status'];
          final message = l['message']==null || l['message']=="null" ? APIErrorMsg.somethingWentWrong : l['message'];
         showTopFlashMessage(ToastType.failure, message.toString());
      }, (r) async {
        try {
          final status = r['status'];
          final message = r['message'];
          if (status == ApiStatus.success) {
            final data = r['data']['user_info']; 
             print("userToken --->>> ${changePhone.isTrue}");
             print("userToken --->>> ${tempUser.phonenumber}");
             print("userToken --->>> ${contactNumber.value}");
            if(changePhone.isTrue && contactNumber.value != tempUser.phonenumber && contactNumber.value != ''){
              final userToken = r['data']['login_token'];
              print("userToken --->>> ${userToken}");
              print('befor --->> ${GSAPIHeaders.loginToken}');
          await GSAPIHeaders.writeLoginToken(userToken); 
          print('after --->> ${GSAPIHeaders.loginToken}'); 
          // await GSAPIHeaders.writeLoginToken(r['data']['login_token']);  
            }
            final userData = UserModel.fromJson(data);
            await GS.writeUserData(userData);
            if(changePhone.value && contactNumber.value != tempUser.phonenumber && contactNumber.value != ''){
                txtControllerPhoneNumber.text == contactNumber.value;
                bool isPostCreated = await Get.to(() =>  OtpVerificationScreen(
                  isFromProfileScreen: true,isFromSignUpScreen: false,
                  phoneNumber: contactNumber.value,
                  countryCode: dialCode.value,));                 
              changePhone.value = false;
            }else{
              showTopFlashMessage(ToastType.success, ConstantString.updateProfileApiResMsg,
                context: Get.context);
             Get.back();
             changePhone.value = false;
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
      // update(['edit_details']);
    
  }


  //  Future<void> editProfileNumber({bool handleErrors = true}) async {  
      
  //     update(['edit_details']);
  //     isLoading.value = true;
  //     await GetStorage.init();
  //     final apiHelper = ApiHelper(
  //       serviceName: "update_profile",
  //       endPoint: ApiPaths.update_profile,
  //       showErrorDialog: handleErrors,
  //       showTransparentOverlay: true,
  //     );

  //     final result = await apiHelper.postMultipart(
  //       body: {
  //         "full_name": user.value.phonenumber ?? '',        },
  //       imageFile: {
  //         "profile_image": profileFile == null ? [] : [profileFile!],
  //       },
  //     );

  //     Log.success("User Profile result: $result");
  //     await result.fold((l) {
  //       final status = l['status'];
  //         final message = l['message'];
  //        showTopFlashMessage(ToastType.failure, message.toString());
  //     }, (r) async {
  //       try {
  //         final status = r['status'];
  //         final message = r['message'];
  //         if (status == ApiStatus.success) {
  //           final data = r['data'];
  //           final userData = UserModel.fromJson(data);
  //           await GS.writeUserData(userData);
  //           showTopFlashMessage(ToastType.success, r['message'],
  //               context: Get.context);
  //           Get.back();
  //         } else {
  //           showTopFlashMessage(ToastType.failure, message.toString());
  //         }
  //         isLoading.value = false;
  //         return;
  //       } catch (e, stacktrace) {
  //         Log.error('\n******** $e ********\n$stacktrace');
  //       }
  //     });
  //     isLoading.value = false;
  //     update(['edit_details']);
    
  // }


  void verifyOtpScreen() {
    Get.to(() =>  OtpVerificationScreen(
      isFromProfileScreen: true,isFromSignUpScreen: false,
      phoneNumber: contactNumber.value,
                  countryCode: dialCode.value,));
  }
    DateTime selectedDate =
      DateTime.now().subtract(const Duration(days: 365 * 18));

  Future selectDate(BuildContext context) async {
    if (tempUser.dateofbirth!.isNotEmpty) {
      try {
        selectedDate =
            DateFormat(AppConstants.dobFormat).parse(tempUser.dateofbirth!);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1940),
        lastDate: DateTime(2020),
        confirmText: 'OK',
        cancelText: 'CLOSE',
        builder: (ctx, child) {
          return Theme(
              data: ThemeData.light().copyWith(
                primaryColor:
                    AppColors.backgroundColor, // Change the header color
                hintColor:
                    AppColors.backgroundColor, // Change the selected date color
                colorScheme: const ColorScheme.light(
                    primary: AppColors
                        .backgroundColor), // Change the calendar days' color
                buttonTheme:
                    const ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!);
        });
        
    if (picked != null) {
      print(picked);
      String formattedDate = DateFormat(AppConstants.dobFormat).format(picked);
      print(formattedDate);
      updateDateOfBirth(picked.toString(),);
      print(DateFormat("yyyy-MM-dd").format(picked));
      dateValueToSend = DateFormat("yyyy-MM-dd").format(picked);// user.value.dateOfBirth = formattedDate;
      update([GetBuilderIds.dateOfBirth]);
    }
  }
  
    RxBool isLoadingToUpload = false.obs; 
  Future<void> profileCallback(BuildContext context) async {
    isLoadingToUpload.value = true;
    final bool? isGallaryImagePicker =
        await chooseFromImageSourceSheet(context);
    if (isGallaryImagePicker != null) {
      // if (Platform.isAndroid) {
      //   final hasAgreedToDiscloser =
      //       // ignore: use_build_context_synchronously
      //       await showImagePermissionDiscloserDialog(context);
      //   if (hasAgreedToDiscloser == false) {
      //     return;
      //   }
      // }
      late final Either<bool, File> result;
      if (isGallaryImagePicker) {
        result = await Picker.pickImage(context: context, fromSource: ImageSource.gallery);
      } else {
        result = await Picker.pickImage(context: context, fromSource: ImageSource.camera);
      }
      result.fold((l) {
        isLoadingToUpload.value = false;
      }, (r) {
        profileFile = r;
        update([GetBuilderIds.profileImage]);
        isLoadingToUpload.value = false;
      });
    }
  }
}
