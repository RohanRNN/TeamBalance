import 'package:flutter/services.dart';

class AppConstants {
  static const String appName = "TeamBalance";
    static double bottomNavigationBarHeight = 90;
      //timer
  static const int otpTimer = 60;
    //Comment Type
  static const String rememberMeValue = 'remember_me_value';
  static const String guestLoginValue = 'guest_login_value';
  static const String dobFormat = "dd/MM/yyyy";
  static const String postTypeMedia = "Media";
  static const String postTypeText = "Text";
  static const kGoogleApiBrowserKey = "AIzaSyBaFv5O9EahxPMUfbsR3SYJSTIbe4wxoI4";

  // notification type
  static const String notiTypePostlike = "postlike";
  static const String notiTypePostcomment = "postcomment";
  static const String notiTypeNewmessage = "newmessage";
}
class FontFamilyName {
  static const montserrat = 'Montserrat';
}


class NoInitialSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Prevent entering a space as the initial character
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    return newValue;
  }
}


