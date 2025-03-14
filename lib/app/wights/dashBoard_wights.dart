import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/dash_board_controller.dart';
import 'package:team_balance/app/controllers/my_post_controller.dart';
import 'package:team_balance/app/controllers/search_post_controller.dart';
import 'package:team_balance/app/views/settings/profile/other_user_profile_screen.dart';
import 'package:team_balance/app/views/settings/profile/profile_screen.dart';
import 'package:team_balance/app/views/video_player/videoplay.dart';
import 'package:team_balance/app/wights/radio_button_widget.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/main.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CustomPostWidget extends StatefulWidget {
  CustomPostWidget({
    super.key,
    required this.arrayOfPost,
    required this.isFromMyPostScreen,
    required this.isFromSearchScreen,
  });

  var arrayOfPost = <PostModel>[].obs;
  final bool isFromMyPostScreen;
  final bool isFromSearchScreen;

  @override
  State<CustomPostWidget> createState() => _CustomPostWidgetState();
}

class _CustomPostWidgetState extends State<CustomPostWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
  final DashBoardController dashBoardController =
      Get.put(DashBoardController());
  final MyPostController myPostController = Get.put(MyPostController());
  final SearchPostController searchPostController = Get.put(SearchPostController());
  PageController pageController = PageController(initialPage: 0);
  RxInt activePage = 0.obs;
  RxInt currentPostNumber = 1.obs;
  List<int> imagePageCount = [];

  List<PageController> pageControllers = [];

// Initialize page controllers based on the length of your data

