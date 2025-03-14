import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/create_ads_controller.dart';
import 'package:team_balance/app/controllers/create_post_controller.dart';
import 'package:team_balance/app/views/settings/post/video_player_widget.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/getbuilder_id_constant.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CreateAdsScreen extends StatefulWidget {
  final VoidCallback onAdCreated;
  
  const CreateAdsScreen({super.key, required this.onAdCreated});

  @override
  State<CreateAdsScreen> createState() => _CreateAdsScreenState();
}

class _CreateAdsScreenState extends State<CreateAdsScreen> {
  final CreateAdsController createAdsController = Get.put(CreateAdsController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
       if (Get.arguments != null) {
        print(Get.arguments);
      createAdsController.businessId = Get.arguments['businessId'];
      createAdsController.businesspromotionpostcodes = Get.arguments['businesspromotionpostcodes'];
         for (var promotionPostcode in createAdsController.businesspromotionpostcodes!) {
    createAdsController.postCodeList.add(
      PostcodeDistirctData(
        id: promotionPostcode!.id, // Assuming this maps to the id
        postcodedistrict: promotionPostcode.postcodedistrict,
        region: '', // Region is not available in BusinessPromotionPostcode, defaulting to empty or assign as needed
        cityId: 0, // No cityId in BusinessPromotionPostcode, assign default or leave as null
      ),
    );
  } 
    }
    super.initState();
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with submission
    createAdsController.submitPostClicked();
      print('Form is valid, submitting...');
    } else {
      createAdsController.submitPostClicked();
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

  // @override
  // void dispose() {
  //   loginController.dispose();s
  //   super.dispose();
  // }
 String? selectedPostcode;
  @override
  Widget build(BuildContext context) {
    const imageScale = 2.6;
    var deviceSize = MediaQuery.of(context).size; 
       return Scaffold(
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
          // child: Image.asset(AppImages.cancelpostback,scale: imageScale,)),
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Text(ConstantString.uploadAds,style: tbScreenBodyTitle(),),
      ),
           body:  Container(  
            height: deviceSize.height,
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left:20.0,right: 20),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: GetBuilder<CreateAdsController>(
                id: GetBuilderIds.addAdsMedia,
                builder: (controller) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(ConstantString.photoandvideo,style: tbTextFieldStyle(),),  
                              Padding(
                              padding: const EdgeInsets.only(top:12),
                              child: createAdsController.adsMedia != null ?
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
                                  child: 
                                  createAdsController.isImage(createAdsController.adsMedia!)
                                      ? Image.file(createAdsController.adsMedia!, fit: BoxFit.cover)
                                      :
                                       createAdsController.isVideo(createAdsController.adsMedia!)
                                          ? VideoPlayerWidget(file: createAdsController.adsMedia!) // Custom widget to play videos
                                          : Container(), // Placeholder or handle other types
                                ),
                              ),
                                Positioned(top: 5,right: 5,
                                      child: InkWell(
                                        onTap: () {                                       
                                          setState(() {
                                            print('this is cliecked ');
                                              createAdsController.adsMedia = null; 
                                              createAdsController.thumbnail = null;
                                          });
                                        },
                                        child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                             ],)
                              :InkWell(
                                onTap: () {
                                  createAdsController.adsMediaCallback(context, 2,false).then((value) => setState(() { }));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                        color: AppColors.placeHolderGray,),                    
                                  height: AppSizes.double275,
                                width: AppSizes.double500,
                                child:
                                createAdsController.isMediaLoading.value? AppLoader():
                                Column(
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
                              height:createAdsController.adsMedia != null &&
                              createAdsController.isImage(createAdsController.adsMedia!) ? null : AppSizes.double30,
                            ), createAdsController.adsMedia != null &&
                              createAdsController.isImage(createAdsController.adsMedia!) ? Text(''): Text(ConstantString.thumbnail,style: tbTextFieldStyle(),),  
                              Padding(
                             padding: const EdgeInsets.only(top:12),
                              child: 
                              createAdsController.thumbnail!=null?
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
                                child: Image.file(createAdsController.thumbnail!,fit: BoxFit.cover,)) ,),
                                Positioned(top: 5,right: 5,
                                      child: InkWell(
                                        onTap: () {
                                          createAdsController.adsMediaCallback(context,3,true);
                                          setState(() {                                        
                                          });
                                        },
                                        child: Image.asset(AppImages.removephoto, scale: imageScale,)))
                             ],):
                             createAdsController.adsMedia != null &&
                             createAdsController.isImage(createAdsController.adsMedia!)?SizedBox():
                             InkWell(
                                onTap: () {
                                   createAdsController.adsMediaCallback(context, 1,true).then((value) => setState(() { }));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                        color: AppColors.placeHolderGray,),                    
                                  height: AppSizes.double275,
                                width: AppSizes.double500,
                                child: 
                                createAdsController.isMediaLoading.value? AppLoader():
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(AppImages.thumbnail,scale: imageScale,),
                                    SizedBox(height: AppSizes.double15,),
                                    Text(ConstantString.addLogo, style: tbPlaceHolderText(),)
                                  ],
                                ),),
                              ),
                            ),                      
                           SizedBox(
                          height:createAdsController.adsMedia != null &&
                              createAdsController.isImage(createAdsController.adsMedia!) ? null : AppSizes.double30,
                          ),  
                          Padding(
                     padding: const EdgeInsets.only(bottom:10.0),
                     child: Text(ConstantString.postcodeDistrict,style: tbTextFieldStyle(),),
                   ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField(  
                             onTap: () {
                                _showDialog('postCode');
                              },
                                  validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Postcode is required';
                              }
                              return null;
                            },
                            style: tbFormTextRecidenceStyle(),
                          // cursorHeight: 10,
                          onChanged: ((values){
                            createAdsController.txtControllerPostDistrict.text = values;
                          }),  
                          readOnly:true, 
                          controller: createAdsController.txtControllerPostDistrict,
                          decoration: InputDecoration(  
                                                    
                             suffix: InkWell(
                              onTap: () {
                                _showDialog('postCode');
                              },
                              child: Image.asset(AppImages.downarrow, scale: imageScale)),                       
                           enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                              ),
                               ), ),
                        ), ],),
              ),
            ),
          ),
        ),
      ),
         bottomNavigationBar:  Obx(() => createAdsController.isCreateAdsLoading.value?
        //  Center(child: AppLoader(),)
        tbCustomLoader(width: deviceSize.width*0.5)
         :
          Container(
              color: Colors.transparent,
        height: AppSizes.double100,
        child: Center(child: tbScreenButton(onTap: _validateAndSubmit,title: ConstantString.submit, height: deviceSize.height,width: deviceSize.width )))),
    );
  }


    void _showDialog(String dialogBoxFor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {      
           return PostcodeDialog(
          selectedPostcode: selectedPostcode,
          onSelected: (value) {
            setState(() {
              selectedPostcode = value;
              createAdsController.txtControllerPostDistrict.text = value!;
              Navigator.pop(context);
            });
          },
          postcodes: createAdsController.postCodeList,
        );
        
       
      },
    );
  }

}
