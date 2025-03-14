
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team_balance/app/controllers/create_my_business_controller.dart';
import 'package:team_balance/app/views/settings/my_business/google_map/google_map_screen.dart';
import 'package:team_balance/app/views/settings/my_business/residence_screen.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CreateMyBusinessScreen extends StatefulWidget {
  const CreateMyBusinessScreen({super.key});

  @override
  State<CreateMyBusinessScreen> createState() => _CreateMyBusinessScreenState();
}

class _CreateMyBusinessScreenState extends State<CreateMyBusinessScreen> with WidgetsBindingObserver {
  final CreateMyBusinessController createMyBusinessController = Get.put(CreateMyBusinessController());

final Completer<GoogleMapController> _controller = Completer();
  // final List<Marker> _markers = <Marker>[];
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
//  createMyBusinessController.getCategoryApi();
 createMyBusinessController.getCurrentLocation(context);     
    ever(createMyBusinessController.latitude, (_) => _updateCameraPosition());
  ever(createMyBusinessController.longitude, (_) => _updateCameraPosition());
}
 late GoogleMapController controller;

void _updateCameraPosition() async {
   GoogleMapController controller = await _controller.future;
  controller.animateCamera(
    CameraUpdate.newLatLng(
      LatLng(
        createMyBusinessController.latitude.value,
        createMyBusinessController.longitude.value,
      ),
    ),
  );
}

    @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Call getCurrentLocation again when returning to the app
      createMyBusinessController.getCurrentLocation(context);
    }
  }
// Set<Marker> _markers = {};
//   void _addMarker() {
//     final marker = Marker(
//       markerId: MarkerId('uniqueMarkerId1'),
//       position: LatLng(double.tryParse(createMyBusinessController.latitude.value.toString()!)!, double.tryParse(createMyBusinessController.longitude.value.toString()!)! ), // Coordinates for the marker
//       infoWindow: InfoWindow(
//         title: 'San Francisco',
//         snippet: 'A cool place to visit',
//       ),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     );

//     setState(() {
//       _markers.add(marker);
//     });
//   }