// format count
String formatCount(int count) {
  if (count >= 1000) {
    return (count / 1000).toStringAsFixed(1).replaceAll(".0", "") + "K";
  }
  return count.toString();
}

  @override
  Widget build(BuildContext context) {
    const imageScale = 2.5;
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    int _currentPage = 0;
    var deviceSize = MediaQuery.of(context).size;

    return Obx(() {
      for (int i = 0; i < widget.arrayOfPost.length; i++) {
        pageControllers.add(PageController(initialPage: 0));
        imagePageCount.add(0);
      }
      return
          //  widget.arrayOfPost.isEmpty? Center(child:Padding(
          //                                padding: const EdgeInsets.all(8.0),
          //                                child: Text(ConstantString.noPostFound,style: tbNoDataFoundTextStyle(),textAlign: TextAlign.center,),
          //                              ) ,):
          //   RefreshIndicator(
          // // color: Colors.transparent,
          // // backgroundColor: Colors.transparent,
          // onRefresh: widget.isFromMyPostScreen
          //     ? myPostController.onRefresh
          //     : dashBoardController.onRefresh,
          // child:
          // Center(
          // child:
          Column(
        //  children: List.generate(1, (mainIndex) =>
        children:
            //  dashBoardController.isAdsLoading.value
            //                  ? List.generate(3, (index) => Padding(
            //                     padding: const EdgeInsets.all(25.0),                                           child: Shimmer.fromColors(
            //                          baseColor: Colors.grey[400]!,
            //                          highlightColor: Colors.grey[100]!,
            //                          child: Container(
            //                            height: MediaQuery.of(context).size.height * .525, // Match the height of your actual carousel item
            //                            decoration: BoxDecoration(
            //                              color: Colors.grey[300], // Placeholder color
            //                              borderRadius: BorderRadius.circular(20),
            //                            ),
            //                          ),
            //                        ),
            //                      )):
            List.generate(
          widget.arrayOfPost.length,
          (mainIndex) => Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 3.0)),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(0)),
              //  height:
              //  widget.arrayOfPost[mainIndex].posttype != AppConstants.postTypeText ?

              //  MediaQuery.of(context).size.height * .525: null,
              // height: widget.arrayOfPost[mainIndex].posttype == AppConstants.postTypeText ?
              // Platform.isAndroid? MediaQuery.of(context).size.height * .375: MediaQuery.of(context).size.height * .38
              // : MediaQuery.of(context).size.height * .525,
              // width: deviceSize.width*.9,
              child:
                  //  widget.arrayOfPost[mainIndex].posttype == AppConstants.postTypeText ?
                  Container(
                // padding: EdgeInsets.only(top:15,left: 15,right: 15,bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(0),
                  // boxShadow: [
                  // BoxShadow(
                  //   color: AppColors.moreLightGrey,
                  //   spreadRadius: .5,
                  //   blurRadius: 10
                  // )
                  // ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (widget.arrayOfPost[mainIndex].userid ==
                            dashBoardController.loginUserId) {
                          Get.to(() => ProfileScreen());
                        } else {
                          final result = await Get.to(
                              () => OtherUserProfileScreen(
                                    otherUserId:
                                        widget.arrayOfPost[mainIndex].userid! ??
                                            0,
                                    isFromChatScreen: false,
                                  ),
                              arguments: {
                                "isGuestLogin":
                                    dashBoardController.isGuestLogin,
                              });
                          if (result != null) {
                            print('result --->>>  ${result}');
                            setState(() {
                              widget.arrayOfPost.removeWhere(
                                  (post) => post.userid == int.parse(result));
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: 15, right: 15, bottom: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: widget.arrayOfPost[mainIndex]
                                              .profileimage ==
                                          '' ||
                                      widget.arrayOfPost[mainIndex]
                                              .profileimage ==
                                          null
                                  ? CircleAvatar(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                            AppImages.profileplaceholder),
                                      ),
                                      backgroundColor:
                                          AppColors.placeHolderGray,
                                      radius: AppSizes.double24,
                                    )
                                  : CircleAvatar(
                                      radius: AppSizes.double24,
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          width: AppSizes.double55 * 2,
                                          height: AppSizes.double55 * 2,
                                          fit: BoxFit.cover,
                                          imageUrl: ApiPaths.profilePath +
                                                  widget.arrayOfPost[mainIndex]
                                                      .profileimage! ??
                                              '',
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            AppImages.profileplaceholder,
                                            scale: imageScale,
                                          ),
                                        ),
                                      )),
                            ),
                            SizedBox(
                              width: AppSizes.double5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: AppSizes.double5,
                                ),
                                Text(
                                  widget.arrayOfPost[mainIndex].fullname!,
                                  style: tbPostUserNameBlack(),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      widget.arrayOfPost[mainIndex].date!,
                                      style: widget.arrayOfPost[mainIndex]
                                                  .posttype ==
                                              AppConstants.postTypeText
                                          ? tbPostDateAndTime()
                                          : tbPostDateAndTimeForMedia(),
                                    ),
                                    SizedBox(
                                      width: AppSizes.double5,
                                    ),
                                    Text(
                                      widget.arrayOfPost[mainIndex].time!,
                                      style: widget.arrayOfPost[mainIndex]
                                                  .posttype ==
                                              AppConstants.postTypeText
                                          ? tbPostDateAndTime()
                                          : tbPostDateAndTimeForMedia(),
                                    )
                                  ],
                                )
                              ],
                            ),
                            // SizedBox(
                            //   width: Platform.isAndroid?AppSizes.double70: AppSizes.double80,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    widget.arrayOfPost[mainIndex].posttype !=
                            AppConstants.postTypeText
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 15.0, right: 8.0, bottom: 8.0),
                            child: Text(
                              widget.arrayOfPost[mainIndex].postdescription!
                                  .trim(),
                              style: tbPostDescription(),
                              textAlign: TextAlign.start,
                            ),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: AppSizes.double5,
                    ),
                    widget.arrayOfPost[mainIndex].posttype ==
                            AppConstants.postTypeText
                        ? Divider(
                            thickness: .5,
                          )
                        : SizedBox(),
                    widget.arrayOfPost[mainIndex].posttype ==
                            AppConstants.postTypeText
                        ? Padding(
                            padding: EdgeInsets.only(
                                top: 0, left: 15, right: 15, bottom: 0),
                            child: Center(
                              child: Text(
                                widget.arrayOfPost[mainIndex].postdescription!
                                    .trim(),
                                style: tbPostDescriptionBlack(),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          )
                        : widget.arrayOfPost[mainIndex].mediadata!.isNotEmpty
                            ? Container(
                                height: deviceSize.height * .40,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: pageControllers[mainIndex],
                                      // controller: pageControllerBlur,
                                      onPageChanged: (int page) {
                                        if (activePage.value != page) {
                                          // setState(() {
                                          activePage.value = page;
                                          print(
                                              'this is page number =======>>>>>>>${page + 1}');
                                          // });
                                        }
                                      },
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.arrayOfPost[mainIndex]
                                          .mediadata!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return widgetBackgroundblurImage(
                                            mediaData: widget
                                                .arrayOfPost[mainIndex]
                                                .mediadata![index]);
                                      },
                                    ),
                                    PageView.builder(
                                      controller: pageController,
                                      onPageChanged: (int page) {
                                        if (currentPostNumber.value != page) {
                                          print(
                                              'Only update if page has changed  ========>>>> ${page}'); //
                                          setState(() {
                                            imagePageCount[mainIndex] = page;
                                          });
                                          activePage.value = page;
                                          currentPostNumber.value =
                                              page; // Update only if page is different
                                          pageControllers[mainIndex].jumpToPage(
                                              page); // Sync the page controller for the blur effect
                                          // });
                                        }
                                      },
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.arrayOfPost[mainIndex]
                                          .mediadata!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return widgetmediadata(
                                            mediaData: widget
                                                .arrayOfPost[mainIndex]
                                                .mediadata![index]);
                                      },
                                    ),
                                    if (widget.arrayOfPost[mainIndex].mediadata!
                                            .length >
                                        1)
                                      widgetPageIndicator(postIndex: mainIndex),
                                  ],
                                ),
                              )
                            : widgetImagePlaceholder(width, height),
                    SizedBox(
                      height: AppSizes.double5,
                    ),
                    widget.arrayOfPost[mainIndex].posttype ==
                            AppConstants.postTypeText
                        ? Divider(
                            thickness: .5,
                          )
                        : SizedBox(),
                    // I HAVE COMMITE FOR SMALL DEVIES
                    // SizedBox(height: AppSizes.double5,),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 15,right: 15,),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Row(
                    //         crossAxisAlignment: CrossAxisAlignment.end,
                    //         children: [
                    //           Icon(Icons.favorite, color: Colors.black, size: 15.0,),
                    //           SizedBox(width: AppSizes.double5,),
                    //           Text('${widget.arrayOfPost[mainIndex].likedCount} likes',style: tbPostDateAndTime(),),
                    //         ],
                    //       ),
                    //       Row(
                    //         children: [
                    //            Text('${widget.arrayOfPost[mainIndex].totalComments} comments',style: tbPostDateAndTime(),),
                    //            SizedBox(width: AppSizes.double15,),
                    //         Text('2.7k share',style: tbPostDateAndTime(),)
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 2, left: 15, right: 15, bottom: 2),
                      child: SizedBox(
                        height: 50,
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: widget.isFromMyPostScreen ? 
                                () {
                                  if(dashBoardController.isGuestLogin){
                                    dashBoardController.guestLoginClicked(context);
                                  }else{
                                  setState(() {
                                    myPostController.arrayOfPost[mainIndex]
                                        .isliked = myPostController
                                                .arrayOfPost[mainIndex]
                                                .isliked ==
                                            0
                                        ? 1
                                        : 0;
                                    if (myPostController
                                            .arrayOfPost[mainIndex].isliked ==
                                        1) {
                                      widget.arrayOfPost[mainIndex].totalLikes =
                                          widget.arrayOfPost[mainIndex]
                                                  .totalLikes! +
                                              1;
                                    } else {
                                      if (widget.arrayOfPost[mainIndex]
                                              .totalLikes! !=
                                          0) {
                                        widget.arrayOfPost[mainIndex]
                                            .totalLikes = widget
                                                .arrayOfPost[mainIndex]
                                                .totalLikes! -
                                            1;
                                      }
                                    }
                                  }); 
                                  myPostController.postLikeDislikeApi(
                                      postId: widget.arrayOfPost[mainIndex].id!,
                                      index: mainIndex);}
                                }: widget.isFromSearchScreen ? () {
                                  if(dashBoardController.isGuestLogin){
                                    dashBoardController.guestLoginClicked(context);
                                  }else{
                                  setState(() {
                                    searchPostController.arrayOfPost[mainIndex]
                                        .isliked = searchPostController
                                                .arrayOfPost[mainIndex]
                                                .isliked ==
                                            0
                                        ? 1
                                        : 0;
                                    if (searchPostController
                                            .arrayOfPost[mainIndex].isliked ==
                                        1) {
                                      widget.arrayOfPost[mainIndex].totalLikes =
                                          widget.arrayOfPost[mainIndex]
                                                  .totalLikes! +
                                              1;
                                    } else {
                                      if (widget.arrayOfPost[mainIndex]
                                              .totalLikes! !=
                                          0) {
                                        widget.arrayOfPost[mainIndex]
                                            .totalLikes = widget
                                                .arrayOfPost[mainIndex]
                                                .totalLikes! -
                                            1;
                                      }
                                    }
                                  }); 
                                  searchPostController.postLikeDislikeApi(
                                      postId: widget.arrayOfPost[mainIndex].id!,
                                      index: mainIndex);}
                                }: () {
                                  if(dashBoardController.isGuestLogin){
                                    dashBoardController.guestLoginClicked(context);
                                  }else{
                                  setState(() {
                                    dashBoardController.arrayOfPost[mainIndex]
                                        .isliked = dashBoardController
                                                .arrayOfPost[mainIndex]
                                                .isliked ==
                                            0
                                        ? 1
                                        : 0;
                                    if (dashBoardController
                                            .arrayOfPost[mainIndex].isliked ==
                                        1) {
                                      widget.arrayOfPost[mainIndex].totalLikes =
                                          widget.arrayOfPost[mainIndex]
                                                  .totalLikes! +
                                              1;
                                    } else {
                                      if (widget.arrayOfPost[mainIndex]
                                              .totalLikes! !=
                                          0) {
                                        widget.arrayOfPost[mainIndex]
                                            .totalLikes = widget
                                                .arrayOfPost[mainIndex]
                                                .totalLikes! -
                                            1;
                                      }
                                    }
                                  }); 
                                  dashBoardController.postLikeDislikeApi(
                                      postId: widget.arrayOfPost[mainIndex].id!,
                                      index: mainIndex);}
                                },
                                child: Obx(
                                  () => widget.arrayOfPost[mainIndex].isliked ==
                                          1
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                AppImages.likefieldontext,
                                                scale: 3.0,
                                              ),
                                              SizedBox(
                                        width: AppSizes.double5,
                                      ),
                                              Text(
                                                formatCount(widget.arrayOfPost[mainIndex].totalLikes!),
                                                style: tbPostMoreOption(),),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                AppImages.likenormalonimage,
                                                scale: 3.0,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                        width: AppSizes.double5,
                                      ),
                                              Text(
                                                formatCount(widget.arrayOfPost[mainIndex].totalLikes!),
                                                style: tbPostMoreOption(),),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  dashBoardController.commentClicked(
                                      widget.arrayOfPost[mainIndex].id!,
                                      mainIndex,
                                      context,
                                      widget.arrayOfPost[mainIndex],
                                      () {
                                        setState(() {                                          
                                        });
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.comment,
                                        scale: 3.0,
                                        color: AppColors.black,
                                      ),
                                      SizedBox(
                                        width: AppSizes.double5,
                                      ),
                                      Text(
                                        formatCount(widget.arrayOfPost[mainIndex].totalComments!),
                                        style: tbPostMoreOption(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                 dashBoardController.isGuestLogin
                                            ? dashBoardController
                                                .guestLoginClicked(context):
                                                 dashBoardController.sharePostClicked(
                                      deviceSize: deviceSize,
                                      context: context,
                                      mediaPath: widget.arrayOfPost[mainIndex]
                                                  .posttype ==
                                              AppConstants.postTypeText
                                          ? ""
                                          : ApiPaths.postMediaPath +
                                              widget.arrayOfPost[mainIndex]
                                                  .mediadata![0]!.medianame!,
                                      hashtag: widget.arrayOfPost[mainIndex]
                                          .postdescription!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.share,
                                        scale: 3.0,
                                        color: AppColors.black,
                                      ),
                                      SizedBox(
                                        width: AppSizes.double5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            widget.arrayOfPost[mainIndex].userid ==
                                    dashBoardController.loginUserId
                                ? InkWell(
                                    onTap: () {
                                      dashBoardController.isGuestLogin
                                          ? dashBoardController
                                              .guestLoginClicked(context)
                                          : widget.isFromMyPostScreen
                                              ? myPostController.deletePostClicked(
                                                  context,
                                                  widget.arrayOfPost[mainIndex]
                                                      .id!
                                                      .toString(),
                                                  mainIndex)
                                              :  widget.isFromSearchScreen ?  
                                              searchPostController.deletePostClicked(
                                                  context,
                                                  widget.arrayOfPost[mainIndex]
                                                      .id!
                                                      .toString(),
                                                  mainIndex) : 
                                                  dashBoardController.deletePostClicked(
                                              context,
                                              widget.arrayOfPost[mainIndex].id!
                                                  .toString(),
                                              mainIndex);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.deletead,
                                            scale: 3.0,
                                            color: AppColors.black,
                                          ),
                                          SizedBox(
                                      width: AppSizes.double5,
                                    ),
                                        ],
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      dashBoardController.isGuestLogin
                                          ?  dashBoardController
                                              .guestLoginClicked(context)
                                          : reportClicked(
                                              context,
                                              widget.arrayOfPost[mainIndex].id!
                                                  .toString(),
                                              mainIndex);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.report,
                                            scale: 3.0,
                                            color: AppColors.black,
                                          ),
                                          SizedBox(
                                      width: AppSizes.double5,
                                    ),
                                        ],
                                      ),
                                    ),
                                  ),
                            //     widget.isFromMyPostScreen?
                            //      InkWell(
                            //           onTap: () {
                            //            dashBoardController.isGuestLogin ? dashBoardController.guestLoginClicked(context) : myPostController.deletePostClicked(context,widget.arrayOfPost[mainIndex].id!.toString(),mainIndex);
                            //           },
                            //           child: Row(
                            //           children: [
                            //             Image.asset(AppImages.deletead,scale: 3.0,color: AppColors.black, ),
                            //               SizedBox(width: AppSizes.double5,),
                            //             // Text(ConstantString.postDelete,style: tbPostMoreOption(),),
                            //           ],
                            //           ),
                            // ):
                            //   SizedBox(
                            //     child: Row(
                            //           children: [
                            //             Image.asset(AppImages.report,scale: 3.0,color:Colors.transparent, ),
                            //               SizedBox(width: AppSizes.double5,),
                            //             // Text(ConstantString.postReport,style: TextStyle(
                            //             //   color:Colors.transparent
                            //             // ),),
                            //           ],
                            //           ),
                            //   ):
                            //  InkWell(
                            //           onTap: () {
                            //            dashBoardController.isGuestLogin ? dashBoardController.guestLoginClicked(context) : reportClicked(context,widget.arrayOfPost[mainIndex].id!.toString(),mainIndex);
                            //           },
                            //           child: Row(
                            //           children: [
                            //             Image.asset(AppImages.report,scale: 3.0,color: AppColors.black, ),
                            //               SizedBox(width: AppSizes.double5,),
                            //             // Text(ConstantString.postReport,style: tbPostMoreOption(),),
                            //           ],
                            //           ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ////////  for media
              )),
        ),
        //   ),
        // ),
      );
    });
  }

  Widget widgetBackgroundblurImage({MediaDatum? mediaData}) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return mediaData?.isvideomedia == true
        ? (mediaData?.thumbnail != ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: height,
                      width: width,
                      imageUrl:
                          ApiPaths.postThumbnilePath + mediaData!.thumbnail!,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          widgetImagePlaceholder(width, height),
                    )),
              )
            : widgetImagePlaceholder(width, height))
        // : mediaData?.thumbnail != ''
        :
        // mediaData?.medianame == ''
        //     ? ImageFiltered(
        //         imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        //         child: CachedNetworkImage(
        //           fit: BoxFit.cover,
        //           height: height,
        //           width: width,
        //           imageUrl: ApiPaths.postMediaPath + mediaData!.thumbnail!,
        //           progressIndicatorBuilder: (context, url, downloadProgress) =>
        //               SizedBox(
        //             height: 30,
        //             width: 30,
        //             child: Center(
        //               child: CircularProgressIndicator(
        //                   value: downloadProgress.progress),
        //             ),
        //           ),
        //           errorWidget: (context, url, error) =>
        //               widgetImagePlaceholder(width, height),
        //         ),
        //       )
        //     :
        widgetImagePlaceholder(width, height);
  }

  Widget widgetImagePlaceholder(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        image: DecorationImage(
          image: const AssetImage(AppImages.postplaceholder),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
        ),
      ),
    );
  }

  Widget widgetmediadata({MediaDatum? mediaData}) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return mediaData?.isvideomedia == false
        ? (mediaData?.medianame != ''
            ? Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20)
                // ),
                height: height,
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: ApiPaths.postMediaPath + mediaData!.medianame!,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      height: 30,
                      width: 30,
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        widgetImagePlaceholder(width, height),
                  ),
                ),
              )
            : widgetImagePlaceholder(width, height))
        : mediaData?.medianame != ''
            ? VideoPlay(
                mediaData: mediaData,
                isFromPostScreen: true,
                thumbnail: ApiPaths.postThumbnilePath + mediaData!.thumbnail!,
                videoURL: ApiPaths.postMediaPath + mediaData!.medianame!)
            : widgetImagePlaceholder(width, height);
  }

  Widget widgetPageIndicator({required int postIndex}) {
    var currentPage = currentPostNumber;
    return Positioned(
      bottom: 5,
      left: 0,
      right: 0,
      height: 20,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5.0)),
          padding:
              EdgeInsets.only(top: 4.0, bottom: 4.0, left: 4.0, right: 4.0),
          child: Text(
            '${imagePageCount[postIndex] + 1} / ${widget.arrayOfPost[postIndex].mediadata!.length}',
            style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
                fontFamily: FontFamilyName.montserrat),
          ),
          // child: Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: List<Widget>.generate(
          //     widget.arrayOfPost[postIndex].mediadata!.length,
          //     (index) => Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 5),
          //       child: InkWell(
          //           onTap: () {
          //             pageController.animateToPage(index,
          //                 duration: const Duration(milliseconds: 300),
          //                 curve: Curves.easeIn);
          //           },
          //           child: Obx(
          //             () => CircleAvatar(
          //               radius: 5,
          //               backgroundColor: activePage == index
          //                   ? AppColors.blueThemeColor
          //                   : AppColors.white,
          //             ),
          //           )),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }

  void reportClicked(BuildContext context, String post_id, int postIndex) {
    var deviceSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('This is =========>>>>>>');
        print(dashBoardController.reportResaonList);
        return ReportReasonDialog(
          postId: post_id,
          postIdIndex: postIndex,
          reportReasonList: dashBoardController.reportResaonList,
          isFromSearchScreen: widget.isFromSearchScreen,
        );
      },
    );
  }
}
