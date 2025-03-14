

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/comment_controller.dart';
import 'package:team_balance/app/controllers/dash_board_controller.dart';
import 'package:team_balance/app/controllers/search_post_controller.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class ReportCommentSheet extends StatefulWidget {
  final String commentId;
  // final String reasonId;
  final int index;

  const ReportCommentSheet({
    required this.commentId,
    // required this.reasonId,
    required this.index,
  });

  @override
  _ReportCommentSheetState createState() => _ReportCommentSheetState();
}

class _ReportCommentSheetState extends State<ReportCommentSheet> {
  int selectedReasonIndex = 0;
  int selectedReasonId = 0;
 final CommentController commentController = Get.put(CommentController());
  @override
  Widget build(BuildContext context) {

    selectedReasonId = commentController.reportResaonList[0]!.id!;
    var deviceSize = MediaQuery.of(context).size;
    var imageScale = 2.6;

    return Container(
      height: deviceSize.height * .32,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Container(
        width: 50,
        decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ConstantString.reportReason,
                    style: tbScreenBodyTitle(),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      AppImages.reportmodalcancel,
                      scale: imageScale,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: commentController.reportResaonList
                    .asMap()
                    .entries
                    .map((entry) => Material(
                          color: AppColors.primaryColor,
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedReasonIndex = entry.key;
                                selectedReasonId = entry.value!.id!;

                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 17, horizontal: 20),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        selectedReasonIndex == entry.key
                                            ? AppImages.radioon
                                            : AppImages.radiooff,
                                        scale: imageScale,
                                      ),
                                      SizedBox(
                                        width: AppSizes.double20,
                                      ),
                                      Text(
                                        entry.value!.reportreason!,
                                        style: tbReportReasonTitle(),
                                      ),
                                    ],
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
            ),
            SafeArea(
              child: Center(
                child: Container(
                  height: 50.0,
                  width: deviceSize.width * .68,
                  decoration: BoxDecoration(
                    gradient: AppColors.appGraadient,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: InkWell(
                    onTap: () {
                       print('this is seletcet value ====>');
                      print(selectedReasonId.toString());
                      commentController
                          .postReportCommentApi(
                              commentId: widget.commentId,
                              reasonId: selectedReasonId.toString())
                          .then((value) => Navigator.of(context).pop());
                    },
                    child: 
                    Obx(() => commentController.isLoadingReport.value?AppLoader():Center(
                      child: Text(
                        ConstantString.submit,
                        style: tbTextButton(),
                      ),
                    ),),
                    
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
      ),
    );
  }
}



///     report post

 class ReportReasonDialog extends StatefulWidget {
  final List<PostReportReason?> ?reportReasonList;
  final String postId;
  final int postIdIndex;
  final bool isFromSearchScreen;

   ReportReasonDialog({required this.reportReasonList, required this.postId, required this.postIdIndex, required this.isFromSearchScreen});

  @override
  _ReportReasonDialogState createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<ReportReasonDialog> {
  final DashBoardController dashBoardController = Get.put(DashBoardController());
  final SearchPostController  searchPostController = Get.put(SearchPostController());
  int selectedReasonIndex = -1;
  int  selectedReasonId = 0;

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    var imageScale = 2.6;

    return AlertDialog(
      contentPadding: EdgeInsets.all(10),
      title: Text(
        ConstantString.reportReason,
        style: TextStyle(
          fontSize: 18,
          fontFamily: FontFamilyName.montserrat,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: SizedBox(
        width: deviceSize.width * .9,
        height: deviceSize.height * .25,
        child: ListView.separated(
          itemCount: widget.reportReasonList!.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              endIndent: 25,
              indent: 25,
              color: AppColors.lightGrey,
              height: 1,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                setState(() {
                  selectedReasonIndex = index;
                  selectedReasonId = widget.reportReasonList![index]!.id!;
                });
              },
              leading: Text(widget.reportReasonList![index]!.reportreason!, style: tbReportReason()),
              trailing: selectedReasonIndex == index
                  ? Image.asset(AppImages.radioon, scale: imageScale)
                  : Image.asset(AppImages.radiooff, scale: imageScale),
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only( bottom: AppSizes.double15),
      actions: [
        Container(
          height: 45.0,
          width: deviceSize.width * .35,
          decoration: BoxDecoration(
            color: AppColors.placeHolderGray,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text(
                ConstantString.cancel,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamilyName.montserrat,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 45.0,
          width: deviceSize.width * .35,
          decoration: BoxDecoration(
            gradient: AppColors.appGraadient,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: InkWell(
            onTap: () {
              if (selectedReasonIndex != -1) {
                widget.isFromSearchScreen ?
                searchPostController.postReportPostApi(postId: widget.postId, reasonId: selectedReasonId.toString(), index: widget.postIdIndex).then((value) => Get.back()):
                // Only submit if a reason is selected
                dashBoardController.postReportPostApi(postId: widget.postId, reasonId: selectedReasonId.toString(), index: widget.postIdIndex).then((value) => Get.back());
              }
            },
            child: Center(
              child: Text(
                ConstantString.send,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamilyName.montserrat,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
