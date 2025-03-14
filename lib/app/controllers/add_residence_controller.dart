
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/create_my_business_controller.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/models/user_model.dart';


class AddResidenceController extends GetxController {
  final CreateMyBusinessController createMyBusinessController = Get.put(CreateMyBusinessController());
final residenceModel = ResidenceModel().obs;

    
  void addResidenceDetails(ResidenceModel value) {
    if(value != null){
    residenceModel.value = value;
    txtControllerPostDistrict.text = residenceModel.value.postcodedistirct ?? '';
    txtControllerHouseNumber.text = residenceModel.value.housenumber ?? '';
    txtControllerStreetName.text = residenceModel.value.streetname ?? '';
    txtControllerArea.text = residenceModel.value.area ?? '';
    txtControllerCity.text = residenceModel.value.city ?? '';
    txtControllerCountry.text = residenceModel.value.country ??'';
    residenceModel.value.fullAddress = txtControllerHouseNumber.text+", "+txtControllerStreetName.text+", "+txtControllerArea.text+", "+txtControllerCity.text+", "+txtControllerCountry.text+".";
    }
   
  }


final TextEditingController txtControllerPostDistrict = TextEditingController();
final TextEditingController txtControllerHouseNumber = TextEditingController();
final TextEditingController txtControllerStreetName = TextEditingController();
final TextEditingController txtControllerArea = TextEditingController();
final TextEditingController txtControllerCity = TextEditingController();
final TextEditingController txtControllerCountry = TextEditingController();

 
     var postCodeList = <PostcodeDistirctData?>[];
     var cityDataList = <CityData?>[];
     var countryDataList = <CountryData?>[];
 
 @override
  void onInit() async {  
    MasterDataModel? masterData = await GS.readMasterApiData();
    if(masterData != null){
        postCodeList = masterData.postcodedistirctdata!;
        cityDataList = masterData.citydata!;
        countryDataList = masterData.countrydata!;
    }   
    super.onInit();
  }


// void showPostcodeDialog(BuildContext context) {
//    showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return PostcodeDialog(
//           selectedPostcode: selectedPostcode,
//           onSelectedPostcode: (value) {            
//               selectedPostcode = value;
//               Navigator.pop(context);            
//           },
//         );
//       },
//     );
//   }
 
 void skipAndGoHome() {  
      
    Get.offAll(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen: false,indexForScreen: 0,));
  }

   bool isFormValid() {

  
      if (txtControllerCountry.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select country from the list.',
          context: Get.context);
      return false;
    }
      if (txtControllerCity.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select city from the list.',
          context: Get.context);
      return false;
    }
     if (txtControllerPostDistrict.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select Post code district.',
          context: Get.context);
      return false;
    }
     
    return true;
  }



  void saveAndGoHome() {   
    if(isFormValid()){
 GS.userData.value!.isresidencecreated! ? postUpdateResidenceApi(isFromSingUp: false) : postCreateResidenceApi(isFromSingUp: true);   
    }   
   
  //  postUpdateResidenceApi(isFromSingUp: true);
  }

   void save() {
    //     print(txtControllerPostDistrict.text);
    //  final residenceModel = ResidenceModel().obs;
    // residenceModel.value.postcodedistirct = txtControllerPostDistrict.text ?? '';
    // residenceModel.value.housenumber  = txtControllerHouseNumber.text?? '';
    // residenceModel.value.streetname  = txtControllerStreetName.text?? '';
    // residenceModel.value.area = txtControllerArea.text ?? '';
    // residenceModel.value.city = txtControllerCity.text ?? '';
    // residenceModel.value.country = txtControllerCountry.text??'';
    // residenceModel.value.fullAddress = txtControllerHouseNumber.text+", "+txtControllerStreetName.text+", "+txtControllerArea.text+", "+txtControllerCity.text+", "+txtControllerCountry.text+".";
    // createMyBusinessController.arrayOfResidence.add(residenceModel.value);
    // print(createMyBusinessController.arrayOfResidence);
    // //  postUpdateResidenceApi(isFromSingUp: false);
   Get.back();
  }

    RxBool isLoading = false.obs;
  Future<void> postUpdateResidenceApi({bool handleErrors = true, bool isFromSingUp = true}) async {
    print('this is edit recidency ======?');
    isLoading.value = true;    

    final apiHelper = ApiHelper(
      serviceName: "update_residence",
      endPoint: ApiPaths.update_residence,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {      
      "postcode_distirct": txtControllerPostDistrict.text,
      "house_number": txtControllerHouseNumber.text,
      "street_name": txtControllerStreetName.text,
      "area": txtControllerArea.text,
      "city": txtControllerCity.text,
      "country": txtControllerCountry.text,
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
          GS.userData.value!.postcodedistirct = txtControllerPostDistrict.text;
          isFromSingUp?
          Get.to(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen: false,indexForScreen: 0,)):
          Get.back();
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

  Future<void> postCreateResidenceApi({bool handleErrors = true, bool isFromSingUp = true}) async {    
    isLoading.value = true;   

  final apiHelper = ApiHelper(
      serviceName: "create_residence",
      endPoint: ApiPaths.create_residence,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {      
      "postcode_district": txtControllerPostDistrict.text,
      "house_number": txtControllerHouseNumber.text,
      "street_name": txtControllerStreetName.text,
      "area": txtControllerArea.text,
      "city": txtControllerCity.text,
      "country": txtControllerCountry.text,
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
          UserModel? userData;
          userData = await GS.readUserData();
          userData?.isresidencecreated = true;
          userData?.postcodedistirct = txtControllerPostDistrict.text;
          GS.writeUserData(userData!);
          isFromSingUp?
          Get.offAll(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen: false,indexForScreen: 0,)):
          Get.back();
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
}
