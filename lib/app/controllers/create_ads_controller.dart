import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/wights/choose_from_imagesouce_sheet.dart.dart';
import 'package:team_balance/app/wights/dialogs/image_permission_discloser_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/picker.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateAdsController extends GetxController {
  File? adsMedia;
  File? thumbnail;
  var businessId = 0;
  List<BusinessPromotionPostcode?>? businesspromotionpostcodes;

  final TextEditingController txtControllerPostDistrict =
      TextEditingController();

  var postCodeList = <PostcodeDistirctData?>[];

  @override
  void onInit() async {
    // MasterDataModel? masterData = await GS.readMasterApiData();
    // if(masterData != null){
    //     postCodeList = masterData.postcodedistirctdata!;
    // }

    super.onInit();
  }


RxBool isMediaLoading = false.obs;
  Future<void> adsMediaCallback(
      BuildContext context, mediaType, pickOnlyImage) async {
    final bool? isGallaryImagePicker =
        await chooseFromImageSourceSheet(context);
    if (isGallaryImagePicker != null) {
      if (Platform.isAndroid) {
        // final hasAgreedToDiscloser =
        //     // ignore: use_build_context_synchronously
        //     await showImagePermissionDiscloserDialog(context);
        // if (hasAgreedToDiscloser == false) {
        //   return;
        // }
      }
      late final Either<bool, File> result;
      if (isGallaryImagePicker) {
        result = await Picker.pickImage(
            context: context,
            fromSource: ImageSource.gallery,
            pickOnlyImage: pickOnlyImage);
      } else {
        result = await Picker.pickImage(
            context: context,
            fromSource: ImageSource.camera,
            pickOnlyImage: pickOnlyImage);
      }
      isMediaLoading.value = true; 
      result.fold((l) {
        isMediaLoading.value = false; 
      }, (r) async {
             final fileSize = await r.length(); 
         final fileSizeInMB = fileSize / (1024 * 1024); 

         if (fileSizeInMB > 150) {
              showTopFlashMessage(ToastType.failure, "File size exceeds 150 MB limit.");
           print("File size exceeds 150 MB limit.");
           return;
         }
        if (mediaType == 1) {
          adsMedia = r;
        } else if (mediaType == 2) {
          if (isVideo(r)) {
            Log.success("Video path==> ${r.path}");
            final thumbnailFileName = await VideoThumbnail.thumbnailFile(
                video: r.path,
                thumbnailPath: (await getTemporaryDirectory()).path,
                imageFormat: ImageFormat.PNG);
            thumbnail = File(thumbnailFileName!);
            adsMedia = r;
          } else {
            adsMedia = r;
          }
        } else if (mediaType == 3) {
          thumbnail = r;
        } else {
          adsMedia = r;
        }
        update([GetBuilderIds.addAdsMedia]);
        isMediaLoading.value = false; 
      });
    }
  }

  bool isImage(File file) {
    final imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp'
    ]; // Add more if needed
    final extension = file.path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  bool isVideo(File file) {
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv']; // Add more if needed
    final extension = file.path.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }

  bool isFormValid() {
    if (adsMedia == null) {
      showTopFlashMessage(
          ToastType.info, 'Please add image/vidoe for the post.',
          context: Get.context);
      return false;
    }
    if (txtControllerPostDistrict.text.isEmpty) {
      showTopFlashMessage(ToastType.info,
          'Please enter Post code district for the ads to be visiable.',
          context: Get.context);
      return false;
    }
    return true;
  }

///////////////////////////    upload new post
  RxBool isCreateAdsLoading = false.obs;
  Future<void> postCreatePostApi(
      {bool handleErrors = true, bool is_text = true}) async {
    isCreateAdsLoading.value = true;
    await GetStorage.init();
    final apiHelper = ApiHelper(
      serviceName: "create_business_advertisement",
      endPoint: ApiPaths.create_business_advertisement,
      showErrorDialog: handleErrors,
      showTransparentOverlay: true,
    );

    final result = await apiHelper.postMultipart(
      body: {
        "business_id": businessId,
        "postcode_district": txtControllerPostDistrict.text,
      },
      imageFile: thumbnail == null
          ? {
              "advertisement_media": [adsMedia!]
            }
          : {
              "advertisement_media": [adsMedia!],
              "advertisement_thumbnail": [thumbnail!]
            },
    );

    Log.success("Add Ads result: $result");
    await result.fold((l) {
      final status = l['status'];
      final message = l['message'] == null || l['message'] == "null"
          ? APIErrorMsg.somethingWentWrong
          : l['message'];
      showTopFlashMessage(ToastType.failure, message.toString());
      Get.back(result: false);
    }, (r) async {
      try {
        final status = r['status'];
        final message = r['message'];
        if (status == ApiStatus.success) {
          showTopFlashMessage(ToastType.success, r['message'],
              context: Get.context);
          Get.back(result: true);
        } else {
          showTopFlashMessage(ToastType.failure, message.toString());
          Get.back(result: false);
        }

        isCreateAdsLoading.value = false;
        return;
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
    });
    isCreateAdsLoading.value = false;
  }

  void submitPostClicked() {
    if (isFormValid()) {
      postCreatePostApi();
    }
    // Get.back();
    // Get.to(() => const MyBusinessScreen());
  }

  void save() {
    Get.back();
  }
}
