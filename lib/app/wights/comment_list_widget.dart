import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/comment_controller.dart';
import 'package:team_balance/app/wights/radio_button_widget.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';

class CommentListWidget extends StatefulWidget {
  CommentListWidget({
    super.key,
    required this.commentData,
    required this.index,
    required this.onFocusChange,
  });
  final int index;
  final CommentModel commentData;
  final Function(bool) onFocusChange;

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  final CommentController commentController = Get.put(CommentController());
  var subComment = false;
  var subCommentImg = false;
  final FocusNode commentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Add listener to the FocusNode
    commentFocusNode.addListener(() {
      if (widget.onFocusChange != null) {
        widget.onFocusChange!(commentFocusNode.hasFocus);
      }
    });
    return   widgetCommentList();
  }

  Widget widgetCommentList() {
    var date = DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(widget.commentData.createdAt!).toLocal()) ??
        '';
    var time = DateFormat('hh:mm a')
            .format(DateTime.parse(widget.commentData.createdAt!).toLocal()) ??
        '';
    // var subComment = false;
    var deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(right: 20, left: 10, bottom: 10),
        // padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: ClipOval(
                        child: widget.commentData.profileImage != ''
                            ? CachedNetworkImage(
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                imageUrl: ApiPaths.profilePath +
                                    widget.commentData.profileImage,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    widgetPlaceholderImage(),
                              )
                            : widgetPlaceholderImage(),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: AppSizes.double5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.commentData.fullName,
                            style: const TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                          Text(
                            '${date} ${time}',
                            style: const TextStyle(
                                color: AppColors.mediumGrey,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.double5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.commentData.comment}',
                              maxLines: null,
                              style: const TextStyle(
                                  color: AppColors.black,
                                  fontFamily: FontFamilyName.montserrat,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ),
                          widget.commentData.userId == GS.userData.value!.id
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    print(widget.commentData.id.toString());
                                    reportCommentSheet(
                                        context,
                                        widget.commentData.id.toString(),
                                        widget.index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, right: 5.0 ,left: 15.0,),
                                    child: Image.asset(
                                      AppImages.commentpagemoreicon,
                                      scale: 2.6,
                                    ),
                                  ),
                                )
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.double15,
                      ),
                      widgetButtons(widget.index),
                      SizedBox(
                        height: AppSizes.double15,
                      ),
                      // widgetSendReplySection(),
                      if (widget.commentData.subCommentsData?.isNotEmpty ??
                          false)
                        // GetBuilder<CommentController>(
                        //   id: GetBuilderIds.replyOnComment,
                        //   builder: (controller) =>
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          itemCount: widget.commentData.subCommentsData.length,
                          itemBuilder: (context, index) {
                            return widgetReplyTextOnComment(
                              replyIndex: index,
                            );
                          },
                        ),
                      // ),
                      widgetDivider(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetButtons(int index) {
    return
        // subComment?
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 2,
        ),
        InkWell(
          onTap: () {
            setState(() {
              subComment = !subComment;
            });

            // commentController.postCreateCommentApi(
            //               commentId: "152",
            //               is_text: true,
            //               is_subComment: true,
            //               commentText: commentController.txtComment.text);
            // commentController.tapOnReplyButton(widget.index);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8, right: 8),
            child: Image.asset(
              AppImages.reply,
              scale: 2.5,
            ),
          ),
        ),
     
        SizedBox(
          height: 2,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: subComment ? 120.0 : 0.0,
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.lightGrey,
                )),
            height: subComment ? 120.0 : 0.0,
            width: AppSizes.double500,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  subCommentImg && commentController.commentMediaFile != null
                      ? SizedBox()
                      : TextFormField(
                          focusNode: commentFocusNode,
                          style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontFamily: FontFamilyName.montserrat,
                              fontWeight: FontWeight.w600),
                          cursorColor: AppColors.blueThemeColor,
                          cursorHeight: 30,
                          controller: commentController.txtReplyComment,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: AppColors.lightGrey,
                                  fontSize: 14,
                                  fontFamily: FontFamilyName.montserrat,
                                  fontWeight: FontWeight.w600),
                              hintText: 'Type your text here...',
                              border: InputBorder.none),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      subCommentImg &&
                              commentController.commentMediaFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  Container(
                                    child: Image.file(
                                      commentController.commentMediaFile!,
                                      fit: BoxFit.cover,
                                    ),
                                    height: 80,
                                    width: 80,
                                  ),
                                  Positioned(
                                      top: 5,
                                      right: 5,
                                      child: InkWell(
                                          onTap: () {
                                            commentController.commentMediaFile =
                                                null;
                                            subCommentImg = false;
                                            setState(() {});
                                          },
                                          child: Image.asset(
                                            AppImages.removephoto,
                                            scale: 3,
                                          )))
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                print("Tap on image");
                                commentController
                                    .commentMediaCallback(context)
                                    .then((value) {
                                  setState(() {
                                    subCommentImg = true;
                                  });
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: AppColors.placeHolderGray,
                                radius: AppSizes.double18,
                                child: Image.asset(
                                  AppImages.thumbnail,
                                  scale: 8,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                      InkWell(
                        onTap: () {
                          if (commentController.txtReplyComment.text != '') {
                            setState(() {
                              // commentController.txtReplyComment.text = '';
                              subComment = false;
                              // subCommentImg = false;
                              // commentController.commentMediaFile = null;
                            });
                            commentController
                                .postCreateCommentApi(
                                    postId:
                                        widget.commentData.postId.toString(),
                                    commentId: widget.commentData.id.toString(),
                                    isText: !subCommentImg,
                                    isSubComment: true,
                                    commentText:
                                        commentController.txtReplyComment.text,
                                    index: index)
                                .then((value) => setState(() {
                                      commentController.txtReplyComment.text =
                                          '';
                                      subComment = false;
                                      subCommentImg = false;
                                      commentController.commentMediaFile = null;
                                    }));
                          } else if (commentController.commentMediaFile?.path !=
                              null) {
                            print(
                                "Comment Media File==> ${commentController.commentMediaFile?.path}");
                            setState(() {
                              // commentController.txtReplyComment.text = '';
                              subComment = false;
                              // subCommentImg = false;
                              // commentController.commentMediaFile = null;
                            });
                           commentController.isReplyLoading.value=true;
                            commentController
                                .postCreateCommentApi(
                                    postId:
                                        widget.commentData.postId.toString(),
                                    commentId: widget.commentData.id.toString(),
                                    isText: false,
                                    isSubComment: true,
                                    commentText:
                                        commentController.txtReplyComment.text,
                                    index: index)
                                .then((value) => setState(() {
                                      commentController.txtReplyComment.text =
                                          '';
                                      subComment = false;
                                      subCommentImg = false;
                                      commentController.commentMediaFile = null;
                                    }));
                          }
                        },
                        child: Padding(
                          padding: subCommentImg &&
                                  commentController.commentMediaFile != null
                              ? const EdgeInsets.only(top: 50.0, bottom: 5)
                              : const EdgeInsets.only(top: 00.0, bottom: 5),
                          child: Image.asset(
                            AppImages.commentsend,
                            scale: 2.5,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: subComment ? AppSizes.double20 : 0.0,
        )
      ],
    );
    // :
    // Row(
    //   children: [
    //     SizedBox(height: AppSizes.double10,),
    //     InkWell(
    //       onTap: () {
    //         setState(() {
    //            subComment = !subComment;
    //         });

    //         // commentController.postCreateCommentApi(
    //         //               commentId: "152",
    //         //               is_text: true,
    //         //               is_subComment: true,
    //         //               commentText: commentController.txtComment.text);
    //         // commentController.tapOnReplyButton(widget.index);
    //       },
    //       child: Image.asset(
    //         AppImages.reply,
    //         scale: 2.5,
    //       ),
    //     ),
    //     const SizedBox(
    //       width: 10,
    //     ),
    //     SizedBox(height: AppSizes.double10,),

    //   ],
    // );
  }

  Widget widgetDivider() {
    return const Divider(
      color: AppColors.lightGrey,
      height: 0.5,
      thickness: 0.2,
    );
  }

  Widget widgetReplyTextOnComment({
    required int replyIndex,
  }) {
    // var date = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.commentData.subCommentsData[replyIndex].createdAt!)) ?? '';
    // var time =  DateFormat('hh:mm a').format(DateTime.parse(widget.commentData.subCommentsData[replyIndex].createdAt!)) ?? '';
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: ClipOval(
                        child: widget.commentData.subCommentsData[replyIndex]
                                    .profileImage !=
                                ''
                            ? CachedNetworkImage(
                                height: 35,
                                width: 35,
                                fit: BoxFit.cover,
                                imageUrl: ApiPaths.profilePath +
                                    widget
                                        .commentData
                                        .subCommentsData[replyIndex]
                                        .profileImage,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    widgetPlaceholderImage(),
                              )
                            : widgetPlaceholderImage(),
                      ),
                    ),
                    Container(),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${widget.commentData.subCommentsData[replyIndex].fullName}',
                            style: const TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                          Text(
                            '${widget.commentData.subCommentsData[replyIndex].createdAt} ${widget.commentData.subCommentsData[replyIndex].createdAt}',
                            style: const TextStyle(
                                color: AppColors.mediumGrey,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.double5),
                      widget.commentData.subCommentsData[replyIndex]
                                  .commentType ==
                              "Text"
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.commentData.subCommentsData[replyIndex].comment}',
                                  maxLines: null,
                                  style: const TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                               
                                widget.commentData.subCommentsData[replyIndex].userId ==
                                        GS.userData.value!.id
                                    ? SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          reportCommentSheet(
                                              context,
                                              widget.commentData.subCommentsData[replyIndex].id.toString(),
                                              widget.index);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, right: 5.0, left: 15),
                                          child: Image.asset(
                                            AppImages.commentpagemoreicon,
                                            scale: 2.6,
                                          ),
                                        ),
                                      )
                              ],
                            )
                          : widget.commentData.subCommentsData[replyIndex]
                                      .commentMediaData.length ==
                                  0
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.lightGrey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: AppSizes.double120,
                                      width: AppSizes.double150,
                                      child: AppLoader(),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(() => ImageFullScreenScreen(
                                                imageUrl:
                                                    ApiPaths.commentMediaPath +
                                                        widget
                                                            .commentData
                                                            .subCommentsData[
                                                                replyIndex]
                                                            .commentMediaData[0]
                                                            .commentMediaName!,
                                              ));
                                          //  Navigator.push(
                                          //    context,
                                          //    MaterialPageRoute(
                                          //      builder: (context) => ImageFullScreenScreen(
                                          //        imageUrl: ApiPaths.commentMediaPath +
                                          //            widget.commentData.subCommentsData[replyIndex].commentMediaData[0].commentMediaName!,
                                          //      ),
                                          //    ),
                                          //  );
                                        },
                                        child: Hero(
                                          tag: 'profileImageHero',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: SizedBox(
                                                height: AppSizes.double120,
                                                width: AppSizes.double150,
                                                child: CachedNetworkImage(
                                                  height: 35,
                                                  width: 35,
                                                  fit: BoxFit.cover,
                                                  imageUrl: ApiPaths
                                                          .commentMediaPath +
                                                      widget
                                                          .commentData
                                                          .subCommentsData[
                                                              replyIndex]
                                                          .commentMediaData[0]
                                                          .commentMediaName!,
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              downloadProgress) =>
                                                          SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      widgetPlaceholderImage(),
                                                )
                                                // Image.network(ApiPaths.commentMediaPath +
                                                //              widget.commentData.subCommentsData[replyIndex].commentMediaData[0].commentMediaName!,fit: BoxFit.cover,),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    widget.commentData.subCommentsData[replyIndex].userId ==
                                        GS.userData.value!.id
                                        ? SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              reportCommentSheet(
                                                  context,
                                                  widget.commentData.subCommentsData[replyIndex].id
                                                      .toString(),
                                                  widget.index);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 0.0,
                                                right: 5.0,
                                                left: 15.0
                                              ),
                                              child: Image.asset(
                                                AppImages.commentpagemoreicon,
                                                scale: 2.6,
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetSendReplySection() {
    return GetBuilder<CommentController>(
        id: GetBuilderIds.replyOnComment,
        builder: (controller) => Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.mediumGrey,
                      strokeAlign: 0.5,
                      width: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: widgetPlaceholderImage(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: TextFormField(
                                controller: commentController.txtReplyComment,
                                textInputAction: TextInputAction.next,
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message here',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 5),
                                ),
                                style: const TextStyle(
                                    color: AppColors.black,
                                    fontFamily: FontFamilyName.montserrat,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                                maxLines: 4,
                                minLines: 1,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            // commentController.tapOnAddCommentButton(
                            //   commentType: AppConstants.commentTypeComment,
                            //   id: 10,
                            //   comment: commentController.txtReplyComment.text,
                            // );
                            commentController.txtReplyComment.clear();
                          },
                          padding: EdgeInsets.zero,
                          icon: Image.asset(
                            AppImages.commentsend,
                            height: 33,
                            width: 33,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget widgetPlaceholderImage() {
    return Container(
      color: AppColors.placeHolderGray,
      height: 40,
      width: 40,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          AppImages.profileplaceholder,      
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> reportCommentSheet(
      BuildContext context, String commentId, int index) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (context) => ReportCommentSheet(
        commentId: commentId,
        index: index,
      ),
    );
  }
}

class ImageFullScreenScreen extends StatelessWidget {
  final String imageUrl;

  const ImageFullScreenScreen({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Hero(
          tag: 'profileImageHero',
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.backGroundImg),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
                child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: CachedNetworkImage(
                // fit: BoxFit.contain,
                fit: BoxFit.cover,
                imageUrl: imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  height: 30,
                  width: 30,
                  child: Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    widgetImagePlaceholder(200, 400),
              ),
            )
                // Image.network(
                //   imageUrl,
                //   fit: BoxFit.contain,
                //   height: MediaQuery.of(context).size.height,
                //   width: MediaQuery.of(context).size.width,
                // ),
                ),
          ),
        ),
      ),
    );
  }

  Widget widgetImagePlaceholder(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: const AssetImage(AppImages.adshomeplaceholder),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
        ),
      ),
    );
  }
}
