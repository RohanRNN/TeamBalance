
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/settings/post/video_media_trimmer.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/app/wights/dialogs/image_permission_discloser_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/post_media_model.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


class CreatePostController extends GetxController {
// File? adsMedia;
File? thumbnail;
static const imageCount = 5;
var imageArray = [];
var selectedMediasPath = <File>[];
var selectedMediasThumbnailPath = <File>[];

var postMediaArray = <PostMediaModel>[];
  final TextEditingController txtPostDescription = TextEditingController();

bool isImage(File file) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']; // Add more if needed
  final extension = file.path.split('.').last.toLowerCase();
  return imageExtensions.contains(extension);
}

bool isVideo(File file) {
  final videoExtensions = ['mp4', 'mov', 'avi', 'mkv']; // Add more if needed
  final extension = file.path.split('.').last.toLowerCase();
  return videoExtensions.contains(extension);
}


   bool isFormValid() {
    
     if (postMediaArray.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please add image/vidoe for the post.',
          context: Get.context);
      return false;
    }
     if (txtPostDescription.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter description for the post.',
          context: Get.context);
      return false;
    }
    return true;
  }

     bool isFormValidForText() {
     if (txtPostDescription.text.isEmpty) {
      showTopFlashMessage(ToastType.info, 'Please enter text for the post.',
          context: Get.context);
      return false;
    }
    return true;
  }

Future<void> checkPermissionsAndShowDialog(BuildContext context) async {
  if (Platform.isAndroid) {
    // Check for camera and media permissions
    bool isCameraGranted = await Permission.camera.isGranted;
    bool isStorageGranted = await Permission.storage.isGranted;

    // Request permissions if not granted
    if (!isCameraGranted) {
      isCameraGranted = await Permission.camera.request().isGranted;
    }

    if (!isStorageGranted) {
      isStorageGranted = await Permission.storage.request().isGranted;
    }

    // If either permission is not granted, return
    if (!isCameraGranted || !isStorageGranted) {
      return;
    }

    // Show the image permission discloser dialog
    final hasAgreedToDiscloser = await showImagePermissionDiscloserDialog(context);
    if (hasAgreedToDiscloser == false) {
      return;
    }
  }
  // Continue with your logic
}

