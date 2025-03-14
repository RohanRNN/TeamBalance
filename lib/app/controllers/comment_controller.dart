import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/dash_board_controller.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/app/wights/dialogs/image_permission_discloser_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/post_model.dart';

class CommentController extends GetxController {
  int postId = 0;
  int postIndexId = 0;
  File? commentMediaFile;
  final TextEditingController txtComment = TextEditingController();
  final TextEditingController txtReplyComment = TextEditingController();
  RxInt selectedCommentId = 0.obs;
  PostModel postModel = PostModel();

  late ScrollController scrollController = ScrollController();
  // late ScrollController topToBottomCommentScrollCntrl = ScrollController();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  int currPage = 1;
  final DashBoardController dashBoardController =
      Get.put(DashBoardController());
  RxBool isLoadingMore = false.obs;
  RxInt commentTypeValue = 0.obs;

  RxBool hasMoreData = true.obs;

  RxBool isReplyLoading = false.obs;
  late CommentModel newCommentFromNotification;

  

  // final listOfItem = [
  //   "Spam",
  //   "Indecent Content",
  // ];
  var reportResaonList = <CommentReportReason?>[];

  @override
  void onInit() async {
    MasterDataModel? masterData = await GS.readMasterApiData();
    if (masterData != null) {
      reportResaonList = masterData!.commentreportreasons!;
    }
    super.onInit();
  }

  static const imageScale = 2.5;
  var selectedCommentReportReason = 0;

  void scrollToTop() {
    Log.info('SCROLL END');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.minScrollExtent,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      }
    });
  }

  Future<void> onRefresh() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
    currPage = 1;
    await getPostCommentsApi(
        fromRefresh: true, page: 1, postId: postId, pageSize: 5);
    isLoadingMore.value = false;
  }

  void onLoadMore() async {
    if (isLoadingMore.value) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isLoadingMore.value = true;
      Log.success("In maxScrollExtent : ${isLoadingMore.value}");
      currPage = currPage + 1;
      await getPostCommentsApi(
          fromRefresh: true, page: currPage, postId: postId, pageSize: 5);
      // isLoadingMore.value = false;
    }
  }

///////////////// for get array of comments
  RxBool isLoading = false.obs;
  var arrayOfComment = <CommentModel>[].obs;
  Future<void> getPostCommentsApi(
      {bool fromRefresh = false,
      int page = 1,
      int pageSize = 5,
      int postId = 0,
      bool isDataAdded = false}) async {
    if (!isDataAdded) {
      if (fromRefresh) {
        isLoading.value = false;
      } else {
        arrayOfComment.clear();
        isLoading.value = true;
      }
    }
    final apiHelper = ApiHelper(
      serviceName: "get_comments",
      endPoint: ApiPaths.get_comments +
          ("post_id=$postId") +
          ("&page=$page") +
          ("&pageSize=$pageSize"),
      showErrorDialog: false,
    );
    final result = await apiHelper.get();
    Log.info('POST COMMENT RESULT: $result');
    result.fold((l) {
      isLoadingMore.value = false;
    }, (r) {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          // final data = r['data'];
          // if (page == 1) {
          // if(fromRefresh){
          //    arrayOfComment.clear();
          // }

          // }
          final data = r['data']['post_comments'] as List<dynamic>;

          if (data.isNotEmpty) {
            for (var newCommentData in data) {
              final newComment = CommentModel.fromJson(newCommentData);

              Log.success(
                  "!arrayOfComment.any((existingComment) =>existingComment.subCommentsData == newComment.subCommentsData) : ${!arrayOfComment.any((existingComment) {
                Log.success(
                    "existingComment.subCommentsData.length : ${existingComment.subCommentsData.length}");
                Log.success(
                    "newComment.subCommentsData.length: ${newComment.subCommentsData.length}");
                return existingComment.subCommentsData.length ==
                    newComment.subCommentsData.length;
              })}");
              
              if (!arrayOfComment.any(
                  (existingComment) => existingComment.id == newComment.id)) {
                arrayOfComment.add(newComment);
              }
            
            }
          }
           if (!arrayOfComment.any((c) => c.id == newCommentFromNotification.id)) {
              // arrayOfComment.add(newCommentFromNotification);
              arrayOfComment.insert(0, newCommentFromNotification);
            }
          if (data.length < pageSize) {
            Log.success("Data length==> ${data.length}, $pageSize : false ");
            hasMoreData.value = false;
          } else {
            Log.success("Data length==> ${data.length}, $pageSize : true ");
            hasMoreData.value = true;
          }
          isLoadingMore.value = false;
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          isLoadingMore.value = false;
        }
      } catch (e, stacktrace) {
        print('\n******** $e ********\n$stacktrace');
        isLoadingMore.value = false;
      }
    });
    isLoading.value = false;
  }

  RxBool isLoadingReport = false.obs;
