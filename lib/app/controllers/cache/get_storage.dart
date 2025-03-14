import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/app/controllers/cache/prefs_key.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/config/api/socket_utils.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

// *  GS - GetStorage
abstract class GS {
  static Future<dynamic> read(GetStorage storage, {required String key}) async {
    if (storage.hasData(key)) {
      return await storage.read(key);
    }
    return null;
  }

  static Future<dynamic> write(GetStorage storage,
      {required String key, required dynamic value}) async {
    try {
      await storage.write(key, value);
      return value;
    } catch (e) {
      Log.error("Error while writing to GS : $e");
    }
  }

  // * READ user_data
  static Rxn<UserModel> userData = Rxn<UserModel>();
  static Rxn<HelpAndSupport> helpAndSupport = Rxn<HelpAndSupport>();
  static Rxn<MasterDataModel> masterApiData = Rxn<MasterDataModel>();

  static Future<UserModel?> readUserData() async {
    final GetStorage storage = GetStorage();
    final result = await read(storage, key: PrefsKey.userData.name);
    if (result != null) {
      Log.info('USER RESULT: $result');
      userData.value = UserModel.fromJson(result as Map<String, dynamic>);
    } else {
      Log.error('not have userData');
    }
    return userData.value;
  }

//  static Future<void> clearUserData() async {
//     final GetStorage storage = GetStorage();
//     await storage.remove(PrefsKey.userData.name);
//   }
  static Future<void> clearUserData() async {
    final GetStorage storage = GetStorage();
    await storage.remove(PrefsKey.userData.name);
    userData.value = null;
    userData.refresh();
  }

  static Future<void> writeUserData(UserModel data) async {
    final GetStorage storage = GetStorage();
    await write(storage, key: PrefsKey.userData.name, value: data.toJson());
    userData.value = data;
    Log.info("USER DATA 123: ${data.toJson()}");
    Log.info("USER DATA postcode: ${data.postcodedistirct}");
  }

  static Future<HelpAndSupport?> readHelpAndSupportData() async {
    final GetStorage storage = GetStorage();
    final result = await read(storage, key: PrefsKey.helpAndSupport.name);
    if (result != null) {
      Log.info('Help And Support RESULT: $result');
      helpAndSupport.value =
          HelpAndSupport.fromJson(result as Map<String, dynamic>);
    } else {
      Log.error('not have userData');
    }
    return helpAndSupport.value;
  }

  static Future<void> writeHelpAndSupportData(HelpAndSupport data) async {
    final GetStorage storage = GetStorage();
    await write(storage,
        key: PrefsKey.helpAndSupport.name, value: data.toJson());
    helpAndSupport.value = data;
  }

  static Future<void> writeMasterApiData(MasterDataModel data) async {
    final GetStorage storage = GetStorage();
    await write(storage,
        key: PrefsKey.masterApiData.name, value: data.toJson());
    masterApiData.value = data;
  }

  static Future<MasterDataModel?> readMasterApiData() async {
    final GetStorage storage = GetStorage();
    final result = await read(storage, key: PrefsKey.masterApiData.name);
    if (result != null) {
      Log.info('Master Data RESULT: $result');
      masterApiData.value =
          MasterDataModel.fromJson(result as Map<String, dynamic>);
    } else {
      Log.error('not have userData');
    }
    return masterApiData.value;
  }

  static Future<bool> readRememberMe() async {
    final GetStorage storage = GetStorage();
    final rememberMe = await read(storage, key: AppConstants.rememberMeValue);
    return rememberMe ?? false;
  }

  static Future<void> writeRememberMe(bool value) async {
    final GetStorage storage = GetStorage();
    await write(storage, key: AppConstants.rememberMeValue, value: value);
  }

  static Future<bool> readGuestLogin() async {
    final GetStorage storage = GetStorage();
    final GuestLogin = await read(storage, key: AppConstants.guestLoginValue);
    return GuestLogin ?? false;
  }

  static Future<void> writeGuestLogin(bool value) async {
    final GetStorage storage = GetStorage();
    await write(storage, key: AppConstants.guestLoginValue, value: value);
  }

