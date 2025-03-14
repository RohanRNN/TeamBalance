import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/create_post_controller.dart';
import 'package:team_balance/app/views/settings/post/video_player_widget.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
 final CreatePostController createPostController = Get.put(CreatePostController());
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // loginController.rememberMe.value = false;
    super.initState();
  }
  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with submission
     createPostController.submitPostClicked();
      print('Form is valid, submitting...');
    } else {
      // Form is not valid, find the first error and scroll to it
      _scrollToFirstError();
    }
  }

    // Scroll to the First Error
  void _scrollToFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // Scrolls to the bottom where the error might be
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
  _scrollController.dispose();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
         backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Get.back(result: false);
              // Get.back();
            },
            child: Image.asset(AppImages.cancelpostback,scale: imageScale,)),
          title: Text(ConstantString.uploadPost,style: tbScreenBodyTitle(),),
               ),
             body:  GestureDetector(
                 onTap: () {
                    FocusScope.of(context).unfocus();
                   },
               child: SafeArea(
                 child: Padding(
                   padding: const EdgeInsets.only(left:20.0,right: 20),
                   child: SingleChildScrollView(
                     controller: _scrollController, 
                     child: GetBuilder<CreatePostController>(
                         id: GetBuilderIds.addPostMedia,
                       builder: (controller) => Form(
                          key: _formKey,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [              
                                  
                                     Text(ConstantString.photoandvideo,style: tbTextFieldStyle(),),  
                                     Padding(
                                     padding: const EdgeInsets.only(top:12),
                                     child: createPostController.postMediaArray.length !=0 ?
                                    Stack(children: [
                                     Container(
                                       decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(15.0),
                                   boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200, // Shadow color
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 1), // Shadow position
                                ),
                              ],
                                ),
                                       height: AppSizes.double275,
                                       width: AppSizes.double500, 
                                       child: ClipRRect(
                                         borderRadius: BorderRadius.circular(15),
                                         child: createPostController.isImage(createPostController.postMediaArray[0].media_name!)
                                             ? Image.file(createPostController.postMediaArray[0].media_name!, fit: BoxFit.cover)
                                             : createPostController.isVideo(createPostController.postMediaArray[0].media_name!)
                                                 ? VideoPlayerWidget(file: createPostController.postMediaArray[0].media_name!) // Custom widget to play videos
                                                 : Container(), // Placeholder or handle other types
                                       ),
                                     ),
                                     //  Container( 
                                     //   height: AppSizes.double275,
                                     // width: AppSizes.double400, 
                                     // child: ClipRRect(
                                     //    borderRadius: BorderRadius.circular(15),
                                     //   child: Image.file(createPostController.adsMedia!,fit: BoxFit.cover,)) ,),
                                       Positioned(top: 5,right: 5,
                                             child: InkWell(
                                               onTap: () {
                                                 createPostController.postMediaArray.removeAt(0);
                                                 setState(() {
                                                   
                                                 });
                                               },
                                               child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                    ],)
                                     :InkWell(
                                       onTap: () {
                                         createPostController.postMediaCallback(context, 2,false).then((value) => setState(() { }));
                                       },
                                       child: Container(
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(15),
                                               color: AppColors.placeHolderGray,),                    
                                         height: AppSizes.double275,
                                       width: AppSizes.double500,
                                       child:                                      
                                        createPostController.isMediaLoading.value? AppLoader(): Column(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Image.asset(AppImages.photovideo,scale: imageScale,),
                                         SizedBox(height: AppSizes.double15,),
                                         Text("Add ${ConstantString.photoandvideo}", style: tbPlaceHolderText(),)
                                       ],
                                     )
                                        ,),
                                     ),
                                   ),
                                    SizedBox(
                                     height: createPostController.postMediaArray.length != 0 && createPostController.postMediaArray[0].media_type == '1' ? null : AppSizes.double30,
                                   ), 
                                     createPostController.postMediaArray.length != 0 && createPostController.postMediaArray[0].media_type == '1' ? Text(''): Text(ConstantString.thumbnail,style: tbTextFieldStyle(),),  
                                     Padding(
                                    padding: const EdgeInsets.only(top:12),
                                     child: 
                                     createPostController.postMediaArray.length != 0 &&
                                     createPostController.postMediaArray[0].thumbnail!=null?
                                      Stack(children: [
                                      Container( 
                                         decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(15.0),
                                   boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200, // Shadow color
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 1), // Shadow position
                                ),
                              ],
                                ),
                                       height: AppSizes.double275,
                                     width: AppSizes.double500, 
                                     child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                       child: Image.file(createPostController.postMediaArray[0].thumbnail!,fit: BoxFit.cover,)) ,),
                                       Positioned(top: 5,right: 5,
                                             child: InkWell(
                                               onTap: () {
                                                 createPostController.postMediaCallback(context,4,true);
                                                 // createPostController.postMediaArray[0].thumbnail = null;
                                                 setState(() {                                        
                                                 });
                                               },
                                               child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                    ],):
                                    createPostController.postMediaArray.length != 0 && createPostController.postMediaArray[0].media_type == '1'?SizedBox():
                                    InkWell(
                                       onTap: () {
                                          createPostController.postMediaCallback(context, 1,true).then((value) => setState(() { }));
                                       },
                                       child: Container(
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(15),
                                               color: AppColors.placeHolderGray,),                    
                                         height: AppSizes.double275,
                                       width: AppSizes.double500,
                                       child: createPostController.isMediaLoading.value? AppLoader():
                                       Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Image.asset(AppImages.thumbnail,scale: imageScale,),
                                           SizedBox(height: AppSizes.double15,),
                                           Text(ConstantString.addThumbnail, style: tbPlaceHolderText(),)
                                         ],
                                       ),),
                                     ),
                                   ), 
                                    SizedBox(
                                     height: createPostController.postMediaArray.length != 0 && createPostController.postMediaArray[0].media_type == '1' ? null : AppSizes.double30,
                                   ), 
                                      Text(ConstantString.addMore,style: tbTextFieldStyle(),),  
                                     Padding(
                                       padding: const EdgeInsets.only(top:12),
                                       child: Wrap(
                                         direction: Axis.vertical,
                                        runSpacing: AppSizes.double10,
                                         spacing: AppSizes.double10,
                                         children: [
                                          for(int i = 1; i<createPostController.postMediaArray.length; i++)                                
                                              createPostController.postMediaArray.length != 0 ? 
                                              Wrap(
                                                 runSpacing: AppSizes.double10,
                                         spacing: AppSizes.double10,
                                               children: [
                                               Stack(
                                               children: [
                                                 Container(
                                             height: AppSizes.double100,
                                             width: AppSizes.double100,                                 
                                             child: ClipRRect(
                                               borderRadius: BorderRadius.circular(15),
                                               child: createPostController.isImage(createPostController.postMediaArray[i].media_name!)
                                             ? Image.file(createPostController.postMediaArray[i].media_name!, fit: BoxFit.cover)
                                             : createPostController.isVideo(createPostController.postMediaArray[i].media_name!)
                                                 ? VideoPlayerWidget(file: createPostController.postMediaArray[i].media_name!) // Custom widget to play videos
                                                 : Container()),
                                           ),
                                           Positioned(top: 5,right: 5,
                                             child: InkWell(
                                               onTap: () {
                                                 createPostController.postMediaArray.removeAt(i);
                                                 setState(() {
                                                   
                                                 });
                                               },
                                               child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                               ],
                                              ),
                                       
                                              createPostController.isVideo(createPostController.postMediaArray[i].media_name!)?
                                          createPostController.postMediaArray[i].thumbnail != null ?
                                   
                                              Stack(
                                               children: [
                                                 Container(
                                             height: AppSizes.double100,
                                             width: AppSizes.double100,                                 
                                             child: ClipRRect(
                                               borderRadius: BorderRadius.circular(15),
                                               child: createPostController.isImage(createPostController.postMediaArray[i].thumbnail!)
                                             ? Image.file(createPostController.postMediaArray[i].thumbnail!, fit: BoxFit.cover)
                                             : createPostController.isVideo(createPostController.postMediaArray[i].thumbnail!)
                                                 ? VideoPlayerWidget(file: createPostController.postMediaArray[i].thumbnail!) // Custom widget to play videos
                                                 : Container()),
                                           ),
                                           // Positioned(top: 5,right: 5,
                                           //   child: InkWell(
                                           //     onTap: () {
                                           //       // createPostController.postMediaArray.removeAt(i);
                                           //       // setState(() {
                                                   
                                           //       // });
                                           //     },
                                           //     child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                                               ],
                                              ):Container(
                                             height: AppSizes.double100,
                                             width: AppSizes.double100,
                                             decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(15),
                                               color: AppColors.placeHolderGray
                                             ),
                                             child: 
                                             Center(child:
                                             createPostController.isMediaLoading.value && createPostController.postMediaArray.length > 0
                                              ? AppLoader():                                              
                                             Image.asset(AppImages.photovideo,scale: imageScale,) ,),
                                           ):SizedBox(),
                                              ],)
                                              :SizedBox(),                       
                                             SizedBox(
                                               height: AppSizes.double10,
                                             ),
                                         createPostController.postMediaArray.length< CreatePostController.imageCount? InkWell(
                                           onTap: () {
                                             createPostController.postMediaCallback(context,3,false).then((value) => setState((){}));
                                           },
                                           child: Container(
                                             height: AppSizes.double100,
                                             width: AppSizes.double100,
                                             decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(15),
                                               color: AppColors.placeHolderGray
                                             ),
                                             child: Center(child:Image.asset(AppImages.photovideo,scale: 3.5,) ,),
                                           ),
                                         ):SizedBox()
                                         
                                       ],),
                                     ),
                                    SizedBox(
                                     height: AppSizes.double30,
                                   ),  
                                   Text(ConstantString.description,style: tbTextFieldStyle(),), 
                           // SizedBox(height: AppSizes.double10,),                 
                                 Padding(
                                   padding: const EdgeInsets.only(top:12),
                                   child: SizedBox(
                                     // height: deviceSize.height*.05,
                                     child: TextFormField( 
                                         style: tbFormValueTextStyle(),
                                     // cursorHeight: 10,
                                     keyboardType: TextInputType.multiline,
                                   maxLines: null,
                                     controller: createPostController.txtPostDescription,
                                     decoration: InputDecoration(                          
                                      enabledBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.grey.shade300), 
                                         ),
                                         focusedBorder: UnderlineInputBorder(
                                           borderSide: BorderSide(color: Colors.blue.shade300), 
                                         ),
                                          ),
                                           validator: (value) {
                                     if (value == null || value.isEmpty) {
                                       return 'Description is required';
                                     }
                                     return null;
                                   },
                                           ),
                                   )
                                 ),                                 
                                   
                                   
                                 
                                   
                                   ],),
                       ),
                     ),
                   ),
                 ),
               ),
             ),
           bottomNavigationBar: Obx(() => createPostController.isCreatePostLoading.value?
          //  Center(child: AppLoader(),)
           tbCustomLoader(width: deviceSize.width*0.5)
           :
            Container(
                color: Colors.transparent,
          height: AppSizes.double100,
          child: Center(child: tbScreenButton(onTap: _validateAndSubmit,title: ConstantString.submit, height: deviceSize.height,width: deviceSize.width )))),
             ),
       );
  }
}
