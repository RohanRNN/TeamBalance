
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/create_my_business_controller.dart';
import 'package:team_balance/app/controllers/edit_my_business_controller.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class CategoryScreenForEdit extends StatefulWidget {
  const CategoryScreenForEdit({super.key, });

  @override
  State<CategoryScreenForEdit> createState() => _CategoryScreenForEditState();
}

class _CategoryScreenForEditState extends State<CategoryScreenForEdit> {
  
  final EditMyBusinessController editMyBusinessController = Get.put(EditMyBusinessController());

  @override
  void initState() {     
    super.initState();
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
        title: Text(ConstantString.businessCategory,style: tbScreenBodyTitle(),),
      ),
           body:  Obx(() => Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:SafeArea(
          child: 
          editMyBusinessController.isLoading.value? AppLoader(): ListView.separated(
              itemCount: editMyBusinessController.arrayOfCategory.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                //   endIndent: 25,
                //  indent:25,
                  color: AppColors.moreLightGrey, // Color of the divider
                  height: 1, // Thickness of the divider
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return  ListTile(
          onTap: () {    
                            setState(() {
                    if(editMyBusinessController.selectedCategories.contains( editMyBusinessController.arrayOfCategory[index].id!,)){
                    editMyBusinessController.selectedCategories.remove(editMyBusinessController.arrayOfCategory[index].id!,);
                    if(editMyBusinessController.addRemoveCategories.contains(editMyBusinessController.arrayOfCategory[index].id!,)){
                    editMyBusinessController.addRemoveCategories.remove(editMyBusinessController.arrayOfCategory[index].id!,);
                  }  else{
                    editMyBusinessController.addRemoveCategories.add(editMyBusinessController.arrayOfCategory[index].id!,);
                  }              

                  }else{
                     editMyBusinessController.selectedCategories.add(editMyBusinessController.arrayOfCategory[index].id!,);                     
                    editMyBusinessController.addRemoveCategories.add(editMyBusinessController.arrayOfCategory[index].id!,);                  
                  }
                    
                });
                
          },
          leading: Text(
          editMyBusinessController.arrayOfCategory[index].categoryname!,
          style: tbCategoryLable(),
          ),         
          trailing: editMyBusinessController.selectedCategories.contains(editMyBusinessController.arrayOfCategory[index].id!,)? Image.asset(
          AppImages.categorycheck,
          scale: imageScale,
          ):Image.asset(
          AppImages.categoryuncheck,
          scale: imageScale,
          ));
              },
            ),
        ),
      ),),
           bottomNavigationBar:  SizedBox(
        height: AppSizes.double100,
        child: Center(child: tbScreenButton(onTap: Get.back,title: ConstantString.continueTitle, height: deviceSize.height,width: deviceSize.width ))),
    );
  }
}
