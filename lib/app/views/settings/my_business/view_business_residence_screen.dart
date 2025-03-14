import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/create_my_business_controller.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class ViewBusinessResidenceScreen extends StatefulWidget {
  ViewBusinessResidenceScreen({
    super.key,
    required this.residenceModel,    
  });
final ResidenceModel residenceModel;

  @override
  State<ViewBusinessResidenceScreen> createState() => _ViewBusinessResidenceScreenState();
}

class _ViewBusinessResidenceScreenState extends State<ViewBusinessResidenceScreen> {
  final CreateMyBusinessController createMyBusinessController = Get.put(CreateMyBusinessController());

  @override
  void initState()  {   
   createMyBusinessController.getResidenceApi().then((value) => setState((){}));
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
        centerTitle: true,
       backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Text(ConstantString.viewResidence,style: tbScreenBodyTitle(),),
      ),

             body:   Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left:50.0,top:25,right: 50),
           
              child: createMyBusinessController.isLoading.value?Center(child: AppLoader(),):
              ListView(
                children: [
                   Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.postcodeDistrict,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.postcodedistirct!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                    Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.houseNumber,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.housenumber!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                    Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.streenName,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.streetname!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                    Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.area,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.area!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                    Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.city,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.city!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                    Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.country,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.country!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),

                   Padding(
                     padding: const EdgeInsets.only(bottom: 25),
                     child: Text(ConstantString.fullAddress,style: tbTextFieldStyle(),),
                   ),
                   Text(widget.residenceModel.fullAddress!,style: tbFormTextRecidenceStyle(),),
                   
                   Divider(thickness: .5,),
                   SizedBox(
                    height: AppSizes.double25,
                   ),
       
                ],
              ),
          ),
        ),
      ),
        //    bottomNavigationBar:  SizedBox(
        // height: AppSizes.double100,
        // child: Center(child:tbScreenButton(onTap: createMyBusinessController.editResidence,title: ConstantString.editResidence, height: deviceSize.height,width: deviceSize.width ))),
    );
  }
  
}
