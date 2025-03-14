
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_screen.dart';
import 'package:team_balance/app/views/settings/my_business/category_screen.dart';
import 'package:team_balance/app/views/settings/my_business/create_my_business_screen.dart';
import 'package:team_balance/app/views/settings/my_business/my_business_screen.dart';
import 'package:team_balance/app/views/settings/my_business/view_residence_screen.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/app/wights/dialogs/image_permission_discloser_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/models/user_model.dart';


class CreateMyBusinessController extends GetxController {
final TextEditingController txtBusinessName = TextEditingController();
final TextEditingController txtBusinessLocation = TextEditingController();
final TextEditingController txtControllerCity = TextEditingController();
final TextEditingController txtControllerCountry = TextEditingController();
  var postCodeList = <PostcodeDistirctData?>[];
     var cityDataList = <CityData?>[];
     var countryDataList = <CountryData?>[];
 var residenceModel = ResidenceModel();
  RxBool isLocationGranted = false.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
var fullAddress = '' ;
var postcoDedistirct = '';
  var arrayOfCategory = <CategoryModel>[].obs;
    RxList selectedCategories = [].obs;
    // var arrayOfResidence = <ResidenceModel>[].obs;
      var arrayOfResidence = <PostcodeDistirctData?>[]?.obs; 
    // var arrayOfResidence = GS.masterApiData.value!.postcodedistirctdata;
    // var arrayOfResidence = [];
    RxList selectedResidence = [].obs;

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

void _showPermissionDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(ConstantString.locationPermissionRequired,
        style: TextStyle(fontFamily: FontFamilyName.montserrat),
        textAlign: TextAlign.center,),
        content: Text(
            ConstantString.locationPermissionRequiredText,
             style: TextStyle(fontFamily: FontFamilyName.montserrat),
        textAlign: TextAlign.center,),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Open Settings'),
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings(); // This opens the device settings
            },
          ),
        ],
      );
    },);
    }

  void getCurrentLocation(BuildContext context) async {
    isLocationGranted.value = false;
  LocationPermission permission = await Geolocator.checkPermission();
  print('permission =====>>>  ${permission} ');
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) { 
       _showPermissionDialog(context);
       isLocationGranted.value = true;
      print("Location permission denied");
      return;
    }
  }
  // Get the current location
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  latitude.value = position.latitude;
  longitude.value = position.longitude;
  addMarker();
  print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
}

RxSet<Marker> markers = <Marker>{}.obs;

  Future<void> addMarker() async {
     final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.locationMarkar,
    );
    
    final marker = Marker(
      markerId: MarkerId('uniqueMarkerId1'),
      position: LatLng(double.tryParse(latitude.value.toString()!)!, double.tryParse(longitude.value.toString()!)! ), // Coordinates for the marker
      infoWindow: InfoWindow(
        title: 'San Francisco',
        snippet: 'A cool place to visit',
      ),
      icon: markerIcon,
    );
      markers.add(marker);    
  }
     RxBool isLoading = false.obs;
  Future<void> getResidenceApi({bool handleErrors = true}) async {
    isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "get_residence",
      endPoint: ApiPaths.get_residence,
      showErrorDialog: handleErrors,
      // showTransparentOverlay: true,
    );

    final result = await apiHelper.get();

    Log.info("result: $result");
    await result.fold((l) {}, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        final data = r['data'];
        print('this is new testign ==========>');  
        print(r['status']);        
        if (status == ApiStatus.success) {
          residenceModel = ResidenceModel.fromJson(data);           
          print('this is =======>');
          print(residenceModel);
           fullAddress = '${residenceModel?.housenumber! ?? ''}, ${residenceModel?.streetname! ?? ''}, ${residenceModel?.area! ?? ''}, ${residenceModel?.city! ?? ''}, ${residenceModel?.country! ?? ''} ';
        
           residenceModel = ResidenceModel.fromJson(data);
          // Get.to(() =>  OtpVerificationScreen(isFromProfileScreen: false,isFromSignUpScreen: true,));
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

// Future<void> getCategoryApi({bool handleErrors = true}) async {        
//   isLoading.value = true;
//   arrayOfCategory.clear();

//   final apiHelper = ApiHelper(
//     serviceName: "get_categories",
//     endPoint: ApiPaths.get_categories,
//     showErrorDialog: handleErrors,
//     showTransparentOverlay: true,
//   );

//   final result = await apiHelper.get();
//   print("result: $result");

//   result.fold(
//     (l) => Log.error("Error: $l"), 
//     (r) async {
//       try {
//         final status = r['status'];
//         if (status == ApiStatus.success) {
//           final data = r['data'];
//           Log.info("Category data: $data");
//           arrayOfCategory.addAll(
//             List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
//           );
//         }
//         print("message: ${r['message']}");
//       } catch (e, stacktrace) {
//         Log.error('\n******** $e ********\n$stacktrace');
//       } finally {
//         isLoading.value = false;
//       }
//     },
//   );
// }

      Future<void> getCategoryApi({bool handleErrors = true}) async {        
        isLoading.value = false;
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
    isLoading.value = false;
  }
  
  
  // void toggleCategory(int index) {
  //   selectedCategories[index] = !selectedCategories[index];
  //   update(); // This is needed if you're using GetX to manage state and you're not using Rx types directly in UI
  // }

// var isResidenceAdded = true;
var residenceCount = 1;
File? businessLogo;

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
        result = await Picker.pickImage(context: context, fromSource: ImageSource.gallery,pickOnlyImage: true);
      } else {
        result = await Picker.pickImage(context: context, fromSource: ImageSource.camera, pickOnlyImage: true);
      }
      result.fold((l) {}, (r) {
        businessLogo = r;
      });
    }
  }


