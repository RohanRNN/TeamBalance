import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/search_post_screen.dart';
import 'package:team_balance/app/views/settings/my_business/add_residence_screen.dart';
import 'package:team_balance/app/views/settings/my_business/business_details_screen.dart';
import 'package:team_balance/app/views/settings/my_business/view_residence_screen.dart';
import 'package:team_balance/app/views/settings/notification_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_ads_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;


class SearchPostController extends GetxController {
     final TextEditingController txtControllerSearchText = TextEditingController();
  var isGuestLogin = false;
  
  var postCode =  GS.userData == null ? 'M9' :GS.userData.value == null ? 'M9' :GS.userData.value!.isresidencecreated! ? GS.userData.value!.postcodedistirct : 'M9';
  static const imageScale = 2.5;
    var refreshKey = GlobalKey<RefreshIndicatorState>();
   int currPage = 0;
   int currAdsPage = 1;
   int currPageForAds = 1;
  RxBool isLoadingMore = false.obs;
    RxBool isLikePost = false.obs;
    RxBool isLikedAnimation = false.obs; 
    var residenceModel = ResidenceModel();
    
 var forceUpdate = GS.userData.value == null ? false: GS.userData.value!.isforceupdate!;   

    late VideoPlayerController videoController;
  late ScrollController scrollController;
 
  final adsImageList = [
    AppImages.postImg1,
    AppImages.postImg2,
    AppImages.postImg3,
    AppImages.postImg4,
    AppImages.postImg5
  ];
   var reportResaonList = <PostReportReason?>[];
 
 @override
  void onInit() async {  
    MasterDataModel? masterData = await GS.readMasterApiData();
    if(masterData != null){
        reportResaonList = masterData!.postreportreasons!;
    }   
    super.onInit();
  }

   @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  //Post like dislike API
Future<void> postLikeDislikeApi({
  bool handleErrors = true,
  int postId = 0,
  int? index,
}) {
  // Use async API call without blocking the UI
  ApiHelper(
    endPoint: ApiPaths.like_dislike_post,
    showErrorDialog: handleErrors,
    showTransparentOverlay: false, // set this to false if it blocks UI
  ).post(
    body: {"post_id": postId.toString()},
    isFormData: true,
  ).then((result) {
    Log.info("result: $result");

    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success && index != null && index < arrayOfPost.length) {
          // Update like status
          // arrayOfPost[index].isliked = r['data']['is_liked'];
          // if(arrayOfPost[index].isliked == 1){
          //     arrayOfPost[index].likedCount = arrayOfPost[index].likedCount! + 1;
          //   }
          //   if(arrayOfPost[index].isliked == 0){
          //     arrayOfPost[index].likedCount = arrayOfPost[index].likedCount! - 1;
          //   }
          Log.info('Post Liked : ${arrayOfPost[index].isliked}');
        } else if (status != ApiStatus.success) {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  });

  // Return immediately without waiting for result
  return Future.value();
}


  // Future<void> postLikeDislikeApi(
  //     {bool handleErrors = true, int postId = 0, int? index}) async {
  //   // update([GetBuilderIds.likePost]);
  //   final apiHelper = ApiHelper(
  //     endPoint: ApiPaths.like_dislike_post,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //   final result = await apiHelper.post(body: {
  //     "post_id": postId.toString(),
  //   }, isFormData: true);
  //   Log.info("result: $result");
  //   await result.fold((l) {}, (r) async {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //         if (index! < arrayOfPost.length) {            
  //           // arrayOfPost[index].isliked = r['data']['is_liked'];
  //           Log.info('Post Liked : ${arrayOfPost[index].isliked}');
  //         }
  //       } else {
  //         showTopFlashMessage(ToastType.failure, message.toString());
  //       }
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  //   // update([GetBuilderIds.likePost]);
  // }



