import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/utils/themes/app_colors.dart';

void errorDialog({
  required String title,
  String? message,
  bool goBack = false,
}) {
  if (goBack) Get.back();
  if (Get.isDialogOpen! == false) {
    Get.defaultDialog(
      title: title,
      titlePadding: const EdgeInsets.only(top: 20.0, left: 5, right: 5),
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 30,
            color: Colors.red,
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5, left: 5),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                      color: AppColors.textBoldColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
      cancel: TextButton(
        onPressed: Get.back,
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(AppColors.blueThemeColor),
            // splashFactory: NoSplash.splashFactory,
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 30))),
        child: Text(
          'OK',
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  } else {
    Log.info("dialog is opened so can't override the existing one...");
  }
}
