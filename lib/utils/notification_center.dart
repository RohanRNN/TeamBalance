import 'dart:async';

import 'package:team_balance/config/log_helper.dart';


class CustomeNotificationCenter {
  CustomeNotificationCenter._privateConstructor();
  static final CustomeNotificationCenter instance =
      CustomeNotificationCenter._privateConstructor();

  static final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void post(String notificationName, {Map<String, dynamic>? userInfo}) {
    _controller.add({'name': notificationName, 'userInfo': userInfo});
  }

  void dispose() {
    Log.info('DISPOST CUSTOME NOTI');
    _controller.close();
  }
}