  //Post report API
    Future<void> postReportPostApi(
      {bool handleErrors = true,
      String postId = "0",
      String reasonId = "1",
      int? index}) async {
    // update([GetBuilderIds.likePost]);
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.report_post,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "post_id": postId,
      "report_reason_id": reasonId,
    }, isFormData: true);
    Log.info("result: $result");
    await result.fold((l) {}, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (index! < arrayOfPost.length) {
            arrayOfPost.removeAt(index);
            showTopFlashMessage(
                ToastType.success, 'Post reported successfully');
          }
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    update([GetBuilderIds.likePost]);
  }
  // Future<void> postReportPostApi(
  //     {bool handleErrors = true, String postId = "0", String reasonId = "1", int? index}) async {
  //   // update([GetBuilderIds.likePost]);
  //   final apiHelper = ApiHelper(
  //     endPoint: ApiPaths.report_post,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //   final result = await apiHelper.post(body: {
  //     "post_id": postId,
  //     "report_reason_id": reasonId,
  //   }, isFormData: true);
  //   Log.info("result: $result");
  //   await result.fold((l) {}, (r) async {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //         if (index! < arrayOfPost.length) {  
  //           arrayOfPost.removeAt(index);          
  //           showTopFlashMessage(ToastType.success, 'Post reported successfully');
  //         }
  //       } else {
  //         showTopFlashMessage(ToastType.failure, message.toString());
  //       }
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  //   update([GetBuilderIds.likePost]);
  // }