///////////////////////////    report comment
  Future<void> postReportCommentApi({
    bool handleErrors = true,
    String commentId = "0",
    String reasonId = "0",
    int? index,
  }) async {
    isLoadingReport.value = true;
    final apiHelper = ApiHelper(
      endPoint: ApiPaths.report_comment,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.post(body: {
      "comment_id": commentId,
      "report_reason_id": reasonId,
    }, isFormData: true);
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
         arrayOfComment.removeWhere((comment) => comment.id.toString() == commentId);
         arrayOfComment.removeWhere((comment) => _removeCommentRecursively(comment, commentId));
          showTopFlashMessage(ToastType.success, message.toString());
          // }
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
        }
        isLoadingReport.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
      isLoadingReport.value = false;
    });
  }

  bool _removeCommentRecursively(CommentModel comment, String commentId) {
  if (comment.id.toString() == commentId) {
    return true;  }
  comment.subCommentsData.removeWhere((subComment) => subComment.id.toString() == commentId);
  return false;
}

  RxBool isLoadingForAdding = false.obs;
  Future<void> postCreateCommentApi({
    bool handleErrors = true,
    String postId = "0",
    int? index,
    bool isText = true,
    bool isSubComment = true,
    String commentId = '0',
    String commentText = '',
  }) {
    if (commentText == '') {
      print("In if commentText == ''");
      ApiHelper(
        endPoint: ApiPaths.create_comment,
        showErrorDialog: handleErrors,
        showTransparentOverlay: false,
      )
          .postMultipart(
        body: isSubComment
            ? {
                "post_id": postId,
                "comment_type": isText ? 'Text' : 'Image',
                "parent_comment_id": commentId,
                "comment": commentText,
              }
            : {
                "post_id": postId,
                "comment_type": isText ? 'Text' : 'Image',
                "comment": commentText,
              },
        imageFile: isText
            ? {}
            : {
                "comment_media":
                    commentMediaFile == null ? [] : [commentMediaFile!],
              },
      )
          .then((value) {
        value.fold(
          (l) {
            final message = l['message'] == null || l['message'] == "null"
                ? APIErrorMsg.somethingWentWrong
                : l['message'];
            showTopFlashMessage(ToastType.failure, message.toString());
            isReplyLoading.value = false;
          },
          (r) {
            try {
              final status = r['status'];
              final message = r['message'];
              final totalComments = r['data']['totalComments'];
              if (status == ApiStatus.success) {
                arrayOfComment.removeWhere((comment) => comment.id == 0);
                final data = r['data']['post_comments'][0];
                if (isSubComment) {
                  final subCommentData = SubCommentsData.fromJson(data);
                  arrayOfComment[index!]
                      .subCommentsData
                      .removeWhere((comment) => comment.id == 0);
                  arrayOfComment[index!].subCommentsData.add(subCommentData);
                } else {
                  final commentData = CommentModel.fromJson(data);
                  arrayOfComment.insert(0, commentData);
                }

                dashBoardController.arrayOfPost[postIndexId].totalComments =
                    totalComments;
                txtComment.text = '';
              } else {
                showTopFlashMessage(ToastType.failure, message.toString());
              }
            } catch (e, stacktrace) {
              Log.error('\n******** Error: $e ********\n$stacktrace');
            } finally {
              isReplyLoading.value = false;
            }
          },
        );
      });
      // showTopFlashMessage(ToastType.info, 'Please select Business Name for you business.',
      //         context: Get.context);
    } else {
      // Add local comment immediately for instant UI feedback
      if (!isSubComment) {
        arrayOfComment.insert(
          0,
          CommentModel(
            id: 0,
            userId: GS.userData.value!.id!,
            fullName: GS.userData.value!.fullname!,
            profileImage: GS.userData.value!.profileimage!,
            postId: int.parse(postId),
            commentType: '',
            subCommentsData: [],
            parentCommentId: 0,
            comment: commentText,
            createdAt: DateTime.now().toString(),
            commentMediaData: [],
          ),
        );
      } else {
        arrayOfComment[index!].subCommentsData.add(
              SubCommentsData(
                id: 0,
                userId: GS.userData.value!.id!,
                fullName: GS.userData.value!.fullname!,
                profileImage: GS.userData.value!.profileimage!,
                postId: int.parse(postId),
                commentType: isText ? "Text" : 'Image',
                parentCommentId: 0,
                comment: commentText,
                createdAt: '',
                commentMediaData: [],
              ),
            );
      }

      // Return immediately to prevent UI freezing
      // Future.value();

      // Execute the API call in a microtask to prevent blocking
      // Future.microtask(()  {
      ApiHelper(
        endPoint: ApiPaths.create_comment,
        showErrorDialog: handleErrors,
        showTransparentOverlay: false,
      )
          .postMultipart(
        body: isSubComment
            ? {
                "post_id": postId,
                "comment_type": isText ? 'Text' : 'Image',
                "parent_comment_id": commentId,
                "comment": commentText,
              }
            : {
                "post_id": postId,
                "comment_type": isText ? 'Text' : 'Image',
                "comment": commentText,
              },
        imageFile: isText
            ? {}
            : {
                "comment_media":
                    commentMediaFile == null ? [] : [commentMediaFile!],
              },
      )
          .then((value) {
        value.fold(
          (l) {
            final message = l['message'] == null || l['message'] == "null"
                ? APIErrorMsg.somethingWentWrong
                : l['message'];
            showTopFlashMessage(ToastType.failure, message.toString());
          },
          (r) {
            try {
              final status = r['status'];
              final message = r['message'];
              final totalComments = r['data']['totalComments'];
              if (status == ApiStatus.success) {
                arrayOfComment.removeWhere((comment) => comment.id == 0);

                final data = r['data']['post_comments'][0];
                if (isSubComment) {
                  final subCommentData = SubCommentsData.fromJson(data);
                  arrayOfComment[index!]
                      .subCommentsData
                      .removeWhere((comment) => comment.id == 0);
                  arrayOfComment[index!].subCommentsData.add(subCommentData);
                } else {
                  final commentData = CommentModel.fromJson(data);
                  arrayOfComment.insert(0, commentData);
                }

                dashBoardController.arrayOfPost[postIndexId].totalComments =
                    totalComments;
                txtComment.text = '';
              } else {
                showTopFlashMessage(ToastType.failure, message.toString());
              }
            } catch (e, stacktrace) {
              Log.error('\n******** Error: $e ********\n$stacktrace');
            }
          },
        );
      });
    }
    // final result =  apiHelper.postMultipart(
    //   body: isSubComment
    //       ? {
    //           "post_id": postId,
    //           "comment_type": isText ? 'Text' : 'Image',
    //           "parent_comment_id": commentId,
    //           "comment": commentText,
    //         }
    //       : {
    //           "post_id": postId,
    //           "comment_type": isText ? 'Text' : 'Image',
    //           "comment": commentText,
    //         },
    //   imageFile: isText
    //       ? {}
    //       : {
    //           "comment_media": commentMediaFile == null ? [] : [commentMediaFile!],
    //         },
    // ).then((value) {
    //   result.fold(
    //   (l) {
    //     final message = l['message']==null || l['message']=="null" ? APIErrorMsg.somethingWentWrong : l['message'];
    //     showTopFlashMessage(ToastType.failure, message.toString());
    //   },
    //   (r) {
    //     try {
    //       final status = r['status'];
    //       final message = r['message'];
    //       final totalComments = r['data']['totalComments'];
    //       if (status == ApiStatus.success) {
    //         arrayOfComment.removeWhere((comment) => comment.id == 0);

    //         final data = r['data']['post_comments'][0];
    //         if (isSubComment) {
    //           final subCommentData = SubCommentsData.fromJson(data);
    //           arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
    //           arrayOfComment[index!].subCommentsData.add(subCommentData);
    //         } else {
    //           final commentData = CommentModel.fromJson(data);
    //           arrayOfComment.add(commentData);
    //         }

    //         dashBoardController.arrayOfPost[postIndexId].totalComments = totalComments;
    //         txtComment.text = '';
    //       } else {
    //         showTopFlashMessage(ToastType.failure, message.toString());
    //       }
    //     } catch (e, stacktrace) {
    //       Log.error('\n******** Error: $e ********\n$stacktrace');
    //     }
    //   },
    // );
    // });

    // Handle the API response
    // Log.info("Result: $result");
    // result.fold(
    //   (l) {
    //     final message = l['message'];
    //     showTopFlashMessage(ToastType.failure, message.toString());
    //   },
    //   (r) {
    //     try {
    //       final status = r['status'];
    //       final message = r['message'];
    //       final totalComments = r['data']['totalComments'];
    //       if (status == ApiStatus.success) {
    //         arrayOfComment.removeWhere((comment) => comment.id == 0);

    //         final data = r['data']['post_comments'][0];
    //         if (isSubComment) {
    //           final subCommentData = SubCommentsData.fromJson(data);
    //           arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
    //           arrayOfComment[index!].subCommentsData.add(subCommentData);
    //         } else {
    //           final commentData = CommentModel.fromJson(data);
    //           arrayOfComment.add(commentData);
    //         }

    //         dashBoardController.arrayOfPost[postIndexId].totalComments = totalComments;
    //         txtComment.text = '';
    //       } else {
    //         showTopFlashMessage(ToastType.failure, message.toString());
    //       }
    //     } catch (e, stacktrace) {
    //       Log.error('\n******** Error: $e ********\n$stacktrace');
    //     }
    //   },
    // );
    // });
    return Future.value();
  }
