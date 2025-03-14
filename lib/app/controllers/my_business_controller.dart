import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads/create_ads_screen.dart';
import 'package:team_balance/app/views/settings/my_business/business_details_screen.dart';
import 'package:team_balance/app/views/settings/my_business/create_my_business_screen.dart';
import 'package:team_balance/app/views/settings/my_business/edit_my_business_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_ads_model.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';

class MyBusinessController extends GetxController {
  RxBool hasBusinessAccount =
      GS.userData.value!.isbusinesscreated!.obs ?? false.obs;
  var disabledAds = false;
  var businessDetails = BusinessModel().obs;
  var businessCategory = '';
  int currPage = 1;
  int currPageForEnable = 1;
  int currPageForDisable = 1;
  RxBool isLoadingForFirst = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasLoadMore = true.obs;

  // late PageController scrollController;

  ScrollController listScrollController = ScrollController();
  // late ScrollController listScrollController;

// RxInt totalcreditbalanceforads = 0.obs;

  void onInit() async {
    super.onInit();
    listScrollController.addListener(onLoadMore);
  }

  Future<void> refreshData() async {
    currPage = 1;
    currPageForEnable = 1;
    currPageForDisable = 1;
    isLoadingForFirst.value = true;
    getBusinessDetailsApi(isrefresh: false);
    getAllAds();
  }

  Future<void> refreshAds() async {
    getAllAds();
  }

  void buyMoreAds() {
//  Get.to(() =>  AdsPlanScreen());
  }

