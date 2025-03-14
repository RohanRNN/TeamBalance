
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/edit_my_business_controller.dart';
import 'package:team_balance/app/views/settings/my_business/google_map/google_map_screen.dart';
import 'package:team_balance/app/views/settings/my_business/residence_screen_for_edit.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/business_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class EditMyBusinessScreen extends StatefulWidget {
  const EditMyBusinessScreen({super.key, required this.businessModel});
  final BusinessModel businessModel;

  @override
  State<EditMyBusinessScreen> createState() => _EditMyBusinessScreenState();
}

class _EditMyBusinessScreenState extends State<EditMyBusinessScreen> {
final EditMyBusinessController editMyBusinessController = Get.put(EditMyBusinessController());
final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    editMyBusinessController.getCategoryApi();
    editMyBusinessController.addbusinessModelDetails(widget.businessModel);
    editMyBusinessController.arrayOfResidence!.value = GS.masterApiData.value!.postcodedistirctdata!;
    
    editMyBusinessController.latitude.value = double.tryParse(editMyBusinessController.businessModelData.value.latitude!)!;
    editMyBusinessController.longitude.value = double.tryParse(editMyBusinessController.businessModelData.value.longitude!)!; _addMarker();
    super.initState();
  ever(editMyBusinessController.latitude, (_) => _updateCameraPosition());
  ever(editMyBusinessController.longitude, (_) => _updateCameraPosition());
}
 late GoogleMapController controller;

void _updateCameraPosition() async {
   GoogleMapController controller = await _controller.future;
  controller.animateCamera(
    CameraUpdate.newLatLng(
      LatLng(
        editMyBusinessController.latitude.value,
        editMyBusinessController.longitude.value,
      ),
    ),
  );
}
  