// Future<void> postCreateCommentApi({
//   bool handleErrors = true,
//   String postId = "0",
//   int? index,
//   bool isText = true,
//   bool isSubComment = true,
//   String commentId = '0',
//   String commentText = '',
// }) async {
//   // Add local comment immediately for instant UI feedback
//   if (!isSubComment) {
//     arrayOfComment.add(
//       CommentModel(
//         id: 0,
//         userId: GS.userData.value!.id!,
//         fullName: GS.userData.value!.fullname!,
//         profileImage: GS.userData.value!.profileimage!,
//         postId: int.parse(postId),
//         commentType: '',
//         subCommentsData: [],
//         parentCommentId: 0,
//         comment: commentText,
//         createdAt: DateTime.now().toString(),
//         commentMediaData: [],
//       ),
//     );
//   } else {
//     arrayOfComment[index!].subCommentsData.add(
//       SubCommentsData(
//         id: 0,
//         userId: GS.userData.value!.id!,
//         fullName: GS.userData.value!.fullname!,
//         profileImage: GS.userData.value!.profileimage!,
//         postId: int.parse(postId),
//         commentType: isText ? "Text" : 'Image',
//         parentCommentId: 0,
//         comment: commentText,
//         createdAt: '',
//         commentMediaData: [],
//       ),
//     );
//   }

