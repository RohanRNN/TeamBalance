import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/ads_plan_controller.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/utils/models/plans_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class PremiumPlansWidget extends StatefulWidget {
  const PremiumPlansWidget({Key? key, required this.planModel, required this.index}) : super(key: key);
  final PlanModel planModel;
  final int index;

  @override
  State<PremiumPlansWidget> createState() => _PremiumPlansWidgetState();
}

class _PremiumPlansWidgetState extends State<PremiumPlansWidget> {
  final AdsPlanController adsPlanController = Get.put(AdsPlanController());
  @override
  Widget build(BuildContext context) {
        final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPage = 0;
  const imageScale = 2.5;
     var deviceSize = MediaQuery.of(context).size; 
  
         return Obx(() => Stack(
          children: [
             Container(
              padding: EdgeInsets.all(20),
                     height: deviceSize.height*.30,
                      child: Container(
                  padding: EdgeInsets.all(12),
                  height: deviceSize.height*.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.planContainerColors[widget.index]
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
              text: '${widget.planModel.localprice} /',
              style: TextStyle(
                fontFamily: FontFamilyName.montserrat,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color:  AppColors.planLineColors[widget.index],
              ),
              ),
              TextSpan(
              text: ' ${widget.planModel.planname}',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
              ),
            ],
          ),
        ),
                       Text(widget.planModel.plantitle!,style: tbAdsText())],),
                        Image.asset(adsPlanController.planLogo[widget.index],scale: imageScale,)
                      ],
                    ),
                    Divider(thickness: 0.2,color: AppColors.planLineColors[widget.index],),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(widget.planModel.features!.length, (mainIndex) =>Row(
                    children: [
                      Image.asset(AppImages.subscriptionarrow,scale: imageScale,),
                      SizedBox(
                        width: AppSizes.double10,
                      ),
                      Text(widget.planModel.features![mainIndex]!.feature!,style: tbAdsText(),)
                    ],
                  )) ,
                    ),
               
                    
                  ],),
                ),
                    ),
            // Positioned(
            //         top: 10,
            //         left: 30,
            //         child: Container(
            //           height: AppSizes.double28,
            //           width: AppSizes.double110,
            //           decoration: BoxDecoration(
            //             borderRadius:BorderRadius.circular(25) ,
            //             color: AppColors.planLineColors[widget.index]
            //           ),
            //           child: Center(child: Text('Current',style: tbPostUserName(),),),
            //         ),
            //       ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: adsPlanController.currentPlanSelecte == widget.index? Image.asset(AppImages.selectplan,scale: imageScale,):SizedBox(),
                  )
          ],
         ));
        
     
          
    
  }
}