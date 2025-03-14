
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/settings/profile/edit_profile_screen.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/models/user_model.dart';


class ProfileController extends GetxController {
  final UserModel userData = GS.userData.value!;
   final List<String> gender = [
  '---',
  'Male',
  'Female',
  ];

  RxBool isGuestLogin = false.obs;
  void setGuestAccount() async {
    isGuestLogin.value = await GS.readGuestLogin();
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

   void editProfileScreen() {
    Get.to(() =>  EditProfileScreen(
      userModelValue: userData,
    ));
  }

    String formatDOB(String? dob) {
  if (dob == null) return '---';
  try {
    DateTime parsedDate = DateTime.parse(dob);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    // Handle the error or return a default value if the date format is invalid
    return '---';
  }
}
 
}
