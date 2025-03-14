
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:team_balance/app/controllers/profile_controller.dart';
// import 'package:team_balance/constants/app_images.dart';
// import 'package:team_balance/constants/string_constants.dart';
// import 'package:team_balance/utils/themes/app_colors.dart';
// import 'package:team_balance/utils/themes/app_sizes.dart';
// import 'package:team_balance/utils/themes/app_theme.dart';

// class AdsDetialsScreen extends StatefulWidget {
//   const AdsDetialsScreen({super.key});

//   @override
//   State<AdsDetialsScreen> createState() => _AdsDetialsScreenState();
// }

// class _AdsDetialsScreenState extends State<AdsDetialsScreen> {
//   final ProfileController profileController = Get.put(ProfileController());

//   @override
//   void initState() {
//     // loginController.rememberMe.value = false;
//     super.initState();
//   }

//   // @override
//   // void dispose() {
//   //   loginController.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     const imageScale = 2.5;
//     var deviceSize = MediaQuery.of(context).size; 
//        return Scaffold(
//           extendBodyBehindAppBar: true,
//            appBar: AppBar(
//        backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: InkWell(
//           onTap: () {
//             Get.back();
//           },
//           child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
//         title: Text(ConstantString.profile,style: tbScreenBodyTitle(),),
//            ),
//            body:  Container(  
//             width: deviceSize.width,          
//          decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(AppImages.backGroundImg),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child:SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left:15.0,right: 15, top: 10),
//                 child: Container(                      
//                   decoration: BoxDecoration(
//                       boxShadow: [
                        
//                          BoxShadow(
//                            color: Colors.black.withOpacity(0.2), // Shadow color
//                            spreadRadius: 1, // How much the shadow should spread
//                            blurRadius: 10, // How blurry the shadow should be
//                            offset: Offset(0, 10), // Offset of the shadow
//                          ),
//                        ],
//                         color: AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(15)
//                         ),               
//                   child: Column(children: [
//                     Container(                      
//                       height: deviceSize.height*.24,
//                       child: Stack(children: [
//                         Image.asset(AppImages.profilecardview,scale: imageScale,),
//                        Align(
//                             alignment: Alignment.bottomCenter,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2), 
//                                     spreadRadius: 2, 
//                                     blurRadius: 10,
//                                     offset: Offset(0, 2), 
//                                   ),
//                                 ],
//                               ),
//                               child: CircleAvatar(
//                                 radius: AppSizes.double60,
//                                 backgroundColor: AppColors.primaryColor,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom:1.5),
//                             child: Align(
//                             alignment: Alignment.bottomCenter,
//                             child: CircleAvatar(radius: AppSizes.double55,backgroundColor: AppColors.placeHolderGray,)),
//                           ),
//                        Padding(
//                          padding: const EdgeInsets.all(30.0),
//                          child: Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Image.asset(AppImages.profileplaceholder,scale: imageScale,)),
//                        ),
                     
//                       ],),
//                     ),
                    
                 
//                   Container(                    
//                     height: deviceSize.height*.3,
//                     child:  
//                     Padding(
//                       padding: const EdgeInsets.only(left:20.0,right: 20),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
                         
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.fullNameText,style: tbTextFieldStyle(),), 
//                          SizedBox(width: 30,),
//                          SizedBox(width: 30,), Text('Dummy Text',textAlign: TextAlign.end,style: tbFormTextStyle(),),
//                         ],),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.gender,style: tbTextFieldStyle(),),
//                          SizedBox(width: 50,),
//                            Text('Dummy Text',textAlign: TextAlign.end,style: tbFormTextStyle(),),
//                         ],),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.phoneNumberText,style: tbTextFieldStyle(),),
//                          SizedBox(width: 50,),
//                            Text('Dummy Text',textAlign: TextAlign.end,style: tbFormTextStyle(),),
//                         ],),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.dateOfBirth,style: tbTextFieldStyle(),),
//                          SizedBox(width: 50,),
//                            Text('Dummy Text',textAlign: TextAlign.end,style: tbFormTextStyle(),),
//                         ],),
//                           Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.totalPost,style: tbTextFieldStyle(),),
//                          SizedBox(width: 50,),
//                            Text('Dummy Text',textAlign: TextAlign.end,style: tbFormTextStyle(),),
//                         ],),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                          Text(ConstantString.bio,style: tbTextFieldStyle(),), 
//                          SizedBox(width: 80,),
//                           Expanded(
//                             child: Text(
//                                                     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,",
//                                                     textAlign: TextAlign.end,
//                                                     style: tbFormTextStyle(),
//                                                     maxLines: 3, // Limit the text to 3 lines
//                                                     overflow: TextOverflow.ellipsis, // Add ellipsis (...) if the text exceeds 3 lines
//                                                   ),
//                           ),
//                         ],)
//                       ],),
//                     ),
                    
//                      )
                     
//                 ],),),
//               ),
//               //  tbScreenButton(onTap: profileController.editProfileScreen,title: ConstantString.editProfile, height: deviceSize.height,width: deviceSize.width ),
//             ],
//           ),
//         ),
//            ),
//             bottomNavigationBar:  Container(
//               color: Colors.transparent,
//         height: AppSizes.double100,
//         child: Center(child: tbScreenButton(onTap: profileController.editProfileScreen,title: ConstantString.editProfile, height: deviceSize.height,width: deviceSize.width ))),
           
//          );
//   }
// }