RxBool isMediaLoading = false.obs;

  Future<void> postMediaCallback(BuildContext context,mediaType,pickOnlyImage) async {
    
    final bool? isGallaryImagePicker =
        await chooseFromImageSourceSheet(context);
    if (isGallaryImagePicker != null) {
      // checkPermissionsAndShowDialog(context);
  //       if (Platform.isAndroid) {
  //   // Check for camera and media permissions
  //   bool isCameraGranted = await Permission.camera.isGranted;
  //   bool isStorageGranted = await Permission.storage.isGranted;

  //   // Request permissions if not granted
  //   if (!isCameraGranted) {
  //     isCameraGranted = await Permission.camera.request().isGranted;
  //   }

  //   if (!isStorageGranted) {
  //     isStorageGranted = await Permission.storage.request().isGranted;
  //   }

  //   // If either permission is not granted, return
  //   if (!isCameraGranted || !isStorageGranted) {
  //     return;
  //   }

  //   // Show the image permission discloser dialog
  //   final hasAgreedToDiscloser = await showImagePermissionDiscloserDialog(context);
  //   if (hasAgreedToDiscloser == false) {
  //     return;
  //   }
  // }
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
        print('this is for galarry=====>>>>>');
        result = await Picker.pickImage(context: context, fromSource: ImageSource.gallery,pickOnlyImage: pickOnlyImage);
      } else {
        result = await Picker.pickImage(context: context, fromSource: ImageSource.camera,pickOnlyImage: pickOnlyImage);
      }
      isMediaLoading.value = true; 
      result.fold((l) {
        isMediaLoading.value = false; 
      }, (r) async {
        // this is for the Size of the file
               final fileSize = await r.length(); 
         final fileSizeInMB = fileSize / (1024 * 1024); 

         if (fileSizeInMB > 150) {
              showTopFlashMessage(ToastType.failure, "File size exceeds 150 MB limit.");
           print("File size exceeds 150 MB limit.");
           return;
         }

        if(mediaType == 1)
        {
          postMediaArray.add(PostMediaModel(media_type: '1', media_name: r, thumbnail: null));
          // selectedMediasPath.add(r);
          // adsMedia = r;
          // selectedMediasPath.add(r!);
        }else if(mediaType == 2){
          if(isVideo(r)){

             final videoPlayerController = VideoPlayerController.file(r);
      await videoPlayerController.initialize();
                  final videoDuration = videoPlayerController.value.duration;
      if (videoDuration.inSeconds > 120) {
        //  Get.to(() =>  TrimmerView(r));
       showTopFlashMessage(ToastType.failure, "Video duration exceeds 40 seconds.");
       isMediaLoading.value = false;
        return;
      }
             final thumbnailFileName = await VideoThumbnail.thumbnailFile(video: r.path, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
          thumbnail = File(thumbnailFileName!);
           postMediaArray.add(PostMediaModel(media_type: '2', media_name: r, thumbnail: thumbnail));
            // selectedMediasPath.add(r);
            // selectedMediasThumbnailPath.add(thumbnail!);
          }else{
             postMediaArray.add(PostMediaModel(media_type: '1', media_name: r, thumbnail: null));
            //  selectedMediasPath.add(r);
          }
         
            // thumbnail =r;
            //  selectedMediasThumbnailPath.add(r!);
        }else if(mediaType == 4){
          postMediaArray[0].thumbnail = r;
          // selectedMediasThumbnailPath.remove(0);
          // selectedMediasThumbnailPath.add(r);
        }
        else{
          if(isVideo(r)){
                     final videoPlayerController = VideoPlayerController.file(r);
      await videoPlayerController.initialize();
      final videoDuration = videoPlayerController.value.duration;
      if (videoDuration.inSeconds > 120) {
          //  Get.to(() =>  TrimmerView(r));
      //  showTopFlashMessage(ToastType.failure, "Video duration exceeds 20 seconds.");
        return;
      }
       final thumbnailFileName = await VideoThumbnail.thumbnailFile(video: r.path, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
          thumbnail = File(thumbnailFileName!);
             postMediaArray.add(PostMediaModel(media_type: '2', media_name: r, thumbnail: thumbnail));
            //  selectedMediasPath.add(r);
            //  selectedMediasThumbnailPath.add(thumbnail!);
          } else{
             postMediaArray.add(PostMediaModel(media_type: '1', media_name: r, thumbnail: null));
            //  selectedMediasPath.add(r);
          }  
        }
        update([GetBuilderIds.addPostMedia]);
        isMediaLoading.value = false;
        // isCreatePostLoading.value = false;
        // update([GetBuilderIds.profileImage]);
      });
      
    }
    
    // update([GetBuilderIds.addPostMedia]);
  }


///////////////////////////    upload new post
  RxBool isCreatePostLoading = false.obs;
  Future<void> postCreatePostApi({bool handleErrors = true, bool is_text = true}) async {
    isCreatePostLoading.value = true;
    for (var media in postMediaArray) {
  if(media.thumbnail != null){
    selectedMediasPath.add(media.media_name!);
    selectedMediasThumbnailPath.add(media.thumbnail!);
  }else{
    selectedMediasPath.add(media.media_name!);
  }
}
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "create_post",
      endPoint: ApiPaths.create_post,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.postMultipart(
      body: {
        "post_type": is_text?AppConstants.postTypeText: AppConstants.postTypeMedia,
        "post_description": txtPostDescription.text,
      },
      imageFile:is_text?{}: {"media": selectedMediasPath, "thumbnail":selectedMediasThumbnailPath},
      
    );

    Log.success("Add Post result: $result");
    await result.fold((l) {
       final status = l['status'];
        final message = l['message']=="null" || l['message']==null ? APIErrorMsg.somethingWentWrong :l['message'] ;

        Log.error("Left from create_post==> $l");
           showTopFlashMessage(ToastType.failure, message.toString());
            //  Get.back();
             Get.back(result: false);
             isCreatePostLoading.value = false;
            // Get.off(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen:false,indexForScreen: 0,));
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status ==  ApiStatus.success) {
          showTopFlashMessage(ToastType.success, r['message'],
              context: Get.context);
              Get.back(result: true);
                // Get.back();
          // Get.off(() =>  HomeScreen(isFromContinueAsGuest: false,isFromChatScreen:false,indexForScreen: 0,));
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
           Get.back(result: false);
        }
        isCreatePostLoading.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    isCreatePostLoading.value = false;
  }

  void submitTextPostClicked() {
    if (isFormValidForText()) {
     postCreatePostApi(is_text:true);
    } 
    }

   void submitPostClicked() {
    if (isFormValid()) {
     postCreatePostApi(is_text:false);
    } 
    
    // Get.to(() =>  HomeScreen(isFromContinueAsGuest:false,isFromChatScreen: false,));
  }

   void save() {
    Get.back(result: true);
  //  Get.back();
  }

}