  static Future<void> writeIsAddedAccountDetails(bool value) async {
    final GetStorage storage = GetStorage();
    await write(storage,
        key: PrefsKey.isAddedAccountDetails.name, value: value);
  }

  static Future<void> writeIsAddedPersonalDetails(bool value) async {
    final GetStorage storage = GetStorage();
    await write(storage,
        key: PrefsKey.isAddedPersonalDetails.name, value: value);
  }

  static Future<void> writeTutorialSeen(bool value) async {
    final GetStorage storage = GetStorage();
    await write(storage, key: PrefsKey.tutorialSeen.name, value: value);

    print(
        "from write========> ${await storage.read(PrefsKey.tutorialSeen.name)}");
    print("from read========> ${await readTutorialSeen()}");
  }

  // READ
  static Future<bool> readIsAddedAccountDetails() async {
    final GetStorage storage = GetStorage();
    final isAdded = await GS.read(storage,
        key: PrefsKey.isAddedAccountDetails.name) as bool?;
    return isAdded ?? false;
  }

  static Future<bool> readIsAddedPersonalDetails() async {
    final GetStorage storage = GetStorage();
    final isAdded = await GS.read(storage,
        key: PrefsKey.isAddedPersonalDetails.name) as bool?;
    return isAdded ?? false;
  }

  static Future<bool> readTutorialSeen() async {
    final GetStorage storage = GetStorage();
    final isSeen =
        await GS.read(storage, key: PrefsKey.tutorialSeen.name) as bool?;
    return isSeen ?? false;
  }

  static Future<void> clearAll() async {
    await GetStorage().erase();
    // userData.value = null;
    GSAPIHeaders.bearerToken = null;
    GSAPIHeaders.userToken = null;
    GSAPIHeaders.fcmToken = null;
    GSAPIHeaders.loginToken = null;
    GSAPIHeaders.isGuestAccount = 0;
    GS.writeTutorialSeen(true);
    Log.success('cleared ALL');
  }
}

Future<void> clearDataAndNavigateToLogin() async {
  SocketUtils.disconnetSocket();
  SocketUtils.socket.disconnect();
  await dbHelper.clearDatabase();

  //  GS.clearAll();
  var deviceToke = '';
  if (GSAPIHeaders.fcmToken != null && GSAPIHeaders.fcmToken!.isNotEmpty) {
    deviceToke = GSAPIHeaders.fcmToken ?? '';
  }
  await GS.clearUserData();
  await GS.clearAll();
  await GetStorage().erase(); 
  await Future.delayed(Duration(milliseconds: 200));
  await GS.writeTutorialSeen(true);
  Log.info('LOGOUT TOKE: $deviceToke');
  GSAPIHeaders.fcmToken = deviceToke;
  await Get.offAll(() => const LoginScreen());
}

// * HEADERS DATA
abstract class GSAPIHeaders {
  static String? fcmToken;
  static String? bearerToken;
  static String? userToken;
  static String? loginToken;
  static int? isGuestAccount;

  // READ
  static Future<void> readAll() async {
    final GetStorage storage = GetStorage();
    bearerToken =
        await GS.read(storage, key: PrefsKey.bearerToken.name) as String?;
    userToken = await GS.read(storage, key: PrefsKey.userToken.name) as String?;
    fcmToken = await GS.read(storage, key: PrefsKey.fcmToken.name) as String?;
  }

  static Future<void> writeBearerToken(String token) async {
    final GetStorage storage = GetStorage();
    bearerToken = await GS.write(storage,
        key: PrefsKey.bearerToken.name, value: token) as String;
  }

  static Future<void> writeLoginToken(String token) async {
    final GetStorage storage = GetStorage();
    loginToken = await GS.write(storage,
        key: PrefsKey.loginToken.name, value: token) as String;
  }

  static Future<void> writeUserToken(String token) async {
    final GetStorage storage = GetStorage();
    userToken = await GS.write(storage,
        key: PrefsKey.userToken.name, value: token) as String;
  }

  static Future<void> writeDeviceToken(String token) async {
    final GetStorage storage = GetStorage();
    fcmToken = await GS.write(storage,
        key: PrefsKey.fcmToken.name, value: token) as String;
  }
}