//   // Return immediately to prevent UI freezing
//   Future.value();

//   // Handle API call asynchronously
//   // Future.delayed(Duration.zero, ()  {
//     final apiHelper = ApiHelper(
//       endPoint: ApiPaths.create_comment,
//       showErrorDialog: handleErrors,
//       showTransparentOverlay: true,
//     );

//     final result =  apiHelper.postMultipart(
//       body: isSubComment
//           ? {
//               "post_id": postId,
//               "comment_type": isText ? 'Text' : 'Image',
//               "parent_comment_id": commentId,
//               "comment": commentText,
//             }
//           : {
//               "post_id": postId,
//               "comment_type": isText ? 'Text' : 'Image',
//               "comment": commentText,
//             },
//       imageFile: isText
//           ? {}
//           : {
//               "comment_media": commentMediaFile == null ? [] : [commentMediaFile!],
//             },
//     ).then((value) {
//  // Handle the API response
//     Log.info("Result: $value");
//     value.fold(
//       (l) {
//         final message = l['message'];
//         showTopFlashMessage(ToastType.failure, message.toString());
//       },
//       (r) {
//         try {
//           final status = r['status'];
//           final message = r['message'];
//           final totalComments = r['data']['totalComments'];
//           if (status == ApiStatus.success) {
//             arrayOfComment.removeWhere((comment) => comment.id == 0);

//             final data = r['data']['post_comments'][0];
//             if (isSubComment) {
//               final subCommentData = SubCommentsData.fromJson(data);
//               arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
//               arrayOfComment[index!].subCommentsData.add(subCommentData);
//             } else {
//               final commentData = CommentModel.fromJson(data);
//               arrayOfComment.add(commentData);
//             }

