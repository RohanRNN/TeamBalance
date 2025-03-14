
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';
import 'package:team_balance/app/controllers/ads_plan_controller.dart';
import 'package:team_balance/app/wights/plans_wights.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/in_app_purchase.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class AdsPlanScreen extends StatefulWidget {
  const AdsPlanScreen({super.key});

  @override
  State<AdsPlanScreen> createState() => _AdsPlanScreenState();
}

class _AdsPlanScreenState extends State<AdsPlanScreen> {
  final AdsPlanController adsPlanController = Get.put(AdsPlanController());
  IApEngine iApEngine = IApEngine();
  // late ProductDetailsResponse productDetailsResponse;
  @override
  void initState() {
    adsPlanController.getAllPlansApi(
      fromRefresh: false,
      page: 1,
      pageSize: 10
    );
    fetchProducts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchProducts() async {
    iApEngine.getIsAvailable().then((value) => print('this is getIsAvailable ====>>>>> ${value}'));

List <ProductId> storeProductIds = <ProductId>[
  ProductId(id: 'basic_plan_10_ads', isConsumable: true)
];
    await iApEngine.queryProducts(storeProductIds).then((response) => 
    {
      // productDetailsResponse = response,
      print('this is response====>>>>>>>>>${response.productDetails}'),
     print('this is notFoundIDs ====>>>>>>>>>${response.notFoundIDs}')
    }
    );
  }



  @override
  Widget build(BuildContext context) {
    print('this  are new === >>');
    const imageScale = 2.5;
    var deviceSize = MediaQuery.of(context).size; 
       return Scaffold(
          extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
       backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text(ConstantString.premiumPlans,style: tbScreenBodyTitle(),),
            InkWell(
              onTap: () {
                adsPlanController.planHistoryClicked();
              },
              child: Text(ConstantString.history.toUpperCase(),style: TextStyle(
           fontSize:15,
           color:AppColors.textButtonTextColor,
           fontWeight: FontWeight.w600,
          //  fontFamily: FontFamilyName.montserrat
         ),)),
          ],
        ),
      ),


      // body: 
      // Platform.isIOS?
      // Obx(() {
      //   //  if (InAppPurchaseUtils.inAppPurchaseUtilsInstance.products == null) {
      //   if (InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.isEmpty) {
      //     return Center(
      //       child: CircularProgressIndicator(),
      //     );
      //   } else {
      //     return ListView.builder(
      //       itemCount: InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.length,
      //       itemBuilder: (context, index) {
      //         final product = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products[index];
      //         return ListTile(
      //           title: Text(product.title),
      //           subtitle: Text(product.description),
      //           trailing: TextButton(
      //             child: Text(product.price),
      //             onPressed: () {
      //             setState(() {
      //                 adsPlanController.productIdValus = product.id;
      //             });
      //               // InAppPurchaseUtils.inAppPurchaseUtilsInstance.purchaseProduct(product.id);
      //             },
      //           ),
      //         );
      //       },
      //     );
      //   }
      // }): Obx(() {
      //    if (InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.isEmpty) {
      //     return Center(
      //       child: CircularProgressIndicator(),
      //     );
      //   } else {
      //     return ListView.builder(
      //       itemCount: InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.length,
      //       itemBuilder: (context, index) {
      //         final product = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products[index];
      //         return ListTile(
      //           title: Text(product.title),
      //           subtitle: Text(product.description),
      //           trailing: TextButton(
      //             child: Text(product.price),
      //             onPressed: () {
      //             setState(() {
      //                 adsPlanController.productIdValus = product.id;
      //             });
      //               // InAppPurchaseAndroidUtils.inAppPurchaseUtilsInstance.purchaseProduct(product.id);
      //             },
      //           ),
      //         );
      //       },
      //     );
      //   }
      // }),
           body:  Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:SafeArea(
          child: Obx(() => adsPlanController.isLoading.value ? Center(child: AppLoader(),): ListView.builder(
            itemCount: adsPlanController.arrayOfPlans.length, 
            itemBuilder:  (BuildContext, index)=>InkWell(
              onTap: () {                 
                adsPlanController.currentPlanSelecte.value = index;              
              },
              child: PremiumPlansWidget(planModel: adsPlanController.arrayOfPlans[index],index: index,))))
        ),
      ),
          bottomNavigationBar:  SizedBox(
        height: AppSizes.double100,
        child: Center(child: Container(   
                     height: 55,
                    width: deviceSize.width*.68,                 
                    // height: deviceSize.height*.062,
                    // width: deviceSize.width*.68,
                    decoration: BoxDecoration(
                    gradient: AppColors.appGraadient,                  
                    borderRadius: BorderRadius.circular(18.0)
                    ),
                      child: InkWell(
                    onTap: () {   
                      adsPlanController.clickedOnPayNow(context,'basic_plan_10_ads');         
                    //  adsPlanController.clickedOnPayNow(context,adsPlanController.productIdValus[]);
                    print('this is index == >${adsPlanController.productIdValus}');
                    // adsPlanController.payNow(context);
                    },
                    child:  Center(
                    child: Text(
                      ConstantString.payNow,
                      style: tbTextButton(),
                    ),
                    ),
                    ),
                    ),),)
    
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:team_balance/in_app_purchase.dart';// Import your InAppPurchaseUtils class

// class AdsPlanScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('In-App Purchases'),
//       ),
//       body: Obx(() {
//         if (InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.isEmpty) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         } else {
//           return ListView.builder(
//             itemCount: InAppPurchaseUtils.inAppPurchaseUtilsInstance.products.length,
//             itemBuilder: (context, index) {
//               final product = InAppPurchaseUtils.inAppPurchaseUtilsInstance.products[index];
//               return ListTile(
//                 title: Text(product.title),
//                 subtitle: Text(product.description),
//                 trailing: TextButton(
//                   child: Text(product.price),
//                   onPressed: () {
//                     InAppPurchaseUtils.inAppPurchaseUtilsInstance.buyConsumableProductForAndroid(product.id);
//                   },
//                 ),
//               );
//             },
//           );
//         }
//       }),
//     );
//   }
// }
