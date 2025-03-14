
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_history_screen.dart';
import 'package:team_balance/app/views/settings/my_business/my_business_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/in_app_purchase.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/plans_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';


class AdsPlanController extends GetxController {
     static const imageScale = 2.5;
RxInt currentPlanSelecte = 0.obs; 

var productIdValus = '';

var planLogo = [AppImages.basic,AppImages.advance,AppImages.premium];


  RxBool isLoading = false.obs;
  var arrayOfPlans = <PlanModel>[].obs;
  Future<void> getAllPlansApi({
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
      serviceName: "get_all_advertisements",
      endPoint: ApiPaths.get_plans + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    if(page == 1){
      arrayOfPlans.clear();
    }
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1) {
            arrayOfPlans.clear();
          }
          final data = r['data']['plans'];
          arrayOfPlans.addAll(
              List<PlanModel>.from(data.map((x) => PlanModel.fromJson(x))));
                  for (var plan in arrayOfPlans) {
      plan.localprice = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.value[0].price;
      plan.planidentifier = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.value[0].id;;
    }
          isLoading.value = false;
          Log.info("Plans Data: ${arrayOfPlans}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        } catch (e, stacktrace) {
          print('\n******** $e ********\n$stacktrace');
        }
      });
      isLoading.value = false;
    }

////////////////    Plans History API
  // var arrayOfPlansHistory = <PlanModel>[].obs;
  // Future<void> getAllPlansHistoryApi({
  //   bool fromRefresh = false,
  //   int page = 1,
  //   int pageSize = 10,
  // }) async {
  //   if (fromRefresh) {
  //     isLoading.value = false;
  //   } else {
  //     isLoading.value = true;
  //   }

  //   final apiHelper = ApiHelper(
  //     serviceName: "get_all_advertisements",
  //     endPoint: ApiPaths.get_plans + ("page=$page") + ("&pageSize=$pageSize"),
  //     showErrorDialog: false,
  //   );
  //   if(page == 1){
  //     arrayOfPlans.clear();
  //   }
  //   final result = await apiHelper.get();
  //   print("result: $result");
  //   result.fold((l) {}, (r) {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //         if (page == 1) {
  //           arrayOfPlans.clear();
  //         }
  //         final data = r['data']['plans'];
  //         arrayOfPlans.addAll(
  //             List<PlanModel>.from(data.map((x) => PlanModel.fromJson(x))));
  //                 for (var plan in arrayOfPlans) {
  //     plan.localprice = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.value[0].price;
  //     plan.planidentifier = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.value[0].id;;
  //   }
  //         isLoading.value = false;
  //         Log.info("Plans Data: ${arrayOfPlans}");
  //       } else {
  //         showTopFlashMessage(ToastType.failure, message.toString());
  //       }
  //       } catch (e, stacktrace) {
  //         print('\n******** $e ********\n$stacktrace');
  //       }
  //     });
  //     isLoading.value = false;
  //   }



   
  void planHistoryClicked() {
   Get.to(() => const AdsPlanHistoryScreen());
  }

   void payNowClicked() {
 
  }

   void clickedOnPayNow(BuildContext context,String productId) {
    print('This is productId ====>>>> ${productId}');
    if(Platform.isAndroid){
      InAppPurchaseUtils.inAppPurchaseUtilsInstance.buyConsumableProductForAndroid(productId);
    }else if(Platform.isIOS){
      InAppPurchaseUtils.inAppPurchaseUtilsInstance.buyConsumableProductForIos(productId);
    }else{
       showTopFlashMessage(ToastType.failure, 'Invalid Platform');
    }
   }


   void payNow(BuildContext context) {
     var deviceSize = MediaQuery.of(context).size; 
    showDialog(
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
              child:Image.asset(AppImages.uploadsuccess,scale: imageScale,),
            ),
            SizedBox(height: AppSizes.double10),
            Padding(
              padding: const EdgeInsets.only(top:8.0,left: 30,right: 30),
              child: Text(
                "Paymen Successful!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: FontFamilyName.montserrat,
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
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
                 Get.offAll(() => const MyBusinessScreen());
              },
              child: Text('OKAY!'   ,           
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
    );
  }

// login for in_app_purchase
// Future<void> buyConsumableProduct(String productId) async {
//     try {
//       Set<String> productIds = {newProductId};

//       final ProductDetails productDetails = 
//                 await _iap.queryProductDetails(productId);
//       if (productDetails == null) {
//         // Product not found
//         return;
//       }
      
//       final PurchaseParam purchaseParam = 
//                            PurchaseParam(productDetails: productDetails.first);
//      await _iap.buyConsumable(purchaseParam: purchaseParam,autoConsume: true);
//     } catch (e) {
//       // Handle purchase error
//       print('Failed to buy plan: $e');
//     }
//   }


}
