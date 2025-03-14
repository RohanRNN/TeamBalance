
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/ads_plan_controller.dart';
import 'package:team_balance/app/controllers/otp_verification_controller.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class AdsPlanHistoryScreen extends StatefulWidget {
  const AdsPlanHistoryScreen({super.key});

  @override
  State<AdsPlanHistoryScreen> createState() => _AdsPlanHistoryScreenState();
}

class _AdsPlanHistoryScreenState extends State<AdsPlanHistoryScreen> {
  final AdsPlanController adsPlanController = Get.put(AdsPlanController());

  @override
  void initState() {
    //     adsPlanController.getAllPlansHistoryApi(
    //   fromRefresh: false,
    //   page: 1,
    //   pageSize: 10
    // );
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
       return Scaffold(
          extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
       backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Text(ConstantString.purchaseHistory,style: tbScreenBodyTitle(),),
      ),
           body:  Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:SafeArea(
          child: ListView(
            children: [
              ListTile(leading: CircleAvatar(
                radius: AppSizes.double20,
                backgroundColor: AppColors.fantedBlueColor,
                child: Image.asset(AppImages.purchasehistorylist,scale: imageScale,)),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('\$15.00 / Advance plan',style: tbPostUserNameBlack(),),
                   Text('02/10/2024 05:45 pm',style: tbPostDescriptionBlack(),)
                ],),)
            ],
          ),
        ),
      )
    );
  }
}
