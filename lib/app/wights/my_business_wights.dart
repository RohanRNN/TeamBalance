import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/my_business_controller.dart';
import 'package:team_balance/app/views/video_player/videoplay.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/models/business_ads_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CustomAdsWidget extends StatefulWidget {
  const CustomAdsWidget(
      {Key? key,
      required this.disableAds,
      required this.businessAdvertise,
      required this.index})
      : super(key: key);
  final bool disableAds;
  final int index;
  final BusinessAdvertise businessAdvertise;
  @override
  State<CustomAdsWidget> createState() => _CustomAdsWidgetState();
}

class _CustomAdsWidgetState extends State<CustomAdsWidget> {
  final MyBusinessController myBusinessController =
      Get.put(MyBusinessController());
  @override
  Widget build(BuildContext context) {
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    int _currentPage = 0;
    var deviceSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Container(
        // foregroundDecoration: BoxDecoration(
        //                             borderRadius: BorderRadius.circular(20),
        //                                 gradient: LinearGradient(
        //                                   colors: [AppColors.lightBlack, Colors.transparent, Colors.transparent, Colors.transparent],
        //                                   begin: Alignment.topCenter,
        //                                   end: Alignment.bottomCenter,
        //                                   stops: [0, 0.15, 0.8, 1],
        //                                 ),
        //                               ),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(20), // Optional: Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: Offset(2, 3), // Shadow position (x, y)
            ),
          ],
        ),

        height: AppSizes.double350,
        child: Stack(
          children: [
            widgetBackgroundblurImage(
                mediaData: widget.businessAdvertise.ads![0]),
            widgetmediadata(mediaData: widget.businessAdvertise.ads![0]),
            //  Container(
            //   height: deviceSize.height*.34,
            //              decoration: BoxDecoration(
            //   image: DecorationImage(image: AssetImage(AppImages.adshomeplaceholder,),fit: BoxFit.cover,
            // //   colorFilter: ColorFilter.mode(
            // //   Colors.grey.shade200.withOpacity(0.5),
            // //   BlendMode.darken
            // //  ),
            //  ) ,
            //    color: Colors.grey.withOpacity(0.5),
            //   borderRadius: BorderRadius.circular(20)

            //              ),
            //             ),
            //  Positioned(
            //   top: 120,
            //   left: 170,
            //   child: Image.asset(AppImages.play,scale: 3,color: AppColors.primaryColor,)),
            Positioned(
                left: 10,
                top: 10,
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          height: AppSizes.double40,
                          width: AppSizes.double40,
                          child: Image.asset(
                            AppImages.locationpin,
                            scale: 2.5,
                          )),
                      SizedBox(
                        width: AppSizes.double10,
                      ),
                      Text(
                        widget.businessAdvertise.advertisementpromotionarea!,
                        style: tbPostUserName(),
                      )
                    ],
                  ),
                )),
            widget.disableAds
                ? Container(
                    height: AppSizes.double350,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.6),
                        borderRadius: BorderRadius.circular(20)),
                  )
                : SizedBox(),

            Positioned(
                right: 10,
                top: 10,
                child: InkWell(
                  onTap: () {
                    myBusinessController.enableOrDisable(
                        context,
                        myBusinessController.disabledAds,
                        widget.businessAdvertise.businessadvertisementid!,
                        widget.index);
                  },
                  child: widget.disableAds
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          height: AppSizes.double35,
                          width: AppSizes.double75,
                          child: Center(
                            child: Text(
                              ConstantString.enable,
                              style: tbAdsStatusTextStyle(),
                            ),
                          ))
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          height: AppSizes.double35,
                          width: AppSizes.double75,
                          child: Center(
                            child: Text(
                              ConstantString.disable,
                              style: tbAdsStatusTextStyle(),
                            ),
                          )),
                )),

            Positioned(
                right: 10,
                bottom: 10,
                child: InkWell(
                  onTap: () {
                    myBusinessController.deleteAdsClicked(
                        context,
                        widget.businessAdvertise.businessadvertisementid!,
                        widget.index);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10)),
                      height: AppSizes.double40,
                      width: AppSizes.double40,
                      child: Image.asset(
                        AppImages.deletead,
                        scale: 2.5,
                      )),
                )),
          ],
        ),
      ),
    );
  }

  Widget widgetBackgroundblurImage({AdsMediaForHome? mediaData}) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return mediaData?.isvideomedia == true
        ? (mediaData?.thumbnail != ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: height,
                      width: width,
                      imageUrl:
                          ApiPaths.businessAdsThumbnail + mediaData!.thumbnail!,
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
        //           imageUrl: ApiPaths.businessAdsMedia + mediaData!.thumbnail!,
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
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: const AssetImage(AppImages.postplaceholder),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
        ),
      ),
    );
  }

  Widget widgetmediadata({AdsMediaForHome? mediaData}) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return mediaData?.isvideomedia == false
        ? (mediaData?.medianame != ''
            ? Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mediumBlack,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.20, 0.8, 1],
                  ),
                ),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20)
                // ),
                height: height,
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: ApiPaths.businessAdsMedia + mediaData!.medianame!,
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
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: VideoPlay(
                  isFromPostScreen: false,
                  thumbnail:
                      ApiPaths.businessAdsThumbnail + mediaData!.thumbnail!,
                  videoURL: ApiPaths.businessAdsMedia + mediaData!.medianame!,
                  mediaData: MediaDatum(
                      id: mediaData.id,
                      isvideomedia: mediaData.isvideomedia,
                      medianame: mediaData.medianame,
                      thumbnail: mediaData.thumbnail),
                ),
              )
            : widgetImagePlaceholder(width, height);
  }
}