CameraPosition getGoogleCameraPosition() {
    return CameraPosition(
      target: LatLng(
        double.parse(createMyBusinessController.latitude.value.toString()),
        double.parse(createMyBusinessController.longitude.value.toString()),
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
    print('createMyBusinessController.latitude.value.toString() ===   ${createMyBusinessController.latitude.value.toString()}');
    print('createMyBusinessController.longitude.value.toString() ===   ${createMyBusinessController.longitude.value.toString()}');
    const imageScale = 2.6;
    var deviceSize = MediaQuery.of(context).size; 
       return Container(
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
          title: Text(ConstantString.mybusiness,style: tbScreenBodyTitle(),),
               ),
             body:  Stack(
               children: [
                 Container(  
                  width: deviceSize.width,          
                            decoration: const BoxDecoration(
                             image: DecorationImage(
                  image: AssetImage(AppImages.backGroundImg),
                  fit: BoxFit.cover,
                             ),
                           ),
                           child:Obx(() => 
                             SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ConstantString.businessName,style: tbTextFieldStyle(),),                  
                                Padding(
                                  padding: const EdgeInsets.only(right:20.0),
                                  child: SizedBox(
                                    height: deviceSize.height*.05,
                                    child: TextFormField( 
                                      controller: createMyBusinessController.txtBusinessName,
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
                                Text(ConstantString.businessLogo,style: tbTextFieldStyle(),), 
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: createMyBusinessController.businessLogo== null? InkWell(
                                    onTap: () {
                                      createMyBusinessController.addLogoCallback(context).then((value) => setState(() { }));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                            color: AppColors.placeHolderGray,),                    
                                      height: AppSizes.double140,
                                    width: AppSizes.double140,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: AppSizes.double10,),
                                        Image.asset(AppImages.thumbnail,scale: imageScale,),
                                        SizedBox(height: AppSizes.double15,),
                                        Text(ConstantString.addLogo, style: tbPlaceHolderText(),)
                                      ],
                                    ),),
                                  ):Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                          color: AppColors.placeHolderGray,),                    
                                    height: AppSizes.double140,
                                  width: AppSizes.double140,
                                  child: Stack(children: [
                                   Container( 
                                     height: AppSizes.double140,
                                  width: AppSizes.double140,
                                  child: ClipRRect(
                                     borderRadius: BorderRadius.circular(15),
                                    child: Image.file(createMyBusinessController.businessLogo!,fit: BoxFit.cover,)) ,),
                                    Positioned(top: 5,right: 5,
                                          child: InkWell(
                                            onTap: () {
                                              createMyBusinessController.businessLogo = null;
                                              setState(() {
                                                
                                              });
                                            },
                                            child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                 ],)),
                                ),
                                SizedBox(
                                  height: AppSizes.double40,
                                ),
                                Text(ConstantString.businessLocation,style: tbTextFieldStyle(),),                  
                                Padding(
                                  padding: const EdgeInsets.only(right:20.0),
                                  child: SizedBox(
                                     height: createMyBusinessController.txtBusinessLocation.text != '' ? null : deviceSize.height*.05,
                                    child: TextFormField(
                                      onTapOutside: (event) {
                                         FocusScope.of(context).requestFocus(FocusNode()); 
                                      },
                                        minLines: 1,
                                        maxLines: 4,
                                        controller: createMyBusinessController.txtBusinessLocation,
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
                                //    Padding(
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
                                 
                                 InkWell(
                                  onTap: () async {
                  // Navigate to GoogleMapScreen and retrieve the selected location
                  final selectedLocation = await Get.to(() =>  GoogleMapScreen(
                    latitude: createMyBusinessController.latitude.value,
                    longitude: createMyBusinessController.longitude.value,
                  ), 
                      arguments: createMyBusinessController.txtBusinessLocation.text);
                             
                  if (selectedLocation != null) {
                    print('selectedLocation ======>>>>> ${selectedLocation}');
                     if(selectedLocation is String){
                                      setState(() {
                                        createMyBusinessController.txtBusinessLocation.text = selectedLocation;
                                      });
                                    }else{
                                      setState(() {
                                        if(selectedLocation['currentAddress'] != null){
                                      createMyBusinessController.txtBusinessLocation.text = selectedLocation['currentAddress'];
                                      createMyBusinessController.latitude.value = selectedLocation['latitude'];
                                      createMyBusinessController.longitude.value = selectedLocation['longitude'];
                                        }
                               
                                    });
                                   createMyBusinessController.addMarker();
                                    }
                 
                    // print('selectedLocation ====== >>>  ${selectedLocation}');
                    // // Set the returned location value to the text field
                    // createMyBusinessController.txtBusinessLocation.text = selectedLocation['currentAddress'];
                  } else {
                    print('Location not selected or canceled.');
                  }
                  setState(() {
                    
                  });
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
                      // width: AppSizes.double400,
                      // width: deviceSize,
                      decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20),
                             // Optionally add a background color or image if needed
                      ),
                      child: ClipRRect(
                             borderRadius: BorderRadius.circular(20),
                             child: Stack(
                  children: [
                    IgnorePointer(
                      ignoring: true, 
                      child: 
                      Obx(() {
                       if (createMyBusinessController.latitude.value != 0.0 &&
                           createMyBusinessController.longitude.value != 0.0) {
                         return GoogleMap(
                           
                             // key: ValueKey('${createMyBusinessController.latitude.value}-${createMyBusinessController.longitude.value}'), // Key that changes when location changes
                            markers: createMyBusinessController.markers.toSet(),
                            
                           initialCameraPosition: CameraPosition(
                             target: LatLng(
                  createMyBusinessController.latitude.value,
                  createMyBusinessController.longitude.value,
                             ),
                             zoom: 14,
                           ),
                           onMapCreated: (controller) {
                  _controller.complete(controller);
                 
                     //     controller.animateCamera(
                     //   CameraUpdate.newLatLng(
                     //     LatLng(
                     //       createMyBusinessController.latitude.value,
                     //       createMyBusinessController.longitude.value,
                     //     ),
                     //   ),
                     // );
                           },
                         );
                       } else {
                         // Display a loader while waiting for location
                         return createMyBusinessController.isLocationGranted.value  ? Container(
                           decoration: BoxDecoration(
                             color: Colors.grey.shade100,
                             borderRadius: BorderRadius.circular(15.0)
                           ),
                           height: AppSizes.double180,
                      // width: AppSizes.double400,
                           child: Center(child: Padding(
                             padding: const EdgeInsets.all(15.0),
                             child: Text('Allow location permission from the setting or pick a location manually.',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                  color: Colors.grey,
                  fontFamily: FontFamilyName.montserrat
                             ),),
                           ))) 
                           :  Container(
                           decoration: BoxDecoration(
                             color: Colors.grey.shade100,
                             borderRadius: BorderRadius.circular(15.0)
                           ),
                           height: AppSizes.double180,
                      width: AppSizes.double400,
                           child: Center(child: CircularProgressIndicator(
                             color: AppColors.blueThemeColor,
                           )));
                       }
                     }),
                      // Obx(() => GoogleMap(
                      //      initialCameraPosition: CameraPosition(
                      //         target: LatLng(
                      //           double.parse(createMyBusinessController.latitude.value.toString()),
                      //           double.parse(createMyBusinessController.longitude.value.toString()),
                      //         ),
                      //         zoom: 14,
                      //       ),
                      //     // initialCameraPosition: _kGoogle,
                      //     mapType: MapType.normal,
                      //     myLocationEnabled: true,
                      //     compassEnabled: true,
                      //     onMapCreated: (GoogleMapController controller) {
                      //       _controller.complete(controller);
                      //     },
                      //   ),
                      // ),
                    ),
                  ],
                             ),
                      ),
                    ),
                  ),
                             ),
                                  // InkWell(
                                  //   onTap: () async {
                                  //     if (createMyBusinessController
                                  //         .txtBusinessLocation.text.isNotEmpty) {
                                  //       createMyBusinessController.txtBusinessLocation.text =
                                  //           await Get.to(() => const GoogleMapScreen(),
                                  //               arguments: createMyBusinessController
                                  //                   .txtBusinessLocation.text);
                                  //     } else {
                                  //       createMyBusinessController.txtBusinessLocation.text =
                                  //           await Get.to(() => const GoogleMapScreen()) == null ?'':await Get.to(() => const GoogleMapScreen());
                                  //     }
                                  //   },
                                    
                                  //   child: Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Container(                  
                                  //     height: AppSizes.double180,
                                  //   width: AppSizes.double400,
                                  //   child: 
                                  //    ClipRRect(
                                  //     borderRadius: BorderRadius.circular(20),
                                  //     child: GoogleMap(
                                  //               initialCameraPosition: _kGoogle,
                                  //               markers: Set<Marker>.of(_markers),
                                  //               mapType: MapType.normal,
                                  //               myLocationEnabled: true,
                                  //               compassEnabled: true,
                                  //               onMapCreated: (GoogleMapController controller) {
                                  //                 _controller.complete(controller);
                                  //               },
                                  //               onTap: (value) async {
                                  //                 if (_markers.isNotEmpty) {
                                  //                   _markers.clear();
                                  //                 }
                                  //                 Log.info(value);
                                  //                 // await placemarkFromCoordinates(value.latitude, value.longitude)
                                  //                 //     .then((List<Placemark> placemarks) {
                                  //                 //   Placemark place = placemarks[0];
                                  //                 //   setState(() {
                                  //                 //     _currentAddress =
                                  //                 //         '${place.name}, ${place.locality}, ${place.country}, ${place.postalCode}';
                                  //                 //     searchTextfiled.text = _currentAddress ?? '';
                                  //                 //   });
                                  //                 // }).catchError((e) {
                                  //                 //   Log.error("ERROR 2: $e");
                                  //                 // });
                                  //                 Log.info("Drag End: $value");
                                  //                 // _onAddMarkerButtonPressed(value);
                                  //               },
                                  //             ),
                                  //   ),
                                  //   ),
                                  //                         ),
                                  // ),
                                 SizedBox(
                                  height: AppSizes.double40,
                                ),
                                InkWell(
                                  onTap: () {
                                    createMyBusinessController.getCategory();
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
                                Obx(() => Column(children: List.generate(createMyBusinessController.selectedCategories.length, (index)=>
                                SizedBox(
                                  height: AppSizes.double40,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(right:15,left: 1),
                                            onTap: () {    
                                        setState(() {
                                                      // if(createMyBusinessController.selectedCategories.contains(index)){  
                                                        createMyBusinessController.selectedCategories.remove(createMyBusinessController.selectedCategories[index]);                                         
                                                    // }
                                                  });
                                                  
                                            },
                                            leading: Text(
                                            createMyBusinessController.arrayOfCategory[createMyBusinessController.selectedCategories[index]].categoryname!,
                                            style: tbCategoryLable(),
                                            ),         
                                            trailing:  Image.asset(
                                            AppImages.removecategory,
                                            scale: imageScale,
                                            )),
                                ),),),),
                               
                                SizedBox(
                                  height: AppSizes.double20,
                                ),
                                Divider(thickness: 0.5,),                 
                             
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
                                        Get.to(() =>  ResidenceScreen())!.then((value) => setState((){}));
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
                               createMyBusinessController.selectedResidence!.isNotEmpty ? Wrap(children: [
                                 Text("At ${createMyBusinessController.residenceCount} location(s)",style: TextStyle(
                                                                     fontSize:12,
                                                                     color: AppColors.textBoldColor,
                                                                     fontWeight: FontWeight.w500,
                                                                   ),),
                             
                               Obx(() =>  Column(children: List.generate(createMyBusinessController.selectedResidence!.length, (index)=>
                                Padding(
                                  padding: const EdgeInsets.only(top:10.0,bottom: 15),
                                  child: InkWell(
                                    onTap: () {
                                      // createMyBusinessController.viewResidence(index);
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
                                            Text(createMyBusinessController.postCodeList!.firstWhere((residence) => residence!.id == createMyBusinessController.selectedResidence[index])!.postcodedistrict!,
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
                                                    if(createMyBusinessController.selectedResidence.contains(createMyBusinessController.selectedResidence[index])){
                                                        createMyBusinessController.selectedResidence.remove(createMyBusinessController.selectedResidence[index]);
                                                    }else{
                                                        createMyBusinessController.selectedResidence.add(createMyBusinessController.selectedResidence[index]);
                                                    }
                                                  });
                                                },
                                                child: createMyBusinessController.selectedResidence.contains(createMyBusinessController.selectedResidence[index])?Icon(Icons.check_circle_sharp,color: AppColors.lightGreen,size: 27,):Icon(Icons.check_circle_sharp,color: AppColors.lightGrey,size: 27,)),
                                              
                                              Padding(
                                                padding: const EdgeInsets.only(top:5.0),
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
                           ),
                   ),
                    Obx(() =>  createMyBusinessController.isLoadingForCreateBusiness.value
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
             )
               ,bottomNavigationBar: Container(                    
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                      gradient: AppColors.appGraadient,    
                      ),
                        child: InkWell(
                      onTap: () {            
                      createMyBusinessController.submit();
                      },
                      child:  Center(
                      child: Text(
                        ConstantString.submit,
                        style: tbTextButton(),
                      ),
                      ),
                      ),
                      )
             ),
       );
  }
  //   static const CameraPosition _kGoogle = CameraPosition(
  //      target: LatLng(20.007357, 73.792992),
  //   // target: LatLng(20.007357, 73.792992),
  //   zoom: 14,
  // );
  
//  void _showDialog(String dialogBoxFor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {      
//            return PostcodeDialog(
//           selectedPostcode: selectedPostcode,
//           onSelected: (value) {
//             setState(() {
//               selectedPostcode = value;
//               createMyBusinessController.txtControllerPostDistrict.text = value!;
//               Navigator.pop(context);
//             });
//           },
//           postcodes: createAdsController.postCodeList,
//         );
        
       
//       },
//     );
//   }

}
