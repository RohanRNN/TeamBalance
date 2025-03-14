import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:onepref/onepref.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class InAppPurchaseUtils extends GetxController {
  InAppPurchaseUtils._();
  late StreamSubscription<List<PurchaseDetails>> _purchasesSubscription;
  static final InAppPurchaseUtils _instance = InAppPurchaseUtils._();
  static InAppPurchaseUtils get inAppPurchaseUtilsInstance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  final RxList<ProductDetails> products = <ProductDetails>[].obs; 
   IApEngine iApEngine = IApEngine();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    _purchasesSubscription.cancel();
    super.onClose();
  }

          final storage = FlutterSecureStorage();
          static const serviceAccountKey = 'service_account_key';// Key for secure storage

          Future<Map<String, dynamic>> getServiceAccountCredentials() async {
            String? credentialsJson = await storage.read(key: serviceAccountKey);
            if (credentialsJson == null) {
              throw Exception("Service account credentials not found");
            }
            return jsonDecode(credentialsJson);
          }


  Future<void> initialize() async {
    print('Inilixzation for new code =======>>>>>>>');
    if((await _iap.isAvailable())){
 print('Inilixzation for new code 1111111=======>>>>>>>');
    }
      if(!(await _iap.isAvailable())){
 print('Inilixzation for new code 22222222=======>>>>>>>');
    }
    if(!(await _iap.isAvailable())) return;

  
    _purchasesSubscription = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _purchasesSubscription.cancel();
      },
      onError: (error) { },
    );
    
   if(Platform.isAndroid){
    
      await fetchProductsForAndroid();
   }else if(Platform.isIOS){
     await fetchProductsForIos();
   }else{
    showTopFlashMessage(ToastType.failure, 'Invalid Platform');
   }
  }

  Future<void> fetchProductsForIos() async {
    const Set<String> _kIds = <String>{'basic_plan_10_ads'}; 
      print('productDetails for new code 3333333=======>>>>>>');
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      print('productDetails for new code =======>>>>>>>${response.productDetails.toString()}');

    if (response.notFoundIDs.isNotEmpty) {
      return;
    }
  
    products.assignAll(response.productDetails); 
  }

