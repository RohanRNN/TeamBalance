import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:video_player/video_player.dart';


class MyPostController extends GetxController {
      var refreshKey = GlobalKey<RefreshIndicatorState>();
          late VideoPlayerController videoController;
  // late PageController scrollController;
  late ScrollController scrollControllerForMyPost;
   int currPage = 1;
     RxBool isLikePost = false.obs;
  RxBool isLoadingMore = false.obs;
  void commentClicked({PostModel? postModelData}) {
  Get.to(() =>  CommentScreen(
     postModelData: postModelData!,
  ));
  }

  RxBool isGuestLogin = false.obs;
  void setGuestAccount() async {
    isGuestLogin.value = await GS.readGuestLogin();
  //   if(!isGuestLogin.value){
  //      getAllPostApi(    
  //  );  
    // }
  }

Future<void> goToLoginScreen() async {
    var deviceToke = '';
              if (GSAPIHeaders.fcmToken!.isNotEmpty) {
                deviceToke = GSAPIHeaders.fcmToken ?? '';
              }
              await GS.clearAll();
              Log.info('LOGOUT TOKE: $deviceToke');
              GSAPIHeaders.fcmToken = deviceToke;
              Get.offAll(() => const LoginScreen());
}



  Future<void> onRefresh() async {
    // isLoading.value = true;
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
      currPage = 1;
      await getAllPostApi(
        fromRefresh: true,
        fromLoadMore: false,
        page: currPage,
        pageSize: 10,
      );
      // isLoading.value = false;
    
  }

  void onLoadMore() async {
    if (isLoadingMore.value) return;
    // if (scrollControllerForMyPost.position.pixels ==
    //     scrollControllerForMyPost.position.maxScrollExtent) {
      isLoadingMore.value = true;
        currPage = currPage + 1;
        await getAllPostApi(
          fromRefresh: false,
          fromLoadMore: true,
          page: currPage,
          pageSize: 10,
        );
      
      // isLoadingMore.value = false;
    // }
  }


  Future<void> getAllPostApiForRefresh({
    bool fromRefresh = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    // if (fromRefresh) {
    //   isPostLoading.value = false;
    // } else {
    //   isPostLoading.value = true;
    //   arrayOfPost.clear();
    // }

    final apiHelper = ApiHelper(
      serviceName: "get_myposts",
      endPoint: ApiPaths.get_myposts + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    print("result: $result");
    result.fold((l) {
       arrayOfPost.clear();
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          if(page ==1 || fromRefresh){
            arrayOfPost.clear();
          }
            
          
          final data = r['data']['posts'];
          arrayOfPost.addAll(
              List<PostModel>.from(data.map((x) => PostModel.fromJson(x))));
          isLoadingMore.value = false;
            // isPostLoading.value = false;
          Log.info("Post Data: ${arrayOfPost.length}");
          Log.info("Post Data: ${arrayOfPost}");
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
            // isPostLoading.value = false;
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
      }
    });
    // isPostLoading.value = false;
  }


   //Get all post API
  RxBool isPostLoading = false.obs;
  RxBool isPostLoadingFromLoadmore = false.obs;
  var arrayOfPost = <PostModel>[].obs;
  Future<void> getAllPostApi({
    bool fromRefresh = false,
    bool fromLoadMore = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (fromRefresh) {
      isPostLoading.value = false;
    } else if(fromLoadMore){
        isPostLoading.value = false;
    }
    else {
      isPostLoading.value = true;     
      // arrayOfPost.clear();
    }

    final apiHelper = ApiHelper(
      serviceName: "get_myposts",
      endPoint: ApiPaths.get_myposts + ("page=$page") + ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    print("result for get_myposts: $result");
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
            isPostLoading.value = false;
          Log.info("Post Data: ${arrayOfPost.length}");
          Log.info("Post Data 123: ${arrayOfPost}");
        } else {
          arrayOfPost.clear();
          showTopFlashMessage(ToastType.failure, message.toString());
            isPostLoading.value = false;
        }
      } catch (e, stacktrace) {
        arrayOfPost.clear();
        print('\n******** $e ********\n$stacktrace');
      }
    });
    isPostLoading.value = false;
    isLoadingMore.value = false;
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

  //   //Post like dislike API
  // Future<void> postLikeDislikeApi(
  //     {bool handleErrors = true, int postId = 0, int? index})  async {
  //       // arrayOfPost[index!].isliked = arrayOfPost[index!].isliked == 0 ? 1 : 0;
  //   // update([GetBuilderIds.likePost]);
  //   final apiHelper = ApiHelper(
  //     endPoint: ApiPaths.like_dislike_post,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //   final result =  apiHelper.post(body: {
  //     "post_id": postId.toString(),
  //   }, isFormData: true);
  //   Log.info("result: $result");
  //    result.fold((l) {}, (r)  {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //       if (status == ApiStatus.success) {
  //         if (index! < arrayOfPost.length) {
            
  //           arrayOfPost[index].isliked = r['data']['is_liked'];
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
  //   update([GetBuilderIds.likePost]);
  // }



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

}
 
