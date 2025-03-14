import 'package:flutter/material.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

Future<bool?> chooseFromImageSourceSheet(
  BuildContext context,
) {
  final listOfItem = [
    "Gallery",
    "Camera",
  ];
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.25,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Container(
          height: 4,
          width: 50,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text("Choose from",
                    style: tbScreenBodyTitle()),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: listOfItem
                      .map((e) => Material(
                            color: AppColors.primaryColor,
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pop(e == "Gallery" ? true : false);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 17, horizontal: 20),
                                    child: Text(
                                      e,
                                      style: tbReportReasonTitle(),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
