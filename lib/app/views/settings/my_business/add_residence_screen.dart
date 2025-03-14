import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:team_balance/app/controllers/add_residence_controller.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/wights/dialogs/custom_alert_dialog.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/models/residence_model.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class AddResidenceScreen extends StatefulWidget {
     AddResidenceScreen({
    super.key,
    required this.isForEditResidenceAddress,
    required this.isFormHomeScreen,
    required this.isFromSignUpScreen, 
    required this.residenceModel    
  });
final bool isForEditResidenceAddress;
final bool isFormHomeScreen;
final bool isFromSignUpScreen;
final ResidenceModel residenceModel;

  @override
  State<AddResidenceScreen> createState() => _AddResidenceScreenState();
}

class _AddResidenceScreenState extends State<AddResidenceScreen> {
  final AddResidenceController addResidenceController = Get.put(AddResidenceController());

  @override
  void initState() {
   addResidenceController.addResidenceDetails(widget.residenceModel);
     addResidenceController.cityDataList = GS.masterApiData.value!.citydata!; 
     addResidenceController.postCodeList = GS.masterApiData.value!.postcodedistirctdata!; 
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
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
              addResidenceController.postCodeList = GS.masterApiData.value!.postcodedistirctdata!; 
              selectedCity = value!['city'];
              addResidenceController.txtControllerCity.text = value!['city']!;
              addResidenceController.postCodeList = addResidenceController.postCodeList!.where((residence) {
        return residence!.cityId == selectedCityId;  // Filter by city_id
      }).toList();   
              Navigator.pop(context);
            });
          },
          city: addResidenceController.cityDataList, 
        );
        }else if (dialogBoxFor == "country"){
          return CountryDialog(
          selectedCountry: selectedCountry,
          onSelected: (value) {
            int selectedCountryId = int.parse(value!['id']!);
            setState(() {
              addResidenceController.cityDataList = GS.masterApiData.value!.citydata!; 
              selectedPostcode = value!['country'];
              addResidenceController.txtControllerCountry.text = value!['country']!;
               addResidenceController.cityDataList = addResidenceController.cityDataList!.where((residence) {
        return residence!.countryId == selectedCountryId;  // Filter by city_id
      }).toList();  
              Navigator.pop(context);
            });
          },
          country: addResidenceController.countryDataList,
        );
        }else{
           return PostcodeDialog(
          selectedPostcode: selectedPostcode,
          onSelected: (value) {
            setState(() {
              selectedPostcode = value;
              addResidenceController.txtControllerPostDistrict.text = value!;
              Navigator.pop(context);
            });
          },
          postcodes: addResidenceController.postCodeList,
        );
        }
       
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    const imageScale = 2.6;
    var deviceSize = MediaQuery.of(context).size; 
       return Scaffold(
          extendBodyBehindAppBar: true,
      appBar: AppBar(
         systemOverlayStyle: SystemUiOverlayStyle.dark,  
       backgroundColor: Colors.transparent,
        elevation: 0,
        // leadingWidth: 0,
        leading:
         widget.isFormHomeScreen || widget.isFromSignUpScreen ? 
        SizedBox():
         InkWell(
          onTap: () {
            Get.back();
          },
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text(widget.isForEditResidenceAddress? ConstantString.editResidence :ConstantString.addResidence,style: tbScreenBodyTitle(),),
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              onTap: widget.isFormHomeScreen ? (){
                Get.back();
              }: (){
               widget.isForEditResidenceAddress  ? Get.back() : addResidenceController.skipAndGoHome() ;
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text( ConstantString.skip,style: tbTextButtonStyle(),),
              )),
          ],
        ),
      ),
           body:  Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:Padding(
          padding: const EdgeInsets.only(left:40.0,top:20,right: 50),
          child: SafeArea(
            child: ListView(
                children: [
                    Padding(
                           padding: const EdgeInsets.only(bottom:10.0),
                           child: Text(ConstantString.country,style: tbTextFieldStyle(),),
                         ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField( 
                            onTap: () {
                             _showDialog('country');
                          },
                              style: tbFormTextProfileStyle(),
                          // cursorHeight: 10,
                           onChanged: ((values){
                            addResidenceController.txtControllerCountry.text = values;
                          }), 
                          readOnly:true, 
                          controller: addResidenceController.txtControllerCountry,
                          decoration: InputDecoration(  
                            
                             suffix: InkWell(
                              onTap: () {
                                // _showDialog('country');
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
                          SizedBox(
                          height: AppSizes.double40,
                        ),
                         Padding(
                           padding: const EdgeInsets.only(bottom:10.0),
                           child: Text(ConstantString.city,style: tbTextFieldStyle(),),
                         ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField(  
                            onTap: () {
                               _showDialog('city');
                            },
                             style: tbFormTextProfileStyle(),
                          // cursorHeight: 10,
                           onChanged: ((values){
                            addResidenceController.txtControllerCity.text = values;
                          }), 
                          readOnly:true, 
                          controller: addResidenceController.txtControllerCity,
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
                          SizedBox(
                          height: AppSizes.double40,
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
                            style: tbFormTextRecidenceStyle(),
                          // cursorHeight: 10,
                          onChanged: ((values){
                            addResidenceController.txtControllerPostDistrict.text = values;
                          }),  
                          readOnly:true, 
                          controller: addResidenceController.txtControllerPostDistrict,
                          decoration: InputDecoration(  
                                                    
                             suffix: InkWell(
                              onTap: () {
                                // _showDialog('postCode');
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
                        SizedBox(
                          height: AppSizes.double40,
                        ),
                         Padding(
                           padding: const EdgeInsets.only(bottom:10.0),
                           child: Text(ConstantString.houseNumber,style: tbTextFieldStyle(),),
                         ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField(   style: tbFormTextProfileStyle(),
                          // cursorHeight: 10,
                           onChanged: ((values){
                            addResidenceController.txtControllerHouseNumber.text = values;
                          }), 
                          controller: addResidenceController.txtControllerHouseNumber,
                          decoration: InputDecoration(                          
                           enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                              ),
                               ), ),
                        ),
                        SizedBox(
                          height: AppSizes.double40,
                        ),
                         Padding(
                           padding: const EdgeInsets.only(bottom:10.0),
                           child: Text(ConstantString.streenName,style: tbTextFieldStyle(),),
                         ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField(   style: tbFormTextProfileStyle(),
                          // cursorHeight: 10,
                           onChanged: ((values){
                            addResidenceController.txtControllerStreetName.text = values;
                          }), 
                          controller: addResidenceController.txtControllerStreetName,
                          decoration: InputDecoration(                          
                           enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                              ),
                               ), ),
                        ),
                        SizedBox(
                          height: AppSizes.double40,
                        ),
                         Padding(
                           padding: const EdgeInsets.only(bottom:10.0),
                           child: Text(ConstantString.area,style: tbTextFieldStyle(),),
                         ),                  
                        SizedBox(
                          height: deviceSize.height*.05,
                          child: TextFormField(   style: tbFormTextProfileStyle(),
                          // cursorHeight: 10,
                           onChanged: ((values){
                            addResidenceController.txtControllerArea.text = values;
                          }), 
                          controller: addResidenceController.txtControllerArea,
                          decoration: InputDecoration(                          
                           enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                              ),
                               ), ),
                        ),
                        // SizedBox(
                        //   height: AppSizes.double40,
                        // ),
                        //  Padding(
                        //    padding: const EdgeInsets.only(bottom:10.0),
                        //    child: Text(ConstantString.city,style: tbTextFieldStyle(),),
                        //  ),                  
                        // SizedBox(
                        //   height: deviceSize.height*.05,
                        //   child: TextFormField(  
                        //     onTap: () {
                        //        _showDialog('city');
                        //     },
                        //      style: tbFormTextProfileStyle(),
                        //   // cursorHeight: 10,
                        //    onChanged: ((values){
                        //     addResidenceController.txtControllerCity.text = values;
                        //   }), 
                        //   readOnly:true, 
                        //   controller: addResidenceController.txtControllerCity,
                        //   decoration: InputDecoration( 
                           
                        //      suffix: InkWell(
                        //       onTap: () {
                        //         _showDialog('city');
                        //       },
                        //       child: Image.asset(AppImages.downarrow, scale: imageScale)),                        
                        //    enabledBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                        //       ),
                        //       focusedBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                        //       ),
                        //        ), ),
                        // ),
                        // SizedBox(
                        //   height: AppSizes.double40,
                        // ),
                        //  Padding(
                        //    padding: const EdgeInsets.only(bottom:10.0),
                        //    child: Text(ConstantString.country,style: tbTextFieldStyle(),),
                        //  ),                  
                        // SizedBox(
                        //   height: deviceSize.height*.05,
                        //   child: TextFormField( 
                        //     onTap: () {
                        //      _showDialog('country');
                        //   },
                        //       style: tbFormTextProfileStyle(),
                        //   // cursorHeight: 10,
                        //    onChanged: ((values){
                        //     addResidenceController.txtControllerCountry.text = values;
                        //   }), 
                        //   readOnly:true, 
                        //   controller: addResidenceController.txtControllerCountry,
                        //   decoration: InputDecoration(  
                            
                        //      suffix: InkWell(
                        //       onTap: () {
                        //         // _showDialog('country');
                        //       },
                        //       child: Image.asset(AppImages.downarrow, scale: imageScale)),                        
                        //    enabledBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.grey.shade200), // Light grey color for the underline
                        //       ),
                        //       focusedBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.blue.shade200), // Optionally, a lighter blue when the field is focused
                        //       ),
                        //        ), ),
                        // ),
                        SizedBox(
                          height: AppSizes.double40,
                        ),
                ],
              ),
          ),
        ),
      ),
           bottomNavigationBar: Obx(() => addResidenceController.isLoading.value? Center(child: AppLoader(),):  SizedBox(
        height: AppSizes.double100,
        child: Center(child: tbScreenButton(onTap: widget.isFromSignUpScreen? addResidenceController.saveAndGoHome: addResidenceController.save,title: ConstantString.save, height: deviceSize.height,width: deviceSize.width ))),)
    );
  }
}
