import 'package:permission_handler/permission_handler.dart';

import 'log_helper.dart';


Future<bool> getActivityRecognitionPermissionStatus(
    {bool openAppSettingsIfPermanatDisable = true}) async {
  PermissionStatus? status;
  try {
    status = await Permission.activityRecognition.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isDenied || status.isRestricted) {
      status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        return true;
      }
    }
    if (status.isPermanentlyDenied && openAppSettingsIfPermanatDisable) {
      await openAppSettings();
      return false;
    }
    return false;
  } finally {
    Log.info("Permission status :: $status");
  }
}

Future<bool> requestPermission(
    {required Permission permission,
    bool openAppSettingsIfPermanatDisable = true}) async {
  PermissionStatus? status;
  try {
    status = await permission.status;
    // print('curr status');
    // print(status);
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      // print('yes requested');
      status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }
    if ((status.isDenied || status.isPermanentlyDenied) &&
        openAppSettingsIfPermanatDisable) {
      await openAppSettings();
    }
    return false;
  }
    catch(error){
     Log.info(error);
    return false;
  }  
  finally {
    Log.info("$permission status :: $status");
  }
  
}

Future<bool> requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;
  print('this is in main function');
  print(status);
  if (status.isGranted || status.isLimited) {
    return true;
  }
  if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
    print('this is inside function');
    status = await Permission.notification.request();    
    if (status.isGranted || status.isLimited) {
      return true;
    }
  }
  return false;
}