Future<void> fetchProductsForAndroid() async {
  
   /////////// add proper product ids here 
    const Set<String> _kIds = <String>{'500character','5000character','500_character_2'}; 
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      print('productDetails for new code =======>>>>>>>${response.productDetails}');


// List <ProductId> storeProductIds = <ProductId>[
//   ProductId(id: '500character', isConsumable: true),
//   ProductId(id: 'com.addcount', isConsumable: true)
// ];
//    final ProductDetailsResponse response = await iApEngine.queryProducts(storeProductIds);
//     if (response.notFoundIDs.isNotEmpty) {
//       return;
//     }
//      print('ProductDetailsResponse  ----=======>>>>>>> ${response}');
    products.assignAll(response.productDetails); 
  }

  void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    print(purchaseDetailsList.length);
    print(purchaseDetailsList[0].productID);
    for (int index = 0 ; index < purchaseDetailsList.length; index++) {
      print('this is status =====>>>>${purchaseDetailsList[index].status}');
      var purchaseStatus = purchaseDetailsList[index].status;
      switch (purchaseDetailsList[index].status) {
        case PurchaseStatus.pending:
          print(' purchase is in pending ');
          continue;
        case PurchaseStatus.error:
          //  _onPurchaseFailed();
          // print(' purchase error ');
          break;
        case PurchaseStatus.canceled:
         showTopFlashMessage(ToastType.failure, purchaseDetailsList[index].status.toString());
          // print(' purchase cancel ');
          // _onPurchaseFailed();
          break;
        case PurchaseStatus.purchased:
          _onPurchaseSuccess(purchaseDetailsList[index]);
          break;
        case PurchaseStatus.restored:
          print(' purchase restore ');
          break;
      }

      if (purchaseDetailsList[index].pendingCompletePurchase) {
   
         await _iap.completePurchase(purchaseDetailsList[index]).then((value) async {        
              if(purchaseStatus == PurchaseStatus.purchased){            
                  final receipt = purchaseDetailsList[index].verificationData.localVerificationData; 

       if(Platform.isAndroid){
           await verifyPurchase(purchaseDetailsList[index]);              
       }else if(Platform.isIOS){  
         _onPurchaseSuccess(purchaseDetailsList[index]);
            // final validationResponse = await _validateReceiptWithApple(receipt);
            // if (validationResponse['status'] == 1) {           
            //    await postPurchasePlanDetails();
            //   _onPurchaseSuccess(purchaseDetailsList[index]);
            // } else {
            //   _onPurchaseFailed();
            // }  
              
             }else{
          showTopFlashMessage(ToastType.failure, 'Invalid Platform'); 
       }     
          
          }
        });
      
      }           
    }
  }


    Future<void> postPurchasePlanDetails({bool handleErrors = true, Map<String, dynamic>? body}) async { 
    final apiHelper = ApiHelper(
      serviceName: "post_purchase_plan_details",
      endPoint: ApiPaths.post_purchase_plan_details,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );
  
    final result = await apiHelper.post(body: {      
                 "plan_id": "1",
                 "transaction_id": "demo-123",
                 "recipt": "demo-recipt"
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
        if (status == ApiStatus.success) {
          showTopFlashMessage(ToastType.success, message.toString());
        } else if(status == ApiStatus.failed){
          showTopFlashMessage(ToastType.failure, message.toString());
        }else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }

// ///////////////////////////  for ios
//    Future<Map<String, dynamic>> _validateReceiptWithApple(String? receipt) async {
//                   // const String appleVerifyReceiptUrl = 'https://buy.itunes.apple.com/verifyReceipt'; // For production
//                   const String appleVerifyReceiptUrl = 'https://sandbox.itunes.apple.com/verifyReceipt'; // For sandbox

//                   final response = await http.post(
//                     Uri.parse(appleVerifyReceiptUrl),
//                     headers: {'Content-Type': 'application/json'},
//                     body: jsonEncode({
//                       'receipt-data': receipt,
//                       'password': 'your-apple-shared-secret', // Your shared secret
//                     }),
//                   );

//                   if (response.statusCode == 200) {
//                     return jsonDecode(response.body);
//                   } else {
//                     throw Exception('Failed to validate receipt');
//                   }
//                 }


///////////////////////////// for android
Future<void> verifyPurchase(PurchaseDetails purchaseDetails) async {
  final credentials = await getServiceAccountCredentials();
  final accountCredentials = auth.ServiceAccountCredentials.fromJson(credentials);
  final scopes = ['https://www.googleapis.com/auth/androidpublisher'];

  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
  
  final String packageName = 'com.demoteam.team_balance';
  final String productId = purchaseDetails.productID;
  final String token = purchaseDetails.verificationData.serverVerificationData;

  final response = await client.get(
    Uri.parse('https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/purchases/products/$productId/tokens/$token')
  );

  if (response.statusCode == 200) {    
    final receiptData = jsonDecode(response.body);
      await postPurchasePlanDetails();
    // Handle the receipt data
  } else {
        print('Verification failed: ${response.body}');
  }
}

  // void purchaseProduct(String productId) {
  //   // Implementation for purchasing a product
  // }
  void _onPurchaseSuccess(PurchaseDetails purchaseDetails) {
    print('purchaseDetails ===== >>>>   ${purchaseDetails.verificationData.localVerificationData}');
     var isTest = true;
     try{
      print('Inside try block ');
    FlutterInappPurchase.instance.validateReceiptIos(
      receiptBody: {
      'receipt-data': purchaseDetails.verificationData.localVerificationData,
      // 'password': '4302616d9d8c4b2bbe9d1751a5a277b8'
      'password': AppConfig.validateReceiptIosPassword
    },isTest: isTest
    ).then((value) => () {
      print('Inside FlutterInappPurchase ');
      print('validateReceiptIos ====== >>>> ${value.body}');
      var valueBody = jsonDecode(value.body);
      postPurchasePlanDetails(body: {
                 "plan_id": valueBody['receipt']['in_app'][0]['product_id'],
                 "transaction_id": valueBody['receipt']['in_app'][0]['transaction_id'],
                 "recipt":  purchaseDetails.verificationData.localVerificationData
      });
    });}catch(error){
      print('Inside catch error --> ${error}');
    }    
  }

  void _onPurchaseFailed() {
     showTopFlashMessage(ToastType.failure, 'Purchase failed, try again after sometime.');
    // Implement your logic for failed purchase
  }

    //  Future<http.Response> validateReceiptIos(receiptBody,isTest) async {
    //       final String url = isTest
    //         ? 'https://sandbox.itunes.apple.com/verifyReceipt'
    //          : 'https://buy.itunes.apple.com/verifyReceipt';
    //        return  await http.post(
    //        Uri.parse(url),
    //         headers: {
    //         'Accept': 'application/json',
    //          'Content-Type': 'application/json',
    //           },
    //         body: json.encode(receiptBody),
    //           );
    //          }

  // logic for purchasing ads
  Future<void> buyConsumableProductForIos(String productId) async {
    print('Inside buyConsumableProductForIos ======>');
      try {
           Set<String> productIds = {productId};
        final ProductDetailsResponse productDetailsResponse = 
                  await _iap.queryProductDetails(productIds);
                  print('productDetailsResponse${productDetailsResponse.productDetails}');
        if (productDetailsResponse == null) {
          // Product not found
          return;
        }          

        final PurchaseParam purchaseParam = 
                             PurchaseParam(productDetails: productDetailsResponse.productDetails.first);
       await _iap.buyConsumable(purchaseParam: purchaseParam,autoConsume: true);
      } catch (e) {
        print('Failed to buy plan: $e');
      }
    }

      // logic for purchasing ads
  Future<void> buyConsumableProductForAndroid(String productId) async {
    print('Inside buyConsumableProduct ======>  productId ===>>>>> ${productId}');
      try {
        List <ProductId> storeProductIds = <ProductId>[
                ProductId(id: productId, isConsumable: true),
              ];
     final ProductDetailsResponse productDetailsResponse =  await iApEngine.queryProducts(storeProductIds);
                print('productDetailsResponse${productDetailsResponse.productDetails.first.id}');
        if (productDetailsResponse == null) {
          // Product not found
          return;
        }      

        final PurchaseParam purchaseParam = 
                             PurchaseParam(productDetails: productDetailsResponse.productDetails.first);
                             await _iap.buyConsumable(purchaseParam: purchaseParam);
      //  await iApEngine.inAppPurchase.buyConsumable(purchaseParam: purchaseParam,autoConsume: true);
      } catch (e) {
        // Handle purchase error
        print('Failed to buy plan: $e');
      }
    }
}