//             dashBoardController.arrayOfPost[postIndexId].totalComments = totalComments;
//             txtComment.text = '';
//           } else {
//             showTopFlashMessage(ToastType.failure, message.toString());
//           }
//         } catch (e, stacktrace) {
//           Log.error('\n******** Error: $e ********\n$stacktrace');
//         }
//       },
//     );
//     }) ;

// }

///// latest working code
// Future<void> postCreateCommentApi({
//   bool handleErrors = true,
//   String postId = "0",
//   int? index,
//   bool isText = true,
//   bool isSubComment = true,
//   String commentId = '0',
//   String commentText = '',
// }) async {
//   // Add local comment immediately for instant UI feedback
//   if (!isSubComment) {
//     // Add main comment locally
//     arrayOfComment.add(
//       CommentModel(
//         id: 0,
//         userId: GS.userData.value!.id!,
//         fullName: GS.userData.value!.fullname!,
//         profileImage: GS.userData.value!.profileimage!,
//         postId: int.parse(postId),
//         commentType: '',
//         subCommentsData: [],
//         parentCommentId: 0,
//         comment: commentText,
//         createdAt: DateTime.now().toString(),
//         commentMediaData: [],
//       ),
//     );
//   } else {
//     // Add sub-comment locally
//     arrayOfComment[index!].subCommentsData.add(
//       SubCommentsData(
//         id: 0,
//         userId: GS.userData.value!.id!,
//         fullName: GS.userData.value!.fullname!,
//         profileImage: GS.userData.value!.profileimage!,
//         postId: int.parse(postId),
//         commentType: isText ? "Text" : 'Image',
//         parentCommentId: 0,
//         comment: commentText,
//         createdAt: '',
//         commentMediaData: [],
//       ),
//     );
//   }

//   // Prepare API call
//   final apiHelper = ApiHelper(
//     endPoint: ApiPaths.create_comment,
//     showErrorDialog: handleErrors,
//     showTransparentOverlay: true,
//   );

//   // Send the comment to the server
//   final result = await apiHelper.postMultipart(
//     body: isSubComment
//         ? {
//             "post_id": postId,
//             "comment_type": isText ? 'Text' : 'Image',
//             "parent_comment_id": commentId,
//             "comment": commentText,
//           }
//         : {
//             "post_id": postId,
//             "comment_type": isText ? 'Text' : 'Image',
//             "comment": commentText,
//           },
//     imageFile: isText
//         ? {}
//         : {
//             "comment_media": commentMediaFile == null ? [] : [commentMediaFile!],
//           },
//   );

//   // Handle the API response
//   Log.info("Result: $result");
//   result.fold(
//     (l) {
//       // Failure response
//       final message = l['message'];
//       showTopFlashMessage(ToastType.failure, message.toString());
//     },
//     (r) {
//       // Success response
//       try {
//         final status = r['status'];
//         final message = r['message'];
//         final totalComments = r['data']['totalComments'];
//         if (status == ApiStatus.success) {
//           // Remove the temporary comment (id = 0) added for immediate feedback
//           arrayOfComment.removeWhere((comment) => comment.id == 0);
//           // arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);

//           // Parse the response and add the actual comment data
//           final data = r['data']['post_comments'][0];
//           if (isSubComment) {
//             final subCommentData = SubCommentsData.fromJson(data);
//             arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
//             arrayOfComment[index!].subCommentsData.add(subCommentData);
//           } else {
//             final commentData = CommentModel.fromJson(data);
//             arrayOfComment.add(commentData);
//           }

//           // Update the total comment count
//           dashBoardController.arrayOfPost[postIndexId].totalComments = totalComments;

//           // Clear the input text field and reset variables
//           txtComment.text = '';
//         } else {
//           showTopFlashMessage(ToastType.failure, message.toString());
//         }
//       } catch (e, stacktrace) {
//         Log.error('\n******** Error: $e ********\n$stacktrace');
//       }
//     },
//   );
// }

