import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/create_post_controller.dart';
import 'package:team_balance/app/controllers/otp_verification_controller.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CreateTextPostScreen extends StatefulWidget {
  const CreateTextPostScreen({super.key});

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
 final CreatePostController createPostController = Get.put(CreatePostController());


  @override
  void initState() {
    // loginController.rememberMe.value = false;
    super.initState();
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
          // leadingWidth: deviceSize.width*.12,
          leading: InkWell(
            onTap: () {
               Get.back(result: false);
              // Get.back();
            },
            child: Image.asset(AppImages.cancelpostback,scale: imageScale,)),
          title: SizedBox(
            width: deviceSize.width*.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: AppSizes.double25,),
                Text(ConstantString.uploadTextPost,style: tbScreenBodyTitle(),),          
                SizedBox(),
                InkWell(
                  onTap: () {
                    createPostController.submitTextPostClicked();
                    // createPostController.postCreatePostApi(is_text: true);
                  },
                  child: Image.asset(AppImages.submittextpost,scale: imageScale,))
              ],
            ),
          ),
               ),
             body:  SafeArea(
               child: Padding(
                 padding: const EdgeInsets.only(left:20.0,right:20, bottom: 20.0),
                 child: Obx(() => createPostController.isCreatePostLoading.value?
                 // Center(child: AppLoader(),)
                 tbCustomLoader(width: deviceSize.width*0.5)
                 :
                  Container(
                   // height: 10,
                   // padding: EdgeInsets.all(30),
                   decoration: BoxDecoration(
                     color: AppColors.primaryColor,
                     borderRadius: BorderRadius.circular(15),
                     boxShadow: [                        
                              BoxShadow(
                                color: AppColors.lightGrey, // Shadow color
                                spreadRadius: 1, // How much the shadow should spread
                                blurRadius: 10, // How blurry the shadow should be
                                offset: Offset(0, 2), // Offset of the shadow
                              ),
                            ],
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(30.0),
                     child: TextField(                  
                       controller: createPostController.txtPostDescription,
                       textAlign: TextAlign.center,
                       cursorWidth: 3,
                       cursorColor: AppColors.blueThemeColor,
                       style: tbCreatePostText(),
                       maxLines: 25,
                       decoration: InputDecoration(
                           hintText: ConstantString.textPostText, // Add your creative hint here
                                hintStyle: TextStyle(
                                  color: Colors.grey, // Style for the hint text
                                  fontStyle: FontStyle.italic, // Optional: makes the hint text italic
                                ),
                         border: InputBorder.none
                       ),
                     ),
                   ),
                 ),),
                 
               ),
             )
             ),
       );
  }
}
