
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_screen.dart';
import 'package:team_balance/app/views/settings/my_business/business_details_screen.dart';
import 'package:team_balance/app/views/settings/my_business/category_screen.dart';
import 'package:team_balance/app/views/settings/my_business/category_screen_for_edit.dart';
import 'package:team_balance/app/views/settings/my_business/create_my_business_screen.dart';
import 'package:team_balance/app/views/settings/my_business/view_residence_screen.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/app/wights/dialogs/image_permission_discloser_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';


class EditMyBusinessController extends GetxController {

final businessModelData = BusinessModel().obs;
final TextEditingController txtBusinessLocation = TextEditingController();
final TextEditingController txtBusinessName = TextEditingController();
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

 var residenceModel = ResidenceModel();
  var selectedResidenceModel = <BusinessPromotionPostcode?>[].obs;
  
   RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
var fullAddress = '' ;
var postcoDedistirct = '';
  var arrayOfCategory = <CategoryModel>[].obs;
    // var arrayOfResidence = <ResidenceModel>[].obs;
    var arrayOfResidence = <PostcodeDistirctData?>[]?.obs; 

    // var arrayOfResidence = [];
    RxList selectedResidence = [].obs;
    RxList enableDisableResidence = [].obs;

var isResidenceAdded = true;
var residenceCount = 1;
File? businessLogo;
String? businesslogo;
  void addbusinessModelDetails(BusinessModel value) {
    businessModelData.value = value;  
    businesslogo =  businessModelData.value.businesslogo;
    txtBusinessLocation.text = businessModelData.value.location!;
    txtBusinessName.text = businessModelData.value.businessname!;
    latitude.value = double.parse(businessModelData.value.latitude!);
    longitude.value = double.parse(businessModelData.value.longitude!); 
      
      // for selected Categories in business
      selectedCategories.addAll(businessModelData.value.categorydetails!.map<int>((category) => category!.id!).toList());
      
      // for enable Disable Residence
      // enableDisableResidence.addAll(businessModelData.value.businesspromotionpostcodes!.map<int>((location) => location!.isactive == true ? location!.id!:0).toList());
       
       selectedResidenceModel.value = businessModelData.value.businesspromotionpostcodes!;

      selectedResidence.addAll(
  businessModelData.value.businesspromotionpostcodes!
    .where((residence) => residence!.isactive!)
    .map<int>((residence) => residence!.postcodedistrictid!)
    .toList()
);
      print('t hisi ====>>>${selectedResidence}');
  }

  
 RxList selectedCategories = [].obs;
 RxList addRemoveCategories = [].obs;


RxBool isLoading = false.obs;
RxBool isLoadingForCategory = false.obs;

      Future<void> getCategoryApi({bool handleErrors = true}) async {        
        isLoadingForCategory.value = true;
        arrayOfCategory.clear();
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "get_categories",
      endPoint: ApiPaths.get_categories,
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
          Log.info("Category data: $data");
            arrayOfCategory.addAll(
              List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))));
          // Log.success("userData: $userData");
          // await GS.writeMasterApiData(masterApiData);
        } 
        print("message: $message");
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    isLoadingForCategory.value = false;
  }



  void editPostCodeDistrict(String name) {
    businessModelData.value.businessname = name;
  }

    void addPostCodeDistrict(String name) {
    businessModelData.value.businessname = name;
  }


// final TextEditingController txtBusinessName = TextEditingController();
// final TextEditingController txtBusinessLocation = TextEditingController();




Future<void> addLogoCallback(BuildContext context) async {
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
      result.fold((l) {}, (r) {
        businessLogo = r;
        // update([GetBuilderIds.profileImage]);
      });
    }
  }
 



RxBool isLoadingForEditBusiness = false.obs;
  ///////////////////////////    add Business
  Future<void> postEditBusinessApi(    
      {bool handleErrors = true, }) async {
        isLoadingForEditBusiness.value = true;
 
 List<int> uniqueIdsList = [];
  for (var id in addRemoveCategories) {
    if (!uniqueIdsList.contains(id)) {
      uniqueIdsList.add(id); 
    }
  }
String commaSeparatedIds = addRemoveCategories.join(',');
String selectedResidenceIds = selectedResidence.join(',');
String enableDisableResidenceIds = enableDisableResidence.join(',');
// print('this are enable Disable Residences : =====> ${enableDisableResidenceIds}');
print('this are commaSeparatedIds : =====> ${commaSeparatedIds}');
// print('this are selectedResidenceIds : =====> ${selectedResidenceIds}');

// print('this are latitude : =====> ${latitude.value}');
// print('this are longitude : =====> ${longitude.value}');
    // Get.to(() => const AdsPlanScreen());
    GS.userData.value!.isbusinesscreated = true;
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.update_business_details,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

   final result = await apiHelper.postMultipart(
        body:{
          "business_id":businessModelData.value.id,
          "business_name": txtBusinessName.text,
          "location": txtBusinessLocation.text=='' ? businessModelData.value.location! : txtBusinessLocation.text!,
          "latitude":latitude.value,
          "longitude":longitude.value,
          "categories":commaSeparatedIds,
          "new_business_promotion_postcode":selectedResidenceIds,
          "business_promotion_postcode_id":enableDisableResidenceIds,         
          // "promotion_postcodes":commaSeparatedIdsResidence,
        },
        imageFile: businessLogo == null ? {}:{
          "business_logo": [businessLogo!],
        },
      );
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
        if (status == ApiStatus.success) {   
           showTopFlashMessage(ToastType.success, message.toString());
          businessModelData.value = BusinessModel.fromJson(data);
          //  List<String?> categoryNames = businessModelData.value.categorydetails!.map((category) => category!.categoryname).toList();
          //  var businessCategory = categoryNames.join(', ');  
          //   print('businessCategory updated --->> ${r['data']['category_details']}'); 
        Get.back(result: businessModelData.value);           
                     
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          Get.back();
        }
          isLoadingForEditBusiness.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
          isLoadingForEditBusiness.value = false;
      }
        isLoadingForEditBusiness.value = false;
    });    
  }




 void viewResidence() {
    Get.to(() =>  ViewResidenceScreen(isFromHomeScreen: false,));
  }


   bool isFormValid() {

     if (businessModelData.value.businessname == '') {
      showTopFlashMessage(ToastType.info, 'Please select Business Name for you business.',
          context: Get.context);
      return false;
    }
  
  List<int> categoryDetailsIds = businessModelData.value.categorydetails!.map((category) => category!.id!).toList();
  categoryDetailsIds.sort();
  addRemoveCategories.sort();
       if (categoryDetailsIds.length == addRemoveCategories.length &&
         categoryDetailsIds.every((id) => addRemoveCategories.contains(id))) {
      showTopFlashMessage(ToastType.info, 'Please select Categories for you business.',
          context: Get.context);
      return false;
    } 
    return true;
  }

  void saveMyBusiness() {
    if(isFormValid()){
      print("latitude ==> ${latitude.value}");
      print("latitude ==> ${longitude.value}");
    postEditBusinessApi();
    // Get.back();
    }
  
  }

   void getCategory() {
   Get.to(() =>  CategoryScreenForEdit());
  }

   void addResidence() {
   Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isForEditResidenceAddress: false,isFromSignUpScreen: false,residenceModel: residenceModel))!.then((value) => isResidenceAdded = true);
   
  }

   void editResidence() {
   Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isForEditResidenceAddress: true,isFromSignUpScreen: false,residenceModel: residenceModel))!.then((value) => isResidenceAdded = true);
   
  }

}