  void createAds(BuildContext context) {
    // if(businessDetails.value.totalcreditbalanceforads == 0){

    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //   //     return AlertDialog(
    //   //   shape: RoundedRectangleBorder(
    //   //     borderRadius: BorderRadius.circular(15),
    //   //   ),
    //   //   insetPadding: EdgeInsets.zero,
    //   //   clipBehavior: Clip.antiAliasWithSaveLayer,
    //   //   contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
    //   //   backgroundColor: AppColors.primaryColor,
    //   //   content: SizedBox(
    //   //     height: dynamicSize.height * 0.2,
    //   //     width: dynamicSize.width * 0.65,
    //   //     child: Column(
    //   //       mainAxisSize: MainAxisSize.min,
    //   //       mainAxisAlignment: MainAxisAlignment.center,
    //   //       children: [
    //   //         CircleAvatar(
    //   //           radius: AppSizes.double50,
    //   //           backgroundColor: AppColors.fantedBlueColor,
    //   //           child: Image.asset(
    //   //             AppImages.myBusiness,
    //   //             scale: 3,
    //   //             // color: AppColors.blueThemeColor,
    //   //           ),
    //   //         ),
    //   //         SizedBox(height: AppSizes.double10),
    //   //         Padding(
    //   //           padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
    //   //           child: Text(
    //   //             title,
    //   //             textAlign: TextAlign.center,
    //   //             style: const TextStyle(
    //   //                 color: AppColors.black,
    //   //                 fontWeight: FontWeight.w500,
    //   //                 fontSize: 16),
    //   //           ),
    //   //         ),
    //   //         SizedBox(height: AppSizes.double10),
    //   //       ],
    //   //     ),
    //   //   ),
    //   //   actions: <Widget>[
    //   //     const Divider(height: 0, color: AppColors.lightGrey),
    //   //     Padding(
    //   //       padding: const EdgeInsets.only(left:15.0,right: 15.0,),
    //   //       child: Row(
    //   //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //   //         children: [
    //   //             TextButton(
    //   //              onPressed:(){
    //   //                   Get.back();
    //   //             },
    //   //               child: Text(
    //   //                 ConstantString.cancel.toUpperCase(),
    //   //                 style: const TextStyle(
    //   //                     color: AppColors.mediumGrey,
    //   //                     fontWeight: FontWeight.bold,
    //   //                     fontSize: 15),
    //   //               ),
    //   //             ),
    //   //             Container(
    //   //               width: 1.0,
    //   //               height: AppSizes.double25,
    //   //               color: AppColors.lightGrey,
    //   //             ),
    //   //           TextButton(
    //   //             onPressed:(){
    //   //                   Get.to(() =>  AdsPlanScreen())!.then((value) => Get.back());
    //   //             },
    //   //             child: Text(
    //   //               ConstantString.buy.toUpperCase(),
    //   //               style: const TextStyle(
    //   //                   color: AppColors.textButtonBlueColor,
    //   //                   fontWeight: FontWeight.bold,
    //   //                   fontSize: 15),
    //   //             ),
    //   //           ),
    //   //         ],
    //   //       ),
    //   //     )
    //   //   ],
    //   // );
    //      return TBCustomAlertDialog(
    //           image: AppImages.myBusiness,
    //           title: ConstantString.addMoreAdsMessage,
    //           onTapOption1: () {
    //             Get.back();
    //           },
    //           onTapOption2: () {
    //             Get.back();
    //             //  Get.to(() =>  AdsPlanScreen())!.then((value) => Get.back());
    //           },
    //           option1: ConstantString.cancel.toUpperCase(),
    //           option2: ConstantString.buy.toUpperCase());
    //     },
    //   );
    // }else{
    Get.to(
            () => CreateAdsScreen(
                  onAdCreated: () {
                    refreshAds();
                  },
                ),
            arguments: {
          "businessId": businessDetails.value.id,
          "businesspromotionpostcodes":
              businessDetails.value.businesspromotionpostcodes
        })!
        .then((value) {
      print('value ---->>  ${value}');
      if (value != null && value == true) {
        refreshAds();
      }
    });
    // }
  }

//  void createAds(BuildContext context) {
//   if(businessDetails.value.totalcreditbalanceforads == 0){

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//     //     return AlertDialog(
//     //   shape: RoundedRectangleBorder(
//     //     borderRadius: BorderRadius.circular(15),
//     //   ),
//     //   insetPadding: EdgeInsets.zero,
//     //   clipBehavior: Clip.antiAliasWithSaveLayer,
//     //   contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
//     //   backgroundColor: AppColors.primaryColor,
//     //   content: SizedBox(
//     //     height: dynamicSize.height * 0.2,
//     //     width: dynamicSize.width * 0.65,
//     //     child: Column(
//     //       mainAxisSize: MainAxisSize.min,
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: [
//     //         CircleAvatar(
//     //           radius: AppSizes.double50,
//     //           backgroundColor: AppColors.fantedBlueColor,
//     //           child: Image.asset(
//     //             AppImages.myBusiness,
//     //             scale: 3,
//     //             // color: AppColors.blueThemeColor,
//     //           ),
//     //         ),
//     //         SizedBox(height: AppSizes.double10),
//     //         Padding(
//     //           padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
//     //           child: Text(
//     //             title,
//     //             textAlign: TextAlign.center,
//     //             style: const TextStyle(
//     //                 color: AppColors.black,
//     //                 fontWeight: FontWeight.w500,
//     //                 fontSize: 16),
//     //           ),
//     //         ),
//     //         SizedBox(height: AppSizes.double10),
//     //       ],
//     //     ),
//     //   ),
//     //   actions: <Widget>[
//     //     const Divider(height: 0, color: AppColors.lightGrey),
//     //     Padding(
//     //       padding: const EdgeInsets.only(left:15.0,right: 15.0,),
//     //       child: Row(
//     //         mainAxisAlignment: MainAxisAlignment.spaceAround,
//     //         children: [
//     //             TextButton(
//     //              onPressed:(){
//     //                   Get.back();
//     //             },
//     //               child: Text(
//     //                 ConstantString.cancel.toUpperCase(),
//     //                 style: const TextStyle(
//     //                     color: AppColors.mediumGrey,
//     //                     fontWeight: FontWeight.bold,
//     //                     fontSize: 15),
//     //               ),
//     //             ),
//     //             Container(
//     //               width: 1.0,
//     //               height: AppSizes.double25,
//     //               color: AppColors.lightGrey,
//     //             ),
//     //           TextButton(
//     //             onPressed:(){
//     //                   Get.to(() =>  AdsPlanScreen())!.then((value) => Get.back());
//     //             },
//     //             child: Text(
//     //               ConstantString.buy.toUpperCase(),
//     //               style: const TextStyle(
//     //                   color: AppColors.textButtonBlueColor,
//     //                   fontWeight: FontWeight.bold,
//     //                   fontSize: 15),
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     )
//     //   ],
//     // );
//        return TBCustomAlertDialog(
//             image: AppImages.myBusiness,
//             title: ConstantString.addMoreAdsMessage,
//             onTapOption1: () {
//               Get.back();
//             },
//             onTapOption2: () {
//               Get.back();
//               //  Get.to(() =>  AdsPlanScreen())!.then((value) => Get.back());
//             },
//             option1: ConstantString.cancel.toUpperCase(),
//             option2: ConstantString.buy.toUpperCase());
//       },
//     );
//   }else{
//       Get.to(() =>  CreateAdsScreen(
//           onAdCreated: () {
//             refreshData();
//           },
//       ),arguments: {
//     "businessId":businessDetails.value.id,
//     "businesspromotionpostcodes":businessDetails.value.businesspromotionpostcodes
//   })!.then((value) =>      refreshData());
//   }
//   }

// Get Business Details
  RxBool isLoading = false.obs;

