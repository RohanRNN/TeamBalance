
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team_balance/app/controllers/business_detail_controller.dart';
import 'package:team_balance/app/controllers/my_business_controller.dart';
import 'package:team_balance/app/wights/comment_list_widget.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';


class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key, required this.businessModelId, required this.isFromDashBoardScreen, required this.businessDetails});
  final int businessModelId;
  final bool isFromDashBoardScreen;
  final BusinessModel businessDetails;

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final BusinessDetailController businessDetailController = Get.put(BusinessDetailController());

  void setBusinessValue() {
    setState(() {
          businessDetailController.businessDetails.value = widget.businessDetails;
     List<String?> categoryNames = businessDetailController.businessDetails.value.categorydetails!.map((category) => category!.categoryname).toList();
     businessDetailController.businessCategory.value = categoryNames.join(', ');  
    _addMarker();
    });
  }

  @override
  void initState() {
    setBusinessValue();
    //  businessDetailController.getBusinessDetailsApi().then((value) => _addMarker()); 
   super.initState();
  }
Set<Marker> _markers = {};
  Future<void> _addMarker() async {
    final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
     ImageConfiguration(devicePixelRatio: 2.5), 
      AppImages.locationMarkar,
    );
    final marker = Marker(
      markerId: MarkerId('uniqueMarkerId1'),
      position: LatLng(double.tryParse(businessDetailController.businessDetails.value.latitude!)!, double.tryParse(businessDetailController.businessDetails.value.longitude!)! ), // Coordinates for the marker
      infoWindow: InfoWindow(
        title: 'San Francisco',
        snippet: 'A cool place to visit',
      ),
      icon: markerIcon
      
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(marker);
    });
  }
