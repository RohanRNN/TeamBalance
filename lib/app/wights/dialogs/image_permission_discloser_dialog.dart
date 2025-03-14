import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/utils/themes/app_colors.dart';

Future<bool> showImagePermissionDiscloserDialog(
  BuildContext context, {
  String title = "Camera and Gallery permission is needed",
}) async {
  final bool? isPermission = await showDialog(
    context: context,
    builder: (context) => ImagePermissionExplanationDialog(title: title),
  );
  return isPermission ?? false;
}

class ImagePermissionExplanationDialog extends StatelessWidget {
  final String title;
  const ImagePermissionExplanationDialog({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 20),
              const Text(
                "We need Camera and Gallery permission to take photo and set it.",
                style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 19),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: true);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.primaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ],
          )),
    );
  }
}