Set<Marker> _markers = {};
  Future<void> _addMarker() async {
     final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.locationMarkar,
    );
    
    final marker = Marker(
      markerId: MarkerId('uniqueMarkerId1'),
      position: LatLng(editMyBusinessController.latitude.value, editMyBusinessController.longitude.value ), // Coordinates for the marker
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
        double.parse(editMyBusinessController.latitude.value.toString()),
        double.parse(editMyBusinessController.longitude.value.toString()),
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
    const imageScale = 3.0;
    var deviceSize = MediaQuery.of(context).size; 
       return Stack(
         children: [
           Container(
             decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.backGroundImg),
                fit: BoxFit.cover,
              ),
            ),
             child: Scaffold(
              backgroundColor: Colors.transparent,
                extendBodyBehindAppBar: true,
                   appBar: AppBar(
               systemOverlayStyle: SystemUiOverlayStyle.dark,  
              centerTitle: true,
             backgroundColor: Colors.transparent,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
              title: Text(ConstantString.editMybusiness,style: tbScreenBodyTitle(),),
                   ),
                 body:  SafeArea(
                   child: Padding(
                     padding: const EdgeInsets.all(15.0),
                     child: SingleChildScrollView(
                       child:  Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(ConstantString.businessName,style: tbTextFieldStyle(),),                  
                                 Padding(
                                   padding: const EdgeInsets.only(right:20.0),
                                   child: SizedBox(
                                     height: deviceSize.height*.05,
                                     child: TextFormField( 
                                      
                                       // initialValue: editMyBusinessController.txtBusinessName.text ?? '',
                                       controller: editMyBusinessController.txtBusinessName,
                                         style: tbTextFieldTitleStyle(),
                                     // cursorHeight: 10,
                                     decoration: InputDecoration(                          
                                      enabledBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.grey.shade300), // Light grey color for the underline
                                         ),
                                         focusedBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.blue.shade300), // Optionally, a lighter blue when the field is focused
                                         ),
                                          contentPadding: EdgeInsets.only(bottom: 00, top: 0),), ),
                                   )
                                 ),
                                 SizedBox(
                                   height: AppSizes.double40,
                                 ),
                                 Text(ConstantString.businessLogo,style: tbTextFieldStyle(),), 
                                 Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Stack(children: [
                                     Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(15),
                                           color: AppColors.placeHolderGray,),                    
                                     height: AppSizes.double140,
                                   width: AppSizes.double140,
                                   child: 
                                   editMyBusinessController.businessLogo == null?
                                    editMyBusinessController.businesslogo == '' ?
                                   InkWell(
                                     onTap: () {
                                        editMyBusinessController.addLogoCallback(context).then((value) => setState(() { }));
                                     },
                                     child: Column(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                     SizedBox(height: AppSizes.double10,),
                                     Image.asset(AppImages.thumbnail,scale: imageScale,),
                                     SizedBox(height: AppSizes.double15,),
                                     Text(ConstantString.addLogo, style: tbPlaceHolderText(),)
                                       ],
                                     ) ,
                                   ):ClipRRect(
                                    borderRadius:BorderRadius.circular(20),
                                    child: 
                                     CachedNetworkImage(
                                   width: AppSizes.double55 * 2,  
                                      height: AppSizes.double55 * 2,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                  ApiPaths.businessLogo +  editMyBusinessController.businesslogo! ?? '',
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
                                    // Image.network(ApiPaths.businessLogo +  editMyBusinessController.businesslogo!,fit: BoxFit.cover,)
                                    ):
                                   ClipRRect(
                                      borderRadius:BorderRadius.circular(20),
                                     child: Image.asset(editMyBusinessController.businessLogo!.path,fit: BoxFit.cover,)),),
                                     editMyBusinessController.businesslogo == '' && editMyBusinessController.businessLogo == null ? SizedBox(): Positioned(top: 5,right: 5,
                                               child: InkWell(
                                                 onTap: () {                                       
                                                   setState(() {
                                                     editMyBusinessController.businesslogo = '';
                                                     editMyBusinessController.businessLogo = null;
                                                   });
                                                 },
                                                 child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                   ],)
                                 ), 
                                 SizedBox(
                                   height: AppSizes.double40,
                                 ),
                                 Text(ConstantString.businessLocation,style: tbTextFieldStyle(),), 
                                 SizedBox(
                                   height: AppSizes.double10,
                                 ),                 
                                 Padding(
                                   padding: const EdgeInsets.only(right:20.0),
                                   child: SizedBox(
                                    //  height: deviceSize.height*.050,
                                     child: TextFormField( 
                                      readOnly: true,
                                       controller: editMyBusinessController.txtBusinessLocation,
                                        onTapOutside: (event) {
                                         FocusScope.of(context).requestFocus(FocusNode()); 
                                      },
                                        minLines: 1,
                                        maxLines: 4,
                                       // initialValue: editMyBusinessController.businessModelData.value.location ?? '',
                                         style: tbTextFieldTitleStyle(),
                                     // cursorHeight: 10,
                                     decoration: InputDecoration(                          
                                      enabledBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.grey.shade300), // Light grey color for the underline
                                         ),
                                         focusedBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.blue.shade300), // Optionally, a lighter blue when the field is focused
                                         ),
                                          contentPadding: EdgeInsets.only(bottom: 0, top: 0),), ),
                                   )
                                 ),
                                       SizedBox(
                                   height: AppSizes.double40,
                                 ),
                                 Text(ConstantString.setFromMap,style: tbTextFieldStyle(),),  
                                 //   Padding(
                                 //   padding: const EdgeInsets.all(8.0),
                                 //   child: Container(
                                 //     decoration: BoxDecoration(
                                 //       borderRadius: BorderRadius.circular(15),
                                 //           color: AppColors.placeHolderGray,),                    
                                 //     height: AppSizes.double180,
                                 //   width: AppSizes.double400,
                                 //   child: Column(
                                 //     mainAxisAlignment: MainAxisAlignment.center,
                                 //     children: [
                                 //       Image.asset(AppImages.thumbnail,scale: imageScale,),
                                 //       SizedBox(height: AppSizes.double15,),
                                 //       Text(ConstantString.addLogo, style: tbPlaceHolderText(),)
                                 //     ],
                                 //   ),),
                                 // ),
                                 Obx(() => 
                                   InkWell(
                                     onTap: () async {
                                     // Navigate to GoogleMapScreen and retrieve the selected location
                                     final selectedLocation = await Get.to(() =>  GoogleMapScreen(
                                          latitude: editMyBusinessController.latitude.value,
                                          longitude: editMyBusinessController.longitude.value,
                                     ), 
                                         arguments: editMyBusinessController.txtBusinessLocation.text == '' 
                                         ? editMyBusinessController.businessModelData.value.location
                                         :editMyBusinessController.txtBusinessLocation.text);
                                   
                                     if (selectedLocation != null) {
                                       // Set the returned location value to the text field
                                       _addMarker();
                                       if(selectedLocation is String){
                                         setState(() {
                                           editMyBusinessController.txtBusinessLocation.text = selectedLocation;
                                         });
                                       }else{
                                         setState(() {
                                           if(selectedLocation['currentAddress'] != null){
                                         editMyBusinessController.txtBusinessLocation.text = selectedLocation['currentAddress'];
                                         editMyBusinessController.latitude.value = selectedLocation['latitude'];
                                         editMyBusinessController.longitude.value = selectedLocation['longitude'];
                                         }
                                       });
                                       }
                                       
                                     } else {
                                       print('Location not selected or canceled.');
                                     }
                                   },
                                     // onTap: () async {
                                     //   if (editMyBusinessController.businessModelData.value.location == '') {
                                     //     // Navigate to GoogleMapScreen and retrieve the selected location
                                     //     editMyBusinessController.txtBusinessLocation.text =
                                     //         await Get.to(() => const GoogleMapScreen(),
                                     //             arguments: editMyBusinessController.businessModelData.value.location);
                                     //   } 
                                     //   else {
                                     //     print('This is location return value ======>>>>>>${await Get.to(() => const GoogleMapScreen())}');
                                     //     editMyBusinessController.txtBusinessLocation.text =
                                     //         await Get.to(() => const GoogleMapScreen()) ?? '';
                                     //   }
                                     // },
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Container(
                                         height: AppSizes.double180,
                                        //  width: AppSizes.double400,
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(20),
                                           // Optionally add a background color or image if needed
                                         ),
                                         child: ClipRRect(
                                           borderRadius: BorderRadius.circular(20),
                                           child: Stack(
                                             children: [
                                               // Google Map will display here but won't respond to taps
                                               IgnorePointer(
                                                 ignoring: true, // This will prevent the map from handling taps
                                                 child: GoogleMap(
                                                   markers: _markers,
                                                   initialCameraPosition: CameraPosition(
                                              target: LatLng(
                                                double.parse(editMyBusinessController.latitude.value.toString()),
                                                double.parse(editMyBusinessController.longitude.value.toString()),
                                              ),
                                              zoom: 14,
                                            ),
                                                  //  mapType: MapType.normal,
                                                  //  myLocationEnabled: true,
                                                  //  compassEnabled: true,
                                                   onMapCreated: (controller) {
                                                     _controller.complete(controller);
                                                       CameraUpdate.newLatLng(
                                                      LatLng(
                                                        editMyBusinessController.latitude.value,
                                                        editMyBusinessController.longitude.value,
                                                      ),
                                                    );
                                                  
                                                     
                                                   },
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),
                                 // InkWell(
                                 //     onTap: () async {
                                 //       if (editMyBusinessController
                                 //           .businessModelData.value.location == '') {
                                 //         editMyBusinessController.txtBusinessLocation.text =
                                 //             await Get.to(() => const GoogleMapScreen(),
                                 //                 arguments: editMyBusinessController
                                 //                     .businessModelData.value.location);
                                 //       } else {
                                 //         print('This is location retrn values ======>>>>>>${await Get.to(() => const GoogleMapScreen())}');
                                 //         editMyBusinessController.txtBusinessLocation.text =
                                 //             await Get.to(() => const GoogleMapScreen()) ?? '';
                                 //       }                                 
                                 //     },
                                     
                                 //     child: Padding(
                                 //     padding: const EdgeInsets.all(8.0),
                                 //     child: Container(                                                
                                 //       height: AppSizes.double180,
                                 //     width: AppSizes.double400,
                                 //     child: 
                                 //      ClipRRect(
                                 //       borderRadius: BorderRadius.circular(20),
                                 //       child: GoogleMap(
                                 //                 initialCameraPosition: _kGoogle,
                                 //                 // markers: Set<Marker>.of(_markers),
                                 //                 mapType: MapType.normal,
                                 //                 myLocationEnabled: true,
                                 //                 compassEnabled: true,
                                 //                 onMapCreated: (GoogleMapController controller) {
                                 //                   _controller.complete(controller);
                                 //                 },
                                 //                 // onTap: (value) async {
                                 //                 //   if (_markers.isNotEmpty) {
                                 //                 //     _markers.clear();
                                 //                 //   }
                                 //                 //   Log.info(value);
                                 //                 //   // await placemarkFromCoordinates(value.latitude, value.longitude)
                                 //                 //   //     .then((List<Placemark> placemarks) {
                                 //                 //   //   Placemark place = placemarks[0];
                                 //                 //   //   setState(() {
                                 //                 //   //     _currentAddress =
                                 //                 //   //         '${place.name}, ${place.locality}, ${place.country}, ${place.postalCode}';
                                 //                 //   //     searchTextfiled.text = _currentAddress ?? '';
                                 //                 //   //   });
                                 //                 //   // }).catchError((e) {
                                 //                 //   //   Log.error("ERROR 2: $e");
                                 //                 //   // });
                                 //                 //   Log.info("Drag End: $value");
                                 //                 //   // _onAddMarkerButtonPressed(value);
                                 //                 // },
                                 //               ),
                                 //     ),
                                 //     ),
                                 //                           ),
                                 //   ),
                                  SizedBox(
                                   height: AppSizes.double40,
                                 ),
                                   InkWell(
                                   onTap: () {
                                     editMyBusinessController.getCategory();
                                   },
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Text(ConstantString.businessCategory,style: tbTextFieldStyle(),),
                                       Padding(
                                         padding: const EdgeInsets.only(right:15.0),
                                         child: Image.asset(AppImages.nextarrow,scale: imageScale,color: AppColors.lightGrey1,),
                                       ),
                                     ],
                                   ),
                                 ),
                                 Obx(() => editMyBusinessController.isLoadingForCategory.value? 
                                 SizedBox(): 
                                 Column(
                                   children: List.generate(editMyBusinessController.selectedCategories.length, (index)=>
                                 SizedBox(
                                   height: AppSizes.double40,
                                   child: ListTile(
                                     contentPadding: EdgeInsets.only(right:15,left: 1),
                                             onTap: () {    
                                         setState(() {
                                           print('t hisi s i iidd====>${editMyBusinessController.selectedCategories[index]}');
                                                     //   if(editMyBusinessController.selectedCategories.contains(editMyBusinessController.selectedCategories[index])){  
                                                        editMyBusinessController.addRemoveCategories.add(editMyBusinessController.selectedCategories[index]);      
                                                         editMyBusinessController.selectedCategories.remove(editMyBusinessController.selectedCategories[index]);   
                                                                                          
                                                     // }
                                                   });
                                                   
                                             },
                                             leading: Text(
                                               editMyBusinessController.arrayOfCategory.firstWhere((category) => category.id == editMyBusinessController.selectedCategories[index]).categoryname!,
                                             // editMyBusinessController.arrayOfCategory[editMyBusinessController.selectedCategories[index]].categoryname!,
                                             style: tbCategoryLable(),
                                             ),         
                                             trailing:  Image.asset(
                                             AppImages.removecategory,
                                             scale: imageScale,
                                             )),
                                 ),),),),                  
                                 Padding(
                                   padding: const EdgeInsets.only(right:20.0),
                                   child: SizedBox(
                                     height: deviceSize.height*.030,
                                     child: TextFormField(  
                                       readOnly: true,
                                        style: tbTextFieldTitleStyle(),
                                     // cursorHeight: 10,
                                     decoration: InputDecoration(                          
                                      enabledBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.grey.shade300), // Light grey color for the underline
                                         ),
                                         focusedBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.blue.shade300), // Optionally, a lighter blue when the field is focused
                                         ),
                                          contentPadding: EdgeInsets.only(bottom: 0, top: 0),), ),
                                   )
                                 ),
                                  SizedBox(
                                   height: AppSizes.double40,
                                 ),
                                 Text(ConstantString.businessLocText,style: TextStyle(
                                                                      fontSize:12,
                                                                      color: AppColors.textBoldColor,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),),
                                                                                     
                                Padding(
                                   padding: const EdgeInsets.only(top:15.0,bottom: 15),
                                   child: InkWell(
                                     onTap: () {
                                         Get.to(() =>  ResidenceScreenForEdit())!.then((value) => setState((){}));
                                     },
                                     child: Container(
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(15),
                                               color: AppColors.placeHolderGray,),                    
                                         height: AppSizes.double80,
                                       // width: AppSizes.double,
                                       child: Center(
                                         child: ListTile(leading: Image.asset(AppImages.addresidenticon,scale: imageScale,),
                                         title: Text(ConstantString.businessLoc,style: tbSettingsLable(),),
                                         trailing: Image.asset(AppImages.nextarrow,scale: imageScale,),),
                                       ),),
                                   ),
                                 ),
                                 Padding(
                                   padding: const EdgeInsets.only(bottom:10.0),
                                   child: Divider(thickness: 1,),
                                 ),   
                                  SizedBox(
                                   height: AppSizes.double25,
                                 ),                     
                                editMyBusinessController.selectedResidence!.isNotEmpty ? Wrap(children: [
                                  Text("At ${editMyBusinessController.residenceCount} location(s)",style: TextStyle(
                                                                      fontSize:12,
                                                                      color: AppColors.textBoldColor,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),),
                                  SizedBox(
                                   height: AppSizes.double20,
                                 ), 
                 
                                Obx(() =>  Column(children: List.generate(editMyBusinessController.selectedResidenceModel!.length, (index)=>
                                 Padding(
                                   padding: const EdgeInsets.only(top:10.0,bottom: 15),
                                   child: InkWell(
                                     onTap: () {
                                       // editMyBusinessController.viewResidence(index);
                                     },
                                     child: Padding(
                                       padding: const EdgeInsets.only(left:8.0,right:8.0),
                                       child: Container(
                                           decoration: BoxDecoration(
                                             boxShadow: [                        
                                                 BoxShadow(
                                                   color: AppColors.lightGrey, 
                                                   spreadRadius: 1, 
                                                   blurRadius: 15, 
                                                   offset: Offset(0, 2), 
                                                 ),
                                               ],
                                             borderRadius: BorderRadius.circular(15),
                                                 color: AppColors.primaryColor,),                    
                                           height: AppSizes.double80,
                                         child: Center(
                                           child: ListTile(leading: Image.asset(AppImages.residentlisticon,scale: imageScale,),
                                           title: Wrap(
                                             direction: Axis.vertical,
                                             children: [
                                             Text(
                                               editMyBusinessController.selectedResidenceModel[index]!.postcodedistrict!,
                                               style:  TextStyle(
                                                                 fontSize:14,
                                                                 color: AppColors.textBoldColor,
                                                                 fontWeight: FontWeight.w600,
                                                               ),),
                                           
                                           ],),
                                           trailing: Wrap(
                                             spacing: AppSizes.double10,
                                             children: [
                                               InkWell(
                                                 onTap: () {
                                                   setState(() {
                                                     editMyBusinessController.selectedResidenceModel[index]!.isactive = !editMyBusinessController.selectedResidenceModel[index]!.isactive!;
                                                     if(editMyBusinessController.enableDisableResidence.contains(editMyBusinessController.selectedResidenceModel[index]!.id)){
                                                         editMyBusinessController.enableDisableResidence.removeWhere((element) => element == editMyBusinessController.selectedResidenceModel[index]!.id!);
                                                          editMyBusinessController.selectedResidence.removeWhere((element) => element == editMyBusinessController.selectedResidenceModel[index]!.postcodedistrictid!);
                                                     }else{
                                                         editMyBusinessController.enableDisableResidence.add(editMyBusinessController.selectedResidenceModel[index]!.id);
                                                     }
                 
                                                       if(editMyBusinessController.selectedResidence.contains(editMyBusinessController.selectedResidenceModel[index]!.postcodedistrictid)){                                               
                                                          editMyBusinessController.selectedResidence.removeWhere((element) => element == editMyBusinessController.selectedResidenceModel[index]!.postcodedistrictid!);
                                                     }else{
                                                         editMyBusinessController.selectedResidence.add(editMyBusinessController.selectedResidenceModel[index]!.postcodedistrictid);
                                                     }
                 
                                                   });
                                                 },
                                                 child: editMyBusinessController.businessModelData.value.businesspromotionpostcodes![index]!.isactive!? Icon(Icons.check_circle_sharp,color: AppColors.lightGreen,size: 27,):Icon(Icons.check_circle_sharp,color: AppColors.lightGrey,size: 27,)),
                                               
                                               Padding(
                                                 padding: const EdgeInsets.only(top:7.0),
                                                 child: Image.asset(AppImages.nextarrow,scale: imageScale,),
                                               ),
                                             ],
                                           ),),
                                         ),),
                                     ),
                                   ),
                                 ),
                                 ),),),
                                                                                     
                                 
                                ],):SizedBox(),
                                 
                                
                                 
                                 ],),
                     ),
                   ),
                 ),
                 bottomNavigationBar:  Obx(() => editMyBusinessController.isLoadingForEditBusiness.value?Container(child: AppLoader(),): Container(
                    color: Colors.transparent,
              height: AppSizes.double100,
              child: Center(child: tbScreenButton(onTap: editMyBusinessController.saveMyBusiness,title: ConstantString.save, height: deviceSize.height,width: deviceSize.width ))))
                 ),
           ),
           Obx(() =>  editMyBusinessController.isLoadingForEditBusiness.value
                                      ? 
                                    tbCustomLoader(height: deviceSize.height, width: deviceSize.width*.5)
                                      // Center(
                                      //     child: SizedBox(
                                      //       height: 50,
                                      //       width: 50,
                                      //       child: CircularProgressIndicator(), // You can replace this with any animation
                                      //     ),
                                      //   )
                                      : SizedBox()) 
         ],
       );
  }
  //    static const CameraPosition _kGoogle = CameraPosition(
  //   target: LatLng(20.007357, 73.792992),
  //   zoom: 14,
  // );
  //     static const CameraPosition _kGoogle = CameraPosition(
  //   target: LatLng(20.007357, 73.792992),
  //   zoom: 14,
  // );
}
