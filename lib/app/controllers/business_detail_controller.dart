import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/settings/my_business/edit_my_business_screen.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_model.dart';


class BusinessDetailController extends GetxController {
var hasBusinessAccount = GS.userData.value!.isbusinesscreated! ?? false;
var disabledAds = false;

var businessDetails = BusinessModel().obs;
RxString businessCategory = ''.obs;
int currPage = 0;
RxBool isLoadingMore = false.obs;
  late PageController scrollController;


// category
// List<String?> categoryNames = businessDetails.categorydetails!.map((category) => category!.categoryname).toList();
//             businessDetailController.businessCategory = categoryNames.join(',');  



// Get Business Details
  RxBool isLoading = false.obs;
  
  Future<void> getBusinessDetailsApi(
      {bool handleErrors = true}) async {
        isLoading.value = true;
    final apiHelper = ApiHelper(
      serviceName: "get_business_details",
      endPoint:
          ApiPaths.get_business_details,
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    Log.info('get_business_details: $result');
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {        
          final data = r['data'];
         
           businessDetails.value = BusinessModel.fromJson(data);
            List<String?> categoryNames = businessDetails.value.categorydetails!.map((category) => category!.categoryname).toList();
            businessCategory.value = categoryNames.join(', ');  
          
          isLoading.value = false;
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isLoading.value = false;
  }

 //  void goBack() {
  //   Get.offAll(() => HomeScreen(isFromContinueAsGuest:false,isFromChatScreen: false,indexForScreen: 4,));
  // }

   void editBusiness(Function addMarker) {
    Get.to(() =>  EditMyBusinessScreen(businessModel: businessDetails.value ,))!.then((value) 
      {
       print('value ---->>  ${value}');
    if(value != null)
          {           
            // setState({
                businessDetails.value = value;
                addMarker() ;  
                print('businessDetails.value.categorydetails --->> ${businessDetails.value.categorydetails}');         
            // });
             List<String?> categoryNames = businessDetails.value.categorydetails!.map((category) => category!.categoryname).toList();
            businessCategory.value = categoryNames.join(', ');  
            print('businessCategory --->> ${businessCategory}'); 
      getBusinessDetailsApi();
          }     
     }
    );
  }

}
