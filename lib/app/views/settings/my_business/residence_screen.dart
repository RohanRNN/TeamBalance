
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/controllers/create_my_business_controller.dart';
import 'package:team_balance/app/controllers/edit_my_business_controller.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class ResidenceScreen extends StatefulWidget {
  const ResidenceScreen({super.key});

  @override
  State<ResidenceScreen> createState() => _ResidenceScreenState();
}

class _ResidenceScreenState extends State<ResidenceScreen> {
  final CreateMyBusinessController createMyBusinessController = Get.put(CreateMyBusinessController());
var arrayOfResidence = <PostcodeDistirctData?>[]?.obs; 
var cityDataList = <CityData?>[];
  
  @override
  void initState() {   
    if(mounted){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        createMyBusinessController.arrayOfResidence!.value =  GS.masterApiData.value!.postcodedistirctdata!; 
    arrayOfResidence!.value = GS.masterApiData.value!.postcodedistirctdata!; 
    cityDataList = GS.masterApiData.value!.citydata!; 
      });
    }
    
    super.initState();
  }

 String? selectedPostcode;
 String? selectedCity;
 String? selectedCountry;

  void _showDialog(String dialogBoxFor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if(dialogBoxFor == "city"){
          return CityDialog(
          selectedPostcode: selectedCity,          
          onSelected: (value) {
            int selectedCityId = int.parse(value!['id']!);
            setState(() {
              arrayOfResidence!.value = GS.masterApiData.value!.postcodedistirctdata!; 
              print('value for selectedCity ======= >>>   ${value}');
              selectedCity = value!['city'];
              createMyBusinessController.txtControllerCity.text = value!['city']!; 
              createMyBusinessController.arrayOfResidence!.value = arrayOfResidence!.where((residence) {
        return residence!.cityId == selectedCityId;  // Filter by city_id
      }).toList();            
              Navigator.pop(context);

            });
          },
          city: createMyBusinessController.cityDataList, 
        );
        }else if (dialogBoxFor == "country"){
          return CountryDialog(
          selectedCountry: selectedCountry,
          onSelected: (value) {
               int selectedCountryId = int.parse(value!['id']!);
            setState(() {
              cityDataList = GS.masterApiData.value!.citydata!; 
              selectedPostcode = value!['country'];
              createMyBusinessController.txtControllerCountry.text = value!['country']!;
              cityDataList = cityDataList!.where((residence) {
        return residence!.countryId == selectedCountryId;  // Filter by city_id
      }).toList();   
              Navigator.pop(context);
            });
          },
          country: createMyBusinessController.countryDataList,
        );
        }else{
           return PostcodeDialog(
          selectedPostcode: selectedPostcode,
          onSelected: (value) {
            setState(() {
              selectedPostcode = value;
              // editMyBusinessController.txtControllerPostDistrict.text = value!;
              Navigator.pop(context);
            });
          },
          postcodes: createMyBusinessController.postCodeList,
        );
        }
       
      },
    );
  }
 

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
        title: Text(ConstantString.businessLocationList,style: tbScreenBodyTitle(),),
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
              Padding(
                                 padding: const EdgeInsets.all(15.0),
                               child: Text(ConstantString.country,style: tbTextFieldStyle(),),
                             ),                  
                            Padding(
                                padding: const EdgeInsets.only(left:15.0, right: 15.0),
                              child: SizedBox(
                                height: deviceSize.height*.05,
                                child: TextFormField( 
                                  onTap: () {
                                   _showDialog('country');
                                },
                                    style: tbFormTextProfileStyle(),
                                // cursorHeight: 10,
                                 onChanged: ((values){
                                  createMyBusinessController.txtControllerCountry.text = values;
                                }), 
                                readOnly:true, 
                                controller: createMyBusinessController.txtControllerCountry,
                                decoration: InputDecoration( 
                                  suffix: InkWell(
                                    onTap: () {
                                      _showDialog('country');
                                    },
                                    child: Image.asset(AppImages.downarrow, scale: imageScale)),                        
                                 enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                                    ),
                                     ), ),
                              ),
                            ),
                            SizedBox(
                              height: AppSizes.double40,
                            ),
                        Padding(
                               padding: const EdgeInsets.all(15.0),
                               child: Text(ConstantString.city,style: tbTextFieldStyle(),),
                             ),                  
                            Padding(
                                padding: const EdgeInsets.only(left:15.0, right: 15.0),
                              child: SizedBox(
                                height: deviceSize.height*.05,
                                child: TextFormField(  
                                  onTap: () {
                                     _showDialog('city');
                                  },
                                   style: tbFormTextProfileStyle(),
                                // cursorHeight: 10,
                                 onChanged: ((values){
                                  createMyBusinessController.txtControllerCity.text = values;
                                }), 
                                readOnly:true, 
                                controller: createMyBusinessController.txtControllerCity,
                                decoration: InputDecoration( 
                                 
                                   suffix: InkWell(
                                    onTap: () {
                                      _showDialog('city');
                                    },
                                    child: Image.asset(AppImages.downarrow, scale: imageScale)),                        
                                 enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                                    ),
                                     ), ),
                              ),
                            ),
                             SizedBox(
                              height: AppSizes.double40,
                            ),
                            Padding(
                                 padding: const EdgeInsets.all(15.0),
                               child: Text(ConstantString.postcodeDistrict,style: tbTextFieldStyle(),),
                             ),
                      createMyBusinessController.isLoading.value? AppLoader(): SizedBox(
              height: deviceSize.height*.5,
                       child: ListView.separated(
                                       itemCount: createMyBusinessController.arrayOfResidence!.length,
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
                        if(createMyBusinessController.selectedResidence.contains(createMyBusinessController.arrayOfResidence![index]!.id)){
                        createMyBusinessController.selectedResidence.remove(createMyBusinessController.arrayOfResidence![index]!.id);
                                           }else{
                         createMyBusinessController.selectedResidence.add(createMyBusinessController.arrayOfResidence![index]!.id);
                                           }
                                         });
                                         
                                   },
                                   leading: Text(
                                   createMyBusinessController.arrayOfResidence![index]!.postcodedistrict!,
                                   style: tbCategoryLable(),
                                   ),         
                                   trailing: createMyBusinessController.selectedResidence.contains(createMyBusinessController.arrayOfResidence![index]!.id)? Image.asset(
                                   AppImages.categorycheck,
                                   scale: imageScale,
                                   ):Image.asset(
                                   AppImages.categoryuncheck,
                                   scale: imageScale,
                                   ));
                                       },
                                     ),
                     ),]),
          )
        ),
      ),),
           bottomNavigationBar:  SizedBox(
        height: AppSizes.double100,
        child: Center(child: tbScreenButton(onTap: Get.back,title: ConstantString.continueTitle, height: deviceSize.height,width: deviceSize.width ))),
    );
  }
}