  Future<void> getBusinessDetailsApi(
      {bool handleErrors = true, bool isrefresh = true}) async {
    if (isrefresh) {
      isLoading.value = true;
    }
    isLoading.value = true;
    final apiHelper = ApiHelper(
      serviceName: "get_business_details",
      endPoint: ApiPaths.get_business_details,
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    Log.info('get_business_details: $result');
    result.fold((l) {
      isLoading.value = false;
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          final data = r['data'];
          businessDetails.value = BusinessModel.fromJson(data);
          isLoading.value = false;
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          isLoading.value = false;
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
        isLoading.value = false;
      }
    });
  }

// for getting ads
  RxBool isAdsLoading = false.obs;
  var arrayOfAdsEnable = <BusinessAdvertise>[].obs;
  var arrayOfAdsDisable = <BusinessAdvertise>[].obs;

  var arrayOfAds = <BusinessAdvertise>[].obs;

  Future getAllAds() async {
    getAllAdsApi(
      // fromRefresh: true,
      page: currPage,
      pageSize: 10,
      is_active: 1,
    );
    getAllAdsApi(
        // fromRefresh: true,
        page: currPage,
        pageSize: 10,
        is_active: 0);
  }

  Future<void> getAllAdsApi(
      {bool handleErrors = true,
      bool showLoader = true,
      int page = 1,
      int pageSize = 10,
      int is_active = 1}) async {
    if (page == 1) {
      // if(is_active == 1){
      arrayOfAdsEnable.clear();
      // }else{
      arrayOfAdsDisable.clear();
      // }
      arrayOfAds.clear();
      if (showLoader) {
        isAdsLoading.value = true;
      }
    }
    // isAdsLoading.value = true;
    final apiHelper = ApiHelper(
      serviceName: "get_business_advertisement",
      endPoint: ApiPaths.get_business_advertisement +
          ("page=$page") +
          ("&pageSize=$pageSize") +
          ("&is_active=$is_active"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    Log.info('get_business_advertisement: $result');
    await result.fold((l) {
      isLoading.value = false;
      isAdsLoading.value = false;
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          final data = r['data']['Business_Advertises'];
          if (is_active == 1) {
            // if(isLoadingForFirst.value && disabledAds == false)
            // {
            //   arrayOfAds.addAll(
            //   List<BusinessAdvertise>.from(data.map((x) => BusinessAdvertise.fromJson(x))));
            //   isLoadingForFirst.value = false;
            // }
            Log.success("ArrayOfEnable===> ${data}");
            Log.success("ArrayOfEnable===> ${data.length}");
            arrayOfAdsEnable.addAll(List<BusinessAdvertise>.from(
                data.map((x) => BusinessAdvertise.fromJson(x))));
            isAdsLoading.value = false;
            isLoadingMore.value = false;
          } else {
            arrayOfAdsDisable.addAll(List<BusinessAdvertise>.from(
                data.map((x) => BusinessAdvertise.fromJson(x))));
            isAdsLoading.value = false;
            isLoading.value = false;
          }
          if (data.length < pageSize) {
            Log.success("not has more data");
            hasLoadMore.value = false;
          } else {
            Log.success("has more data");
            hasLoadMore.value = true;
          }
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          isAdsLoading.value = false;
          isLoading.value = false;
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
        isAdsLoading.value = false;
        isLoading.value = false;
      }
    });
  }

  void enableOrDisable(
      BuildContext context, bool disable, int adsId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          return Stack(
            children: [
              TBCustomAlertDialog(
                image: disable ? AppImages.enable : AppImages.disable,
                title: disable
                    ? ConstantString.enableAdMessage
                    : ConstantString.disableAdMessage,
                onTapOption1: () {
                  Get.back();
                },
                onTapOption2: () {
                  postDisableEnableAdsApi(
                      index: index, adsId: adsId.toString());
                },
                option1: ConstantString.cancel.toUpperCase(),
                option2: disable
                    ? ConstantString.enable.toUpperCase()
                    : ConstantString.disable.toUpperCase(),
              ),
              if (isLoadingForDisableEnableAds.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.2), // Semi-transparent overlay
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  //  void enableOrDisable(BuildContext context,bool disable,int adsId,int index) {
  //  showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  // return Obx(() {
  //       if (isLoadingForDisableEnableAds.value) {
  //         return Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       }
  //     {  return TBCustomAlertDialog(
  //           image: disable ?AppImages.enable :AppImages.disable,
  //           title: disable ?ConstantString.enableAdMessage :ConstantString.disableAdMessage,
  //           onTapOption1: () {
  //             Get.back();
  //           },
  //           onTapOption2: () {
  //              postDisableEnableAdsApi(index: index,adsId: adsId.toString());
  //           },
  //           option1: ConstantString.cancel.toUpperCase(),
  //           option2: disable?ConstantString.enable.toUpperCase():ConstantString.disable.toUpperCase());
  //           }
  //     });
  //     },
  //   );
  // }

  void goBack() {
    Get.back();
    // Get.offAll(() => HomeScreen(isFromContinueAsGuest:false,isFromChatScreen: false,indexForScreen: 4,));
  }

  //  void editBusiness() {
  //   Get.to(() =>  EditMyBusinessScreen(businessModel: businessDetails.value,));
  // }

  void businessDetail() {
    Get.to(() => BusinessDetailsScreen(
              businessModelId: businessDetails.value.id!,
              isFromDashBoardScreen: false,
              businessDetails: businessDetails.value,
            ))!
        .then((value) {
      print('value ---->>  ${value}');
      if (value != null) {
        businessDetails.value = value.value;
        // getBusinessDetailsApi();
      }
    });
  }

  Future<void> createMyBusiness() async {
    await Get.to(() => const CreateMyBusinessScreen())!.then(
      (value) {
        if (value != null && value == true) {
          hasBusinessAccount.value = true;
          getBusinessDetailsApi();
          //  getAllAdsApi();
        }
      },
    );
  }

  RxBool isLoadingForAds = false.obs;
  Future<void> postDeleteAdsApi(
      {bool handleErrors = true, required String adsId}) async {
    await GetStorage.init();
    isLoadingForAds.value = true;

    final apiHelper = ApiHelper(
      serviceName: "delete_business_advertisement",
      endPoint: ApiPaths.delete_business_advertisement +
          ("business_advertisement_id=$adsId"),
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {}, isFormData: true);
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
          // Log the array contents for debugging
          Log.info(
              "Current ads in arrayOfAds: ${arrayOfAds.map((ad) => ad.businessadvertisementid).toList()}");

          // Find and remove the ad using adsId
          final adIndex = arrayOfAds.indexWhere(
              (ad) => ad.businessadvertisementid == int.parse(adsId));
          if (adIndex != -1) {
            arrayOfAds.removeAt(adIndex);
            Log.info("Removed ad with ID $adsId at index: $adIndex");

            // Update arrayOfAdsEnable or arrayOfAdsDisable
            if (adIndex < arrayOfAds.length) {
              if (arrayOfAds[adIndex].isactive == true) {
                arrayOfAdsEnable.removeWhere(
                    (ad) => ad.businessadvertisementid == int.parse(adsId));
                Log.info(
                    "Removed from active ads. Remaining active ads: ${arrayOfAdsEnable.length}");
              } else {
                arrayOfAdsDisable.removeWhere(
                    (ad) => ad.businessadvertisementid == int.parse(adsId));
                Log.info(
                    "Removed from inactive ads. Remaining inactive ads: ${arrayOfAdsDisable.length}");
              }
            }
          } else {
            Log.error("Ad with ID $adsId not found in arrayOfAds.");
          }

          showTopFlashMessage(ToastType.success, message.toString());
          Get.back();
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          Get.back();
        }
        isLoadingForAds.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    isLoadingForAds.value = false;
  }

  RxBool isLoadingForDisableEnableAds = false.obs;
  Future<void> postDisableEnableAdsApi(
      {bool handleErrors = true, String adsId = "0", int index = 0}) async {
    await GetStorage.init();
    isLoadingForDisableEnableAds.value = true;

    final apiHelper = ApiHelper(
      serviceName: "disable_enable_business_advertisement",
      endPoint: ApiPaths.disable_enable_business_advertisement +
          ("business_advertisement_id=$adsId"),
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {}, isFormData: true);
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
          if (index >= arrayOfAds.length) {
            Log.error(
                'Index $index out of range for arrayOfAds with length ${arrayOfAds.length}');
            showTopFlashMessage(ToastType.failure, 'Invalid ad index');
            isLoadingForDisableEnableAds.value = false;
            return;
          }

          if (arrayOfAds[index].isactive == false) {
            businessDetails.value.totalcreditbalanceforads =
                (businessDetails.value.totalcreditbalanceforads! - 1);
            showTopFlashMessage(ToastType.success, ConstantString.enableAds);
          } else {
            showTopFlashMessage(ToastType.success, ConstantString.disableAds);
          }

          if (arrayOfAds[index].isactive == true) {
            print('This is isactive true ---->>>');
            arrayOfAds[index].isactive = false;
            arrayOfAdsDisable.add(arrayOfAds[index]);
            arrayOfAdsEnable.removeWhere(
                (ad) => ad.businessadvertisementid == int.parse(adsId));
            arrayOfAds.removeWhere(
                (ad) => ad.businessadvertisementid == int.parse(adsId));
          } else {
            print('This is isactive false ---->>>');
            arrayOfAds[index].isactive = true;
            arrayOfAdsEnable.add(arrayOfAds[index]);
            arrayOfAdsDisable.removeWhere(
                (ad) => ad.businessadvertisementid == int.parse(adsId));
            arrayOfAds.removeWhere(
                (ad) => ad.businessadvertisementid == int.parse(adsId));
          }

          Get.back();
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          Get.back();
        }
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      } finally {
        isLoadingForDisableEnableAds.value = false;
      }
    });

