import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:team_balance/app/views/video_player/videoplay.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/utils/models/business_ads_model.dart';

class FullScreenVideo extends StatefulWidget {
  final AdsMediaForHome mediaData;
  final bool isFromPostScreen;

  const FullScreenVideo({Key? key, required this.mediaData, required this.isFromPostScreen}) : super(key: key);

  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {


  @override
  void initState() {
    super.initState();
      
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: widgetmediadata(mediaData:widget.mediaData),
        ),
      ),
    );
  }
    Widget widgetmediadata({AdsMediaForHome? mediaData}) {
      Log.success("is post==> ${widget.isFromPostScreen}");
      Log.success("Media Data==> ${mediaData}");
      Log.success("Media Data==> ${mediaData?.medianame}");
      Log.success("Media Data==> ${mediaData?.thumbnail}");
      // Log.success("Media Data==> ${ApiPaths.businessAdsThumbnail +   mediaData!.thumbnail!}");
      // Log.success("Media Data==> ${ApiPaths.businessAdsMedia + mediaData!.medianame!}");

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return mediaData?.isvideomedia == false
        ? (mediaData?.medianame != ''
            ? Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                height: height,
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.isFromPostScreen ? ApiPaths.businessAdsMedia + mediaData!.medianame! : ApiPaths.businessAdsMedia + mediaData!.medianame!,
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
        : mediaData?.medianame != '' || mediaData?.thumbnail !=null
            ? VideoPlayForThumbnail(
              thumbnail:  widget.isFromPostScreen ? ApiPaths.postThumbnilePath +   mediaData!.thumbnail! :ApiPaths.businessAdsThumbnail +   mediaData!.thumbnail! ,
                videoURL:widget.isFromPostScreen ? ApiPaths.postMediaPath + mediaData!.medianame! : ApiPaths.businessAdsMedia + mediaData!.medianame!)
            : widgetImagePlaceholder(width, height);
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