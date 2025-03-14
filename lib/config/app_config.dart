// ignore: unused_import
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppConfig {
  static const String appName = "TeamBalance";

  static late final PackageInfo packageInfo;

  static bool get isDebugMode =>
      //
      false;
  // kDebugMode;
  // static bool get isDebugMode => ;
  // static bool get setNoValidation => kDebugMode;

  // TODO: this should be +44
  static const String twilioCountryCode = "44";

  // TODO: this should be 0 in production
  // static const int isTestData = 1;
  static const int isTestData = 0;

  // App version
  static const String appVersion= "1.0.1";

   // App Update link
  static const String urlForUpdate= "https://teambalance.uk/";
  static const String termsOfUseLink = "https://api.teambalance.uk/docs/terms.pdf";
  static const String privacyPolicyLink = "https://api.teambalance.uk/docs/privacy_policy.pdf";
  static const String androidUrl = "https://play.google.com/store/apps/details?id=team_balance.com.android";
  static const String iosUrl = "https://apps.apple.com/app/id6670791309";

  //
  static const String validateReceiptIosPassword = "4302616d9d8c4b2bbe9d1751a5a277b8";

// TODO: this should be true in production
  static const bool isInProduction = false;

  static const isLandscapeOrientationSupported = false;


}