RxBool isLoadingForCreateBusiness = false.obs;
var businessDetails = BusinessModel().obs;
  ///////////////////////////    add Business
  Future<void> postCreateBusinessApi(
    
      {bool handleErrors = true, }) async {
        isLoadingForCreateBusiness.value = true;
        List<int?> selectedCategoryIds = selectedCategories.map((index) {
                        return arrayOfCategory[index].id;
                      }).toList();
String commaSeparatedIds = selectedCategoryIds.join(',');

        // List<int?> selectedResidenceIds = selectedResidence.map((index) {
        //                 return arrayOfResidence![index]!.id;
        //               }).toList();
String commaSeparatedIdsResidence = selectedResidence.join(',');
    // Get.to(() => const AdsPlanScreen() );
    GS.userData.value!.isbusinesscreated = true;
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.create_business,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

// print('commaSeparatedIds ===> ${commaSeparatedIds}');

   final result = await apiHelper.postMultipart(
        body:{
          "business_name": txtBusinessName.text,
          "location": txtBusinessLocation.text,
          "latitude":latitude.toString(),
          "longitude":longitude.toString(),
          "categories":commaSeparatedIds,
          "promotion_postcodes":commaSeparatedIdsResidence,
        },
        imageFile:{
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
        if (status == ApiStatus.success) {
          GS.userData.value?.isbusinesscreated = true;
           txtBusinessLocation.text = '';     
             txtBusinessName.text = ''; 
          // final data = r['data'];         
          //  businessDetails.value = BusinessModel.fromJson(data);  
          Get.back(result: true);
          // Get.offAll(() => const MyBusinessScreen());
                
                     
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          Get.back(result: false);
        }
          isLoadingForCreateBusiness.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
          isLoadingForCreateBusiness.value = false;
      }
        isLoadingForCreateBusiness.value = false;
    });    
  }

  

 void viewResidence(int index) {
    Get.to(() =>  ViewResidenceScreen(isFromHomeScreen: false,));
  }

  // void createMyBusiness() {
  //   Get.to(() => const CreateMyBusinessScreen());
  // }

   void getCategory() {
    getCategoryApi();
   Get.to(() =>  CategoryScreen(isFromEditBusinessScreen:false));
  }

   void addResidence() {
   Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isForEditResidenceAddress: false,isFromSignUpScreen: false,residenceModel: residenceModel));
   
  }

   void editResidence() {
   Get.to(() =>  AddResidenceScreen(isFormHomeScreen:false, isForEditResidenceAddress: true,isFromSignUpScreen: true,residenceModel: residenceModel));
    
  }

   bool isFormValid() {

     if (txtBusinessName.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select Business Name for you business.',
          context: Get.context);
      return false;
    }
     if (txtBusinessLocation.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select Location for you business.',
          context: Get.context);
      return false;
    }   
         if (selectedCategories.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select Categories for you business.',
          context: Get.context);
      return false;
    } 
         if (selectedResidence.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please select Post code district for you business.',
          context: Get.context);
      return false;
    } 
   
    return true;
  }


  void submit() {
    // Get.to(() =>  AdsPlanScreen());

    if(isFormValid())
    {
        postCreateBusinessApi();  //  Get.to(() => const AdsPlanScreen() );
    }
    
  }

}