CameraPosition getGoogleCameraPosition() {
    return CameraPosition(
      target: LatLng(
        double.parse(businessDetailController.businessDetails.value.latitude.toString()),
        double.parse(businessDetailController.businessDetails.value.longitude.toString()),
      ),
      zoom: 14,
    );
  }

  // @override
  // void dispose() {
  //   loginController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    const imageScale = 2.5;
    var deviceSize = MediaQuery.of(context).size; 
       return   Scaffold(
          extendBodyBehindAppBar: true,
           appBar: AppBar(
             systemOverlayStyle: SystemUiOverlayStyle.dark,  
            centerTitle: true,
       backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back(result: businessDetailController.businessDetails);
          },
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Text(ConstantString.businessDetails,style: tbScreenBodyTitle(),),
           ),
           body: Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:Obx(() => businessDetailController.isLoading.value?
        //  Center(child: AppLoader(),)
        tbCustomLoader(width: deviceSize.width*.5)
         :
           SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:15.0,right: 15),
                    child: Container(                      
                      decoration: BoxDecoration(
                          boxShadow: [                            
                             BoxShadow(
                               color: AppColors.lightGrey, // Shadow color
                               spreadRadius: .5, // How much the shadow should spread
                               blurRadius: 10, // How blurry the shadow should be
                               offset: Offset(0, 10), // Offset of the shadow
                             ),
                           ],
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(15)
                            ),               
                      child: Column(children: [
                        Stack(children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom:55.0),
                            child: Image.asset(AppImages.profilecardview,scale: imageScale,),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2), 
                                      spreadRadius: 2, 
                                      blurRadius: 10,
                                      offset: Offset(0, 2), 
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: AppColors.primaryColor,
                                  child:  
                                   businessDetailController.businessDetails.value.businesslogo != null ? InkWell(
                            onTap: () {
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                             builder: (context) => ImageFullScreenScreen(
                                               imageUrl:  ApiPaths.businessLogoMediaPath + businessDetailController.businessDetails.value.businesslogo!,
                                             ),
                                           ),
                                         );
                                       },
                             child: CircleAvatar(
                               radius: 53,
                             child: ClipOval(
                               child: CachedNetworkImage(
                                  width: 53 * 2,  
                                     height: 53 * 2,
                                 fit: BoxFit.cover,
                                 imageUrl:
                                  ApiPaths.businessLogoMediaPath + businessDetailController.businessDetails.value.businesslogo!,
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
                                    Image.asset(AppImages.profileplaceholder,scale: imageScale,
                               ),                              
                                ),
                             )
                             ),
                           ):
                           CircleAvatar(radius: 53,backgroundColor: AppColors.placeHolderGray,
                           child: Image.asset(AppImages.thumbnail,scale: imageScale,),) ,
                                ),
                              ),
                            ),

                        //  Align(
                        //       alignment: Alignment.bottomCenter,
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black.withOpacity(0.2), 
                        //               spreadRadius: 2, 
                        //               blurRadius: 10,
                        //               offset: Offset(0, 2), 
                        //             ),
                        //           ],
                        //         ),
                        //         child: CircleAvatar(
                        //           radius: AppSizes.double60,
                        //           backgroundColor: AppColors.primaryColor,
                        //         ),
                        //       ),
                        //     ),
                        //     businessDetailController.businessDetails.businesslogo == null?
                        //     Padding(
                        //       padding: const EdgeInsets.only(bottom:1.5),
                        //       child: Align(
                        //       alignment: Alignment.bottomCenter,
                        //       child: CircleAvatar(radius: AppSizes.double55,backgroundColor: AppColors.placeHolderGray,child:Image.asset(AppImages.thumbnail,scale: imageScale,) ,)),
                        //     ):Padding(
                        //       padding: const EdgeInsets.only(bottom:1.5),
                        //       child: Align(
                        //       alignment: Alignment.bottomCenter,
                        //       child: Stack(children: [
                        //         CircleAvatar(radius: AppSizes.double55,backgroundColor: AppColors.placeHolderGray,),
                        //         Padding(
                        //           padding: const EdgeInsets.all(1.0),
                        //           child: CircleAvatar(radius: AppSizes.double55,backgroundImage: NetworkImage(ApiPaths.businessLogoMediaPath + businessDetailController.businessDetails.businesslogo!)),
                        //         )
                        //       ],)),
                        //     ),
                        
                                                 
                        ],),
                        
                                     
                      Padding(
                        padding: const EdgeInsets.only(left:10.0,right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                           SizedBox(height: AppSizes.double20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                           Text(ConstantString.businessName,style: tbTextFieldStyle(),), 
                           SizedBox(width: 10,),
                          //  SizedBox(width: 30,),
                            SizedBox(
                              width: deviceSize.width*.7,
                              child: Text(businessDetailController.businessDetails.value.businessname!,textAlign: TextAlign.end,style: tbFormTextStyle(),)),
                          ],),
                          SizedBox(height: AppSizes.double20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                           Text(ConstantString.businessCategory,style: tbTextFieldStyle(),),
                           SizedBox(width: 50,),
                             Expanded(child: Text(businessDetailController.businessCategory.value,textAlign: TextAlign.end,style: tbFormTextStyle(),)),
                          ],),
                          SizedBox(height: AppSizes.double20,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(children: [
                                   Container(
                                    
                              height: deviceSize.height*.21,
                              decoration: BoxDecoration(                            
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.lightGrey,                              
                              ),
                              child:   ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: 
                                GoogleMap(
                                          initialCameraPosition: getGoogleCameraPosition(),
                                          // markers: Set<Marker>.of(_markers),
                                          markers: _markers,
                                          mapType: MapType.normal,
                                          myLocationEnabled: true,
                                          compassEnabled: true,
                                          onMapCreated: (GoogleMapController controller) {
                                            // _controller.complete(controller);
                                          },
                                          // onTap: (value) async {
                                          //   if (_markers.isNotEmpty) {
                                          //     _markers.clear();
                                          //   }
                                          //   Log.info(value);
                                          //   // await placemarkFromCoordinates(value.latitude, value.longitude)
                                          //   //     .then((List<Placemark> placemarks) {
                                          //   //   Placemark place = placemarks[0];
                                          //   //   setState(() {
                                          //   //     _currentAddress =
                                          //   //         '${place.name}, ${place.locality}, ${place.country}, ${place.postalCode}';
                                          //   //     searchTextfiled.text = _currentAddress ?? '';
                                          //   //   });
                                          //   // }).catchError((e) {
                                          //   //   Log.error("ERROR 2: $e");
                                          //   // });
                                          //   Log.info("Drag End: $value");
                                          //   // _onAddMarkerButtonPressed(value);
                                          // },
                                        ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              right: 15,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: AppSizes.double30,
                                 decoration: BoxDecoration(
                                    boxShadow: [
                                  BoxShadow(
                                    spreadRadius: .5,
                                    color: AppColors.mediumGrey,
                                    blurRadius:25,
                                    offset: Offset(0, 8)
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.primaryColor
                              ),
                                child: Center(child: Text(businessDetailController.businessDetails.value.location!,
                                 maxLines: 1, // Allow unlimited lines
                                  overflow: TextOverflow.ellipsis, ))),
                            )
                            ],),
                           
                          ),
                          SizedBox(height: AppSizes.double20,),
                          Text(ConstantString.businessLocText,style: TextStyle(
                                                                  fontFamily: FontFamilyName.montserrat,
                                                                 fontSize:12.5,
                                                                 color: AppColors.mediumGrey,
                                                                 fontWeight: FontWeight.w500,
                                                               )),
                      
                         SizedBox(                        
                          height: deviceSize.height*.19,
                           child: 
                           businessDetailController.businessDetails.value.businesspromotionpostcodes== null? Text(ConstantString.noAdsAdded,style: tbNoDataFoundTextStyle(),):
                           businessDetailController.businessDetails.value.businesspromotionpostcodes!.isEmpty? 
                                  Text(ConstantString.noAdsAdded,style: tbNoDataFoundTextStyle(),):
                           ListView.separated(
                                           itemCount: businessDetailController.businessDetails.value.businesspromotionpostcodes!.length,
                                           separatorBuilder: (BuildContext context, int index) {
                                             return Divider(
                                               endIndent: 25,
                                              indent:25,
                                               color: AppColors.lightGrey, // Color of the divider
                                               height: 1, // Thickness of the divider
                                             );
                                           },
                                           itemBuilder: (BuildContext context, int index) {
                                             return Padding(
                              padding: const EdgeInsets.only(top:10.0,bottom: 10),
                              child: InkWell(
                                onTap: () {
                            
                                },
                                child: Center(
                                  child: businessDetailController.businessDetails.value.businesspromotionpostcodes!.isEmpty? 
                                  Text(ConstantString.noAdsAdded,style: tbNoDataFoundTextStyle(),):
                                   ListTile(leading: Image.asset(AppImages.residentlisticon,scale: imageScale,),
                                  title: Wrap(
                                    spacing: 5,
                                    direction: Axis.vertical,
                                    children: [
                                    Text(businessDetailController.businessDetails.value.businesspromotionpostcodes![index]!.postcodedistrict!,style:  TextStyle(
                                                        fontSize:15,
                                                        color: AppColors.textBoldColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),),
                                  
                                  ],),
                                  trailing: Wrap(
                                    children: [
                                    businessDetailController.businessDetails.value.businesspromotionpostcodes![index]!.isactive!? Icon(Icons.check_circle_sharp,color: AppColors.lightGreen,size: 27,):Icon(Icons.check_circle_sharp,color: AppColors.lightGrey,size: 27,)
                                    ],
                                  ),),
                                ),
                              ),
                            );
                                           },
                                         ),
                         ),
                          ],),
                      )
                         
                                    ],),),
                  ),
                  SizedBox(
                    height: 15,
                  )
                  //  tbScreenButton(onTap: profileController.editProfileScreen,title: ConstantString.editProfile, height: deviceSize.height,width: deviceSize.width ),
                ],
              ),
            ),
          ),
        ),
           ),
           
            bottomNavigationBar:  widget.isFromDashBoardScreen ? null:Container(
              color: Colors.transparent,
        height: AppSizes.double100,
        child: Center(
          child: 
          Container(   
                    height: 55,
                    width: deviceSize.width*.68,
                    decoration: BoxDecoration(
                    gradient: AppColors.appGraadient,                  
                    borderRadius: BorderRadius.circular(18.0)
                    ),
                      child: InkWell(
                    onTap: () {            
                      businessDetailController.editBusiness(_addMarker);
                    },
                    child:  Center(
                    child: Text(
                      ConstantString.editDetails,
                      style: tbTextButton(),
                    ),
                    ),
                    ),
                    )
        // tbScreenButton(onTap: businessDetailController.editBusiness,title: ConstantString.editDetails, height: deviceSize.height,width: deviceSize.width )
        )),
           
         );
  }
  