    isLoadingForDisableEnableAds.value = false;
  }

  void deleteAdsClicked(BuildContext context, int adsId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.deletemodal,
            title: ConstantString.deleteAdMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () {
              postDeleteAdsApi(adsId: adsId.toString());
            },
            option1: ConstantString.cancel.toUpperCase(),
            option2: ConstantString.delete.toUpperCase());
      },
    );
  }

  @override
  void onClose() {
    listScrollController.dispose();
    super.onClose();
  }

  void onLoadMore() async {
    if (isLoadingMore.value && !hasLoadMore.value) return;
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      isLoadingMore.value = true;
      currPage = currPage + 1;
      if (disabledAds) {
        currPageForDisable = currPage;
      } else if (disabledAds == false) {
        currPageForEnable = currPage;
      }
      await getAllAdsApi(
          // fromRefresh: true,
          page: currPage,
          pageSize: 10,
          is_active: disabledAds ? 0 : 1);
    }
  }

  var arrayOfCategory = <CategoryModel>[].obs;
  Future<void> getCategoryApi({bool handleErrors = true}) async {
    isLoading.value = true;
    arrayOfCategory.clear();

    final apiHelper = ApiHelper(
      serviceName: "get_categories",
      endPoint: ApiPaths.get_categories,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.get();
    print("result: $result");

    result.fold(
      (l) => Log.error("Error: $l"),
      (r) async {
        try {
          final status = r['status'];
          if (status == ApiStatus.success) {
            final data = r['data'];
            Log.info("Category data: $data");
            arrayOfCategory.addAll(
              List<CategoryModel>.from(
                  data.map((x) => CategoryModel.fromJson(x))),
            );
          }
          print("message: ${r['message']}");
        } catch (e, stacktrace) {
          Log.error('\n******** $e ********\n$stacktrace');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }
}
