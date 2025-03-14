import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team_balance/app/views/settings/notification_screen.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/config/permission_handler.dart';
import 'package:team_balance/config/pick_media_from_camera.dart';

abstract class Picker {
  // // ['jpg', 'jpeg', 'pdf', 'doc']
  // static Future<Either<bool, File>> pickFile({
  //   List<String>? allowedExtensions,
  // }) async {
  //   final FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowedExtensions: allowedExtensions,
  //     type: allowedExtensions == null ? FileType.any : FileType.custom,
  //   );
  //   if (result != null) {
  //     final File file = File(result.files.single.path!);
  //     return Right(file);
  //   } else {
  //     return const Left(false);
  //   }
  // }

//   static Future<Either<bool, File>> pickImage(
//       {ImageSource fromSource = ImageSource.gallery, bool pickOnlyImage = true}) async {
//     try {
//       final picker = ImagePicker();
//       // ignore: unused_local_variable
//       late bool hasPermission;

//       hasPermission = await requestPermission(
//           permission: fromSource == ImageSource.gallery
//               ? Permission.photos
//               : Permission.camera,
//           openAppSettingsIfPermanatDisable: false);
//       // print("hasPermission");
//       // print(hasPermission);
//       try {
//            final pickedFile = pickOnlyImage?await picker.pickImage(
//           source: fromSource,
//           // maxHeight: 500,
//           // maxWidth: 500,
//         ): fromSource == ImageSource.gallery? await picker.pickMedia(
//           // source: fromSource,
//           // maxHeight: 500,
//           // maxWidth: 500,
//         ):await picker.pickVideo(
//           source: fromSource,
//           // source: fromSource,
//           // maxHeight: 500,
//           // maxWidth: 500,
//         );
//         // final pickedFile = await picker.pickImage(
//         //   source: fromSource,
//         //   // maxHeight: 500,
//         //   // maxWidth: 500,
//         // );
//         if (pickedFile != null) {
//           return Right(File(pickedFile.path));
//         }
//       } on PlatformException {
//         hasPermission = await requestPermission(
//             permission: fromSource == ImageSource.gallery
//                 ? Permission.photos
//                 : Permission.camera,
//             openAppSettingsIfPermanatDisable: true);
//       }
//     } catch (e, stacktrace) {
//       Log.error('********** pickImage [$e] **********');
//       Log.error(stacktrace);
//     }
//     return const Left(false);
//   }
// }


// static Future<Either<bool, File>> pickImage({
//   required BuildContext context,
//   ImageSource fromSource = ImageSource.gallery,
//   bool pickOnlyImage = true,
// }) async {
//   try {
//     final picker = ImagePicker();
//     late bool hasPermission;

//     hasPermission = await requestPermission(
//       permission: fromSource == ImageSource.gallery
//           ? Permission.photos
//           : Permission.camera,
//       openAppSettingsIfPermanatDisable: false,
//     );

//     if (!pickOnlyImage) {
//       final result = await showDialog(
//         context: context,
        
//         builder: (context) => ImageSourceOptions(
//           onOptionSelected: (option) async {
//             late final pickedFile;
//             if (option == 'image') {
//               pickedFile = await picker.pickImage(
//                 source: fromSource,
//               );
//             } else if (option == 'video') {
//               pickedFile = await picker.pickVideo(
//                 source: fromSource,
//               );
//             }

//             if (pickedFile != null) {
//               return Right(File(pickedFile.path));
//             } else {
//               return const Left(false);
//             }
//           },
//           fromSource: fromSource,
//         ),
//       );

//       if (result != null) {
//         return result;
//       }
//     } else {
//       final pickedFile = await picker.pickImage(
//         source: fromSource,
//       );

//       if (pickedFile != null) {
//         return Right(File(pickedFile.path));
//       }
//     }
//   } catch (e, stacktrace) {
//     Log.error('********** pickImage [$e] **********');
//     Log.error(stacktrace);
//   }
//   return const Left(false);
// }

static Future<Either<bool, File>> pickImage({
  required BuildContext context,
  ImageSource fromSource = ImageSource.gallery,
  bool pickOnlyImage = true,
}) async {
  try {
    final picker = ImagePicker();
    late bool hasPermission;

    hasPermission = await requestPermission(
      permission: fromSource == ImageSource.gallery
          ? Permission.photos
          : Permission.camera,
      openAppSettingsIfPermanatDisable: false,
    );

    if (pickOnlyImage) {
      final pickedFile = await picker.pickImage(
        source: fromSource,
      );

      if (pickedFile != null) {
        return Right(File(pickedFile.path));
      }
    } else {
      /// This is the code that will be executed if the user wants to pick a camera media
      // final XFile? pickedFile = await Get.to(() =>  PickCamerMedia())!;
      // print('object --->>>   ${pickedFile}');
      //      if (pickedFile != null) {
      //     return Right(File(pickedFile.path));
      //   }
       //   if (pickedFile != null) {
      //     return Right(File(pickedFile.path));
      //   }
      // }

      /// This is the code that will be executed if the user wants to pick a source selected media
           final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Source'),
          content: Text('Do you want to capture an image or record a video?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop('image');
              },
              child: Text('Image'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop('video');
              },
              child: Text('Video'),
            ),
          ],
        ),
      );

      if (result != null) {
        late final pickedFile;
        if (result == 'image') {
          pickedFile = await picker.pickImage(
            source: fromSource,
          );
        } else if (result == 'video') {
          pickedFile = await picker.pickVideo(
            source: fromSource,
            maxDuration: Duration(seconds:40)
          );
        }

        if (pickedFile != null) {
          return Right(File(pickedFile.path));
        }
      }





      // if(fromSource == ImageSource.gallery)
      // {

      //  final pickedFile = await picker.pickMedia(
      //       // source: fromSource,
      //       // maxDuration: Duration(seconds:40)
      //     );
      //      if (pickedFile != null) {
      //     return Right(File(pickedFile.path));
      //   }
       
      // }else{
      //     final result = await showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: Text('Select Source'),
      //     content: Text('Do you want to capture an image or record a video?'),
      //     actions: [
      //       TextButton(
      //         onPressed: () async {
      //           Navigator.of(context).pop('image');
      //         },
      //         child: Text('Image'),
      //       ),
      //       TextButton(
      //         onPressed: () async {
      //           Navigator.of(context).pop('video');
      //         },
      //         child: Text('Video'),
      //       ),
      //     ],
      //   ),
      // );

      // if (result != null) {
      //   late final pickedFile;
      //   if (result == 'image') {
      //     pickedFile = await picker.pickImage(
      //       source: fromSource,
      //     );
      //   } else if (result == 'video') {
      //     pickedFile = await picker.pickVideo(
      //       source: fromSource,
      //       maxDuration: Duration(seconds:40)
      //     );
      //   }

      //   if (pickedFile != null) {
      //     return Right(File(pickedFile.path));
      //   }
      // }
      // }
    
    }
  } catch (e, stacktrace) {
    Log.error('********** pickImage [$e] **********');
    Log.error(stacktrace);
  }
  return const Left(false);
}


}