// ///////////////////////////    add comment
  // Future<void> postCreateCommentApi(
  //     {bool handleErrors = true, String postId = "0", int? index, bool isText = true, bool isSubComment = true,String commentId = '0',String commentText = ''}) async {
  //   // update([GetBuilderIds.likePost]);
  //   // isLoadingForAdding.value= true;

  //   if(!isSubComment)
  //   {
  //      arrayOfComment.add(CommentModel(
  //       id: 0,
  //       userId: GS.userData.value!.id!,
  //       fullName: GS.userData.value!.fullname!,
  //       profileImage: GS.userData.value!.profileimage!,
  //       postId: int.parse(postId),
  //       commentType: '',
  //       subCommentsData: [],
  //       parentCommentId: 0,
  //       comment: commentText,
  //       createdAt: DateTime.now().toString(),
  //       commentMediaData: []));
  //   }else{
  //     arrayOfComment[index!].subCommentsData.add(
  //       SubCommentsData(
  //         id: 0,
  //         userId: GS.userData.value!.id!,
  //         fullName: GS.userData.value!.fullname!,
  //         profileImage: GS.userData.value!.profileimage!,
  //         postId: int.parse(postId),
  //         commentType: isText ? "Text" :'Image' ,
  //         parentCommentId: 0,
  //         comment: commentText,
  //         createdAt:  '',
  //         commentMediaData: [])
  //     );
  //   }

  //   final apiHelper = ApiHelper(
  //     endPoint: ApiPaths.create_comment,
  //     showErrorDialog: handleErrors,
  //     showTransparentOverlay: true,
  //   );

  //  final result = await apiHelper.postMultipart(
  //       body:isSubComment? {
  //         "post_id": postId ?? '',
  //         "comment_type": isText?'Text':'Image',
  //         "parent_comment_id": commentId,
  //         "comment": commentText ?? '',
  //       }:{
  //         "comment_type": isText?'Text':'Image',
  //         "post_id": postId ?? '',
  //         "comment": commentText ?? '',
  //       },
  //       imageFile:isText?{}: {
  //         "comment_media": commentMediaFile == null ? [] : [commentMediaFile!],
  //       },
  //     );
  //   Log.info("result: $result");
  //    result.fold((l) {
  //     final status = l['status'];
  //       final message = l['message'];
  //     showTopFlashMessage(ToastType.failure, message.toString());
  //   }, (r)  {
  //     try {
  //       final status = r['status'];
  //       final message = r['message'];
  //        final totalComments = r['data']['totalComments'];
  //       if (status == ApiStatus.success) {
  //         arrayOfComment.removeWhere((comment) => comment.id == 0);
  //         // arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
  //           final data = r['data']['post_comments'][0];
  //           if(isSubComment){
  //               final subCommentData = SubCommentsData.fromJson(data);
  //               arrayOfComment[index!].subCommentsData.removeWhere((comment) => comment.id == 0);
  //               arrayOfComment[index!].subCommentsData.add(subCommentData);
  //           }else{
  //                 final commentData = CommentModel.fromJson(data);
  //           //  showTopFlashMessage(ToastType.success, message.toString());
  //            arrayOfComment.add(commentData);
  //           }
  //           // isLoadingForAdding.value= false;
  //           dashBoardController.arrayOfPost[postIndexId].totalComments =  totalComments;

  //            txtComment.text = '';
  //            isSubComment = false;

  //       } else {
  //         showTopFlashMessage(ToastType.failure, message.toString());
  //       }
  //       // isLoadingForAdding.value= false;
  //       return;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //   });
  // }

  Future<void> commentMediaCallback(BuildContext context) async {
    final bool? isGallaryImagePicker =
        await chooseFromImageSourceSheet(context);
    if (isGallaryImagePicker != null) {
      // if (Platform.isAndroid) {
      //   final hasAgreedToDiscloser =
      //       await showImagePermissionDiscloserDialog(context);
      //   if (hasAgreedToDiscloser == false) {
      //     return;
      //   }
      // }
      late final Either<bool, File> result;
      if (isGallaryImagePicker) {
        result = await Picker.pickImage(
            context: context,
            fromSource: ImageSource.gallery,
            pickOnlyImage: true);
      } else {
        result = await Picker.pickImage(
            context: context,
            fromSource: ImageSource.camera,
            pickOnlyImage: true);
      }
      result.fold((l) {
        print("IN LEFT OF commentMediaCallback");
      }, (r) {
        commentMediaFile = r;
        update([GetBuilderIds.commentMediaImage]);
      });
    }
  }

  void tapOnAddCommentButton(
      {required int commentType, required int id, required String comment}) {
    if (comment.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Kindly enter your comment',
          context: Get.context);
    } else {}
  }
}