void setGuestAccount() async{
 isGuestLogin = await GS.readGuestLogin();
}


 void guestLoginClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.guestpopup,
            title: ConstantString.guestAccountMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () async {    
              var deviceToke = '';
  if (GSAPIHeaders.fcmToken!.isNotEmpty) {
    deviceToke = GSAPIHeaders.fcmToken ?? '';
  }
  await GS.clearAll();
  Log.info('LOGOUT TOKE: $deviceToke');
  GSAPIHeaders.fcmToken = deviceToke;
              Get.offAll(() => const LoginScreen());
            },
            option1: ConstantString.cancel.toUpperCase(),
            option2: ConstantString.continueTitle.toUpperCase());
      },
    );
  }

     void reportClicked(BuildContext context, String post_id, int postIndex) {
      var deviceSize = MediaQuery.of(context).size; 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(  
          contentPadding: EdgeInsets.all(10),        
          alignment: Alignment.center,
        title: Text(ConstantString.reportReason,style: TextStyle(fontSize: 18,fontFamily: FontFamilyName.montserrat,fontWeight: FontWeight.w600 ),),
        
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
          content: SizedBox(
            width: deviceSize.width*.9,
            height: deviceSize.height*.25,
            child: ListView.separated(
                itemCount: reportResaonList!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    endIndent: 25,
                   indent:25,
                    color: AppColors.lightGrey, // Color of the divider
                    height: 1, // Thickness of the divider
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(leading:Text(reportResaonList![index]!.reportreason!,style: tbReportReason(),),trailing: Image.asset(AppImages.rememberMeCheck,scale: imageScale,),);
                },
              ),
          ) ,
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: EdgeInsets.only(left:15,right: 15,bottom: 15),
          actions: [Container(                    
                    height: 45.0,
                    width: deviceSize.width*.35,
                    decoration: BoxDecoration(
                    color: AppColors.placeHolderGray,                  
                    borderRadius: BorderRadius.circular(15.0)
                    ),
                      child: InkWell(
                    onTap: () {            
                    Get.back();
                    },
                    child:  Center(
                    child: Text(
                      ConstantString.cancel,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontFamilyName.montserrat
                        ),
                    ),
                    ),
                    ),
                    ),
                    Container(                    
                    height: 45.0,
                    width: deviceSize.width*.35,
                    decoration: BoxDecoration(
                    gradient: AppColors.appGraadient,                  
                    borderRadius: BorderRadius.circular(15.0)
                    ),
                      child: InkWell(
                    onTap: () {            
                     postReportPostApi(postId: post_id, index: postIndex).then((value) => Get.back()) ;
                    },
                    child:  Center(
                    child: Text(
                      ConstantString.update,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamilyName.montserrat
                        ),
                    ),
                    ),
                    ),
                    )
                    ],
        );
      },
    );
  }

 void deletePostClicked(BuildContext context, String post_id, int index)  {
  print('this is inside funtinp --========>');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TBCustomAlertDialog(
            image: AppImages.deletemodal,
            title: ConstantString.deletePostMessage,
            onTapOption1: () {
              Get.back();
            },
            onTapOption2: () {
              Get.back();
               postDeletePostApi(handleErrors: true, postId: post_id, index: index).then((value) => Get.back());
            },
            option1: ConstantString.cancel.toUpperCase(),
            option2: ConstantString.delete.toUpperCase());
      },
    );
  }


  RxBool isLoading = false.obs;
  Future<void> postDeletePostApi({bool handleErrors = true, String postId = "0", int index = 0}) async {
    await GetStorage.init();
    // isLoading.value = true;

    final apiHelper = ApiHelper(
      serviceName: "delete_post",
      endPoint: ApiPaths.delete_post,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {      
         "post_id":postId
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
          arrayOfPost.removeAt(index);
           
           var userData = GS.userData.value;
              if (userData != null) {
                userData.totalposts = GS.userData.value!.totalposts! - 1;
                GS.userData.value = userData;
                await GS.writeUserData(userData);
              }
       showTopFlashMessage(ToastType.success, message.toString());
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
  


    Future<void> deletePostApi({bool handleErrors = true, int post_id = 0}) async {
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "delete_post",
      endPoint: ApiPaths.delete_post,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "post_id":"152"
    }, isFormData: false);
    print("result: $result");
    await result.fold((l) {
      if (l['msg'] == "No JWT-Token found.") {
        clearDataAndNavigateToLogin();
      }
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {          
          showTopFlashMessage(ToastType.success, message.toString());
        } else {
         showTopFlashMessage(ToastType.failure, message.toString());
        }
        print("message: $message");
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
  }

  // Future<void> clickedOnBusinessDetails() async {
  //  Get.to(() =>  BusinessDetailsScreen(businessModelId:138,isFromDashBoardScreen: true,));    
  // }

  Future<void> onRefresh() async {
    print('this is onRefresh ===>');
    refreshKey.currentState?.show(atTop: false);
    // await Future.delayed(const Duration(seconds: 2));

      currPage = 0;
      await getAllPostApi(
        fromRefresh: true,
        fromLoadMore: false,
        page: currPage,
        pageSize: 10,
      );
       currAdsPage = 0;
        await getAllAdsApi(
          fromRefresh: true,
          fromLoadMore: false,
          page: currAdsPage,
          pageSize: 10,
        ); 
      isLoadingMore.value = false;
    
  }

  void onLoadMore() async {
    if (isLoadingMore.value) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isLoadingMore.value = true;
        currPage = currPage + 1;
        await getAllPostApi(
          fromRefresh: false,
          fromLoadMore: true,
          page: currPage,
          pageSize: 10,
        );
      
      isLoadingMore.value = false;
    }
  }

    void onLoadMoreForAds() async {
    if (isLoadingMore.value) return;    
      isLoadingMore.value = true;
        currAdsPage = currAdsPage + 1;
        await getAllAdsApi(
          fromRefresh: false,
          fromLoadMore: true,
          page: currAdsPage,
          pageSize: 10,
        );      
      isLoadingMore.value = false;    
  }

   //Get all post API
  RxBool isPostLoading = false.obs;
  var arrayOfPost = <PostModel>[].obs;
  Future<void> getAllPostApi({
    bool fromRefresh = false,
    bool fromLoadMore = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (fromRefresh) {
      isPostLoading.value = false;
      // arrayOfPost.clear();
    } else  if (fromLoadMore) {
      isPostLoading.value = false;
      // arrayOfPost.clear();
    } else {
      isPostLoading.value = true;
    }

    final apiHelper = ApiHelper(
      serviceName: "get_allposts",
      endPoint: ApiPaths.get_allposts + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1 || fromRefresh) {
            arrayOfPost.clear();
          }
          final data = r['data']['posts'];
          arrayOfPost.addAll(
              List<PostModel>.from(data.map((x) => PostModel.fromJson(x))));
          isLoadingMore.value = false;
          Log.info("Post Data: ${arrayOfPost.length}");
          Log.info("Post Data: ${arrayOfPost}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isPostLoading.value = false;
  }

   RxBool isAdsLoading = false.obs;
  var arrayOfAds = <BusinessAdvertise>[].obs;
  Future<void> getAllAdsApi({
    bool fromRefresh = false,
    bool fromLoadMore = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (fromRefresh) {
      isAdsLoading.value = false;
    } else if (fromLoadMore) {
      isAdsLoading.value = false;
    }
    else {
      isAdsLoading.value = true;
    }

    final apiHelper = ApiHelper(
      serviceName: "get_all_advertisements",
      endPoint: ApiPaths.get_all_advertisements + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    if(page == 1 || fromRefresh){
      arrayOfAds.clear();
    }
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1) {
            arrayOfAds.clear();
          }
          final data = r['data']['Advertisements'];
          arrayOfAds.addAll(
              List<BusinessAdvertise>.from(data.map((x) => BusinessAdvertise.fromJson(x))));
          isAdsLoading.value = false;
          Log.info("Post Data: ${arrayOfAds}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isAdsLoading.value = false;
  }



   void viewResidence() {
    Get.to(() =>  ViewResidenceScreen(isFromHomeScreen: true,));
  }

   void addResidence() {
    Get.to(() =>  AddResidenceScreen(isFormHomeScreen:true, isForEditResidenceAddress: false,isFromSignUpScreen: true,residenceModel: residenceModel));
  }

   void commentClicked(int postId,int index ,BuildContext context, PostModel postModel) {
     isGuestLogin ? guestLoginClicked(context) : 
       Get.to(() =>  CommentScreen(
        postModelData: postModel,
       ),arguments: {
    "postId":postId,
    "index":index,
    "postModel": postModel
  });

  }

   Future<void> searchClicked() async {
    var result = await Get.to(() =>  SearchPostScreen());
    if(result){
      txtControllerSearchText.clear();
      // arrayOfPostForSearch.clear();
      getAllPostApi();
    }
  // Get.to(() =>  SearchPostScreen())!.then((value) => getAllPostApi());
  }

     void notificationClicked() {
        Get.to(() =>  NotificationScreen(
          message: null,
        ));
  // Get.to(() =>  NotificationScreen())!.then((value) => getAllPostApi());
  }

 var arrayOfPostForSearch = <PostModel>[].obs;
  Future<void> getAllPostSearchApi({
    bool fromRefresh = false,
    int page = 1,
    int pageSize = 10,
    String searchParam = ''
  }) async {
    if (fromRefresh) {
      isPostLoading.value = false;
    } else {
      isPostLoading.value = true;
    }

    final apiHelper = ApiHelper(
      serviceName: "search_post",
      endPoint: ApiPaths.search_post + ("page=$page") + ("&pageSize=$pageSize") +("&searchParam=$searchParam"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {}, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if (page == 1) {
            arrayOfPost.clear();
          }
          final data = r['data']['posts'];

          arrayOfPostForSearch.addAll(
              List<PostModel>.from(data.map((x) => PostModel.fromJson(x))));
          isLoadingMore.value = false;
          Log.info("Post Data: ${arrayOfPostForSearch.length}");
          Log.info("Post Data: ${arrayOfPostForSearch}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isPostLoading.value = false;
  }

  void _launchURL() async {
    if (await canLaunch(AppConfig.urlForUpdate)) {
      await launch(AppConfig.urlForUpdate);
    } else {
      throw 'Could not launch ${AppConfig.urlForUpdate}';
    }
  }

  //  Future <void> updateAppClicked(BuildContext context) async {
  //   var deviceSize = MediaQuery.of(context).size; 
  //   forceUpdate?  
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     insetPadding: EdgeInsets.zero,
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
  //     backgroundColor: AppColors.primaryColor,
  //     content: SizedBox(
  //       height: deviceSize.height * 0.2,
  //       width: deviceSize.width * 0.65,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           CircleAvatar(
  //             radius: AppSizes.double50,
  //             backgroundColor: AppColors.fantedBlueColor,
  //             child:Image.asset(AppImages.appversion,scale: 1.0,),
  //           ),
  //           SizedBox(height: AppSizes.double10),
  //           Padding(
  //             padding: const EdgeInsets.only(top:8.0,left: 30,right: 30),
  //             child: Text(
  //               ConstantString.updateAppMessage,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontFamily: FontFamilyName.montserrat,
  //                   color: AppColors.black,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 12),
  //             ),
  //           ),
  //           SizedBox(height: AppSizes.double10),
  //         ],
  //       ),
  //     ),
  //     actions: <Widget>[
  //       const Divider(height: 0, color: AppColors.lightGrey),
       
  //         Center(
  //           child: TextButton(
  //             onPressed: (){
  //                Get.back();
  //               _launchURL();
  //               //  Get.back();
  //             },
  //             child: Text(ConstantString.update.toUpperCase()   ,           
  //               style: const TextStyle(
  //                   color: AppColors.lightBlueThemeColor,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15),
  //                   textAlign: TextAlign.center,
  //             ),
  //           ),
  //         )
  //     ],
  //   );
  //     },
  //   ):showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     insetPadding: EdgeInsets.zero,
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
  //     backgroundColor: AppColors.primaryColor,
  //     content: SizedBox(
  //       height: deviceSize.height * 0.2,
  //       width: deviceSize.width * 0.65,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           CircleAvatar(
  //             radius: AppSizes.double50,
  //             backgroundColor: AppColors.fantedBlueColor,
  //             child:Image.asset(AppImages.appversion,scale: 1.0,),
  //           ),
  //           SizedBox(height: AppSizes.double10),
  //           Padding(
  //             padding: const EdgeInsets.only(top:8.0,left: 30,right: 30),
  //             child: Text(
  //               ConstantString.updateAppMessage,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontFamily: FontFamilyName.montserrat,
  //                   color: AppColors.black,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14),
  //             ),
  //           ),
  //           SizedBox(height: AppSizes.double10),
  //         ],
  //       ),
  //     ),
  //     actions: <Widget>[
  //       const Divider(height: 0, color: AppColors.lightGrey),
       
  //       Padding(
  //         padding: const EdgeInsets.only(left:15.0,right: 15.0,),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             TextButton(
  //             onPressed: (){
  //                Get.back();
  //             },
  //             child: Text(ConstantString.cancel.toUpperCase()   ,           
  //               style: const TextStyle(
  //                   color: AppColors.mediumGrey,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15),
  //                   textAlign: TextAlign.center,
  //             ),
  //           ),
  //               Container(
  //                 width: 1.0,
  //                 height: AppSizes.double25,
  //                 color: AppColors.lightGrey,
  //               ),
  //            TextButton(
  //             onPressed: (){
  //                Get.back();
  //               _launchURL();
  //             },
  //             child: Text(ConstantString.update.toUpperCase()   ,           
  //               style: const TextStyle(
  //                   color: AppColors.lightBlueThemeColor,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15),
  //                   textAlign: TextAlign.center,
  //             ),
  //           ),
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  //     },
  //   );
  // }


  //Post like dislike API
Future<void> sharePostClicked({
  required BuildContext context,
  required String mediaPath, // URL or empty string
  required String hashtag,
  required Size deviceSize,  // Text or hashtag to share
  bool handleErrors = true,
}) async {
   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: tbCustomLoader(
        height: deviceSize.height,
        width: deviceSize.width * 0.5,
      ),
    ),
  );
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (context) => Center(child: CircularProgressIndicator(
  //     color: AppColors.blueThemeColor,
  //   )),
  // );

  try {
    if (mediaPath.isEmpty) {
      Navigator.pop(context);
      // Share only text if no media is provided
      await Share.share('$hashtag #teambalance');
     
      return;
    }

    // Download media from the URL
    final Uri mediaUri = Uri.parse(mediaPath);
    final response = await http.get(mediaUri);

    if (response.statusCode == 200) {
      // Save the file temporarily
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/shared_media');

      await tempFile.writeAsBytes(response.bodyBytes);
Navigator.pop(context);
         if (Platform.isAndroid) {
final result = await Share.shareXFiles([XFile(tempFile.path)],  text: '$hashtag #teambalance',);
} else if (Platform.isIOS) {
  // Share.shareXFiles([XFile(tempFile.path)]);
final result = await Share.shareXFiles([XFile(tempFile.path)],  text: '$hashtag #teambalance',);
}
      // Share the file
      // await Share.shareFiles(
      //   [tempFile.path],
      //   text: '$hashtag #teambalance',
      // );

      // Optionally delete the temp file after sharing
      tempFile.delete();
    } else {
      Navigator.pop(context);
      if (handleErrors) {
        
        print('Failed to download media from $mediaPath');
        // Show a dialog or toast if required
      }
    }
  } catch (e) {
    Navigator.pop(context);
    if (handleErrors) {
      print('Error sharing post: $e');
      // Handle errors gracefully
    }
  } 
}
//   Future<void> sharePostClicked(
//       {bool handleErrors = true, int postId = 0}) async {
//        final Uri uri = Uri.parse('https://teambalance.uk/'); 
// Share.shareUri(uri);
//   }
} 
