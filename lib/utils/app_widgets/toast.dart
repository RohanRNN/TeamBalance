import 'dart:async';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/themes/app_colors.dart';

enum ToastType {
  success,
  failure,
  info,
}

extension CheckToastType on ToastType {
  bool get isSuccess => this == ToastType.success;
  bool get isFailure => this == ToastType.failure;
  bool get isInfo => this == ToastType.info;
}

void showTopFlashMessage(ToastType toastType, String message,
    {BuildContext? context}) {
  // if (!mounted) return;
  try {
    final currContext = context ?? Get.context!;
    showFlash(
        context: currContext,
        duration: const Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.top,
            child: FlashBar(
              position: FlashPosition.top,
              behavior: FlashBehavior.fixed,
              icon: Icon(
                toastType.isFailure
                    ? Icons.close_sharp
                    : toastType.isSuccess
                        ? Icons.check_circle
                        : Icons.priority_high_rounded,
                size: 30,
                color: Colors.black,
              ),
              backgroundColor: toastType.isFailure
                  ? Colors.red.shade300
                  : toastType.isSuccess
                      ? Colors.green.shade300
                      : AppColors.blueThemeColor,
              content: Text(message,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              controller: controller,
            ),
          );
        });
  } catch (e) {
    Log.error('showTopFlashMessage catch error : ($e)');
  }
}

RxBool isTimerRunning = false.obs;

Future<bool> willPopCallBack() async {
  if (!isTimerRunning.value) {
    isTimerRunning.value = true;
    Timer.periodic(const Duration(seconds: 2), (time) {
      isTimerRunning.value = false;
      time.cancel();
    });
    showTopFlashMessage(ToastType.info, 'Press back again to exit');
    return false;
  }
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  return true;
}

class FlashMessageController {
  DateTime? _lastMessageTime;
  String? _lastMessage;
  final Duration _threshold = const Duration(seconds: 30);

  void showMessage(ToastType type, String message) {
    final now = DateTime.now();
    if (_lastMessageTime == null ||
        _lastMessage == null ||
        now.difference(_lastMessageTime!) > _threshold ||
        _lastMessage != message) {
      _lastMessageTime = now;
      _lastMessage = message;
      showTopFlashMessage(type, message);
    }
  }
}