//   static  CameraPosition _kGoogle = CameraPosition(
//   target: LatLng(
//     double.parse(businessDetailController.latitude.toString()), 
//     double.parse(businessDetailController.businessDetails.longitude.toString())
//   ),
//   zoom: 14,
// );
  //     static const CameraPosition _kGoogle = CameraPosition(
  //   target: LatLng(businessDetailController.businessDetails.latitude, businessDetailController.businessDetails.longitude),
  //   zoom: 14,
  // );
      // marker added for current users location
    // _markers.add(Marker(
    //   onTap: () {
    //     setState(() {});
    //   },
    //   markerId: const MarkerId("2"),
    //   position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    //   infoWindow: InfoWindow(
    //     title: _currentAddress,
    //   ),
    //   draggable: true,
    //   onDragEnd: (value) async {
    //     await placemarkFromCoordinates(value.latitude, value.longitude)
    //         .then((List<Placemark> placemarks) {
    //       Placemark place = placemarks[0];
    //       setState(() {
    //         _currentAddress =
    //             '${place.name}, ${place.locality}, ${place.country}, ${place.postalCode}';
    //         createMyBusinessController.latitude.value = value.latitude;
    //         createMyBusinessController.longitude.value = value.longitude;
    //         searchTextfiled.text = _currentAddress ?? '';
    //       });
    //     }).catchError((e) {
    //       Log.error("ERROR 2: $e");
    //     });
    //     Log.info("Drag End: $value");
    //     _onAddMarkerButtonPressed(value);
    //   },
    // ));
}
