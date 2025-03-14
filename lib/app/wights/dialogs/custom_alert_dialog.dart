

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/models/master_data_model.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class TBCustomAlertDialog extends StatelessWidget {
  const TBCustomAlertDialog(
      {super.key,
      required this.image,
      required this.title,
      required this.onTapOption1,
      required this.onTapOption2,
      required this.option1,
      required this.option2});

  final String image;
  final String title;

  final String option1;
  final String option2;

  final VoidCallback onTapOption1;
  final VoidCallback onTapOption2;

  @override
  Widget build(BuildContext context) {
    final dynamicSize = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
      backgroundColor: AppColors.primaryColor,
      content: SizedBox(
        height: dynamicSize.height * 0.2,
        width: dynamicSize.width * 0.65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: AppSizes.double50,
              backgroundColor: AppColors.fantedBlueColor,
              child: Image.asset(
                image,
                scale: 3,
                // color: AppColors.blueThemeColor,
              ),
            ),
            Spacer(),
            // SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
              child: AutoSizeText(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                  maxLines: 2, 
                  minFontSize: 12,  
              ),
            ),
            SizedBox(height: AppSizes.double10),
          ],
        ),
      ),
      actions: <Widget>[
        const Divider(height: 0, color: AppColors.lightGrey),
        Padding(
          padding: const EdgeInsets.only(left:15.0,right: 15.0,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (option1 != '')
                TextButton(
                  onPressed: onTapOption1,
                  child: Text(
                    option1,
                    style: const TextStyle(
                        color: AppColors.mediumGreyCancel,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              if (option1 != '')
                Container(
                  width: 1.0,
                  height: AppSizes.double25,
                  color: AppColors.lightGrey,
                ),
              TextButton(
                onPressed: onTapOption2,
                child: Text(
                  option2,
                  style: const TextStyle(
                      color: AppColors.textButtonBlueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class PostcodeDialog extends StatelessWidget {
  final String? selectedPostcode;
  final Function(String?) onSelected;
  final List<PostcodeDistirctData?> postcodes; // Example postcodes

  PostcodeDialog({Key? key, this.selectedPostcode, required this.onSelected, required this.postcodes}) : super(key: key);

  @override
    Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,  // Remove padding around the content
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
        ),
        width: double.maxFinite,
        height: AppSizes.double500,
        child: ListView(
          children: postcodes.map((postcode) => RadioListTile<String>(
            activeColor: AppColors.blueThemeColor,            
            title: Text(postcode!.postcodedistrict!,style: tbFormTextResidence(),),
            value: postcode.postcodedistrict!,
            groupValue: selectedPostcode,
            onChanged: (value) {
              onSelected(value);
            },
            controlAffinity: ListTileControlAffinity.trailing,  // Move radio button to the right
          )).toList(),
        ),
      ),
     
    );
  }
}

class CityDialog extends StatefulWidget {
  final String? selectedPostcode;
  final Function(Map<String, String>?) onSelected;
  final List<CityData?> city; // Example cities

  CityDialog({Key? key, this.selectedPostcode, required this.onSelected, required this.city}) : super(key: key);

  @override
  _CityDialogState createState() => _CityDialogState();
}

class _CityDialogState extends State<CityDialog> {
  TextEditingController searchController = TextEditingController();
  List<CityData?> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = widget.city; // Initially show all cities
    searchController.addListener(_filterCities); // Listen to changes in the search field
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    setState(() {
      // Filter the city list based on the search input
      filteredCities = widget.city
          .where((city) => city!.city!.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        width: double.maxFinite,
        height: AppSizes.double500,
        child: Column(
          children: [
            // Add a search field at the top
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:     TextField(
  controller: searchController,
  decoration: InputDecoration(
    labelText: 'Search City',
    labelStyle: TextStyle(
      fontFamily: FontFamilyName.montserrat
      // color: AppColors.blueThemeColor
    ),
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.lightGrey, 
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
         color: AppColors.lightGrey,
        
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.blueThemeColor, 
        width: 1.0, 
      ),
    ),
  ),
),
            ),
            Expanded(
              child: ListView(
                children: filteredCities.map((city) {
                  return RadioListTile<String>(
                    activeColor: AppColors.blueThemeColor,
                    title: Text(city!.city!, style: tbFormTextResidence()),
                    value: city.city!,
                    groupValue: widget.selectedPostcode,
                    onChanged: (value) {
                      widget.onSelected({
                        'city': city.city!,
                        'id': city.id.toString(), // Assuming id is an int, convert it to String
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing, // Move radio button to the right
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class CityDialog extends StatelessWidget {
//   final String? selectedPostcode;
//    final Function(Map<String, String>?) onSelected;
//   // final Function(String?) onSelected;
//   final List<CityData?> city; // Example postcodes

//   CityDialog({Key? key, this.selectedPostcode, required this.onSelected, required this.city}) : super(key: key);

//   @override
//     Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.transparent,
//       contentPadding: EdgeInsets.zero,  // Remove padding around the content
//       content: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15)
//         ),
//         width: double.maxFinite,
//         height: AppSizes.double500,
//         child: Column(
//           children: [
            
//             ListView(
//               children: city.map((city) => RadioListTile<String>(
//                 activeColor: AppColors.blueThemeColor,            
//                 title: Text(city!.city!,style: tbFormTextResidence(),),
//                 value: city.city!,
//                 groupValue: selectedPostcode,
//                 onChanged: (value) {
//                   // onSelected(value);
//                     onSelected({
//                     'city': city.city!,
//                     'id': city.id.toString() // Assuming id is an int, convert it to String
//                   });
//                 },
//                 controlAffinity: ListTileControlAffinity.trailing,  // Move radio button to the right
//               )).toList(),
//             ),
//           ],
//         ),
//       ),
     
//     );
//   }
// }

class CountryDialog extends StatefulWidget {
  final String? selectedCountry;
  final Function(Map<String, String>?) onSelected;
  final List<CountryData?> country; // List of countries

  CountryDialog({Key? key, this.selectedCountry, required this.onSelected, required this.country}) : super(key: key);

  @override
  _CountryDialogState createState() => _CountryDialogState();
}

class _CountryDialogState extends State<CountryDialog> {
  TextEditingController searchController = TextEditingController();
  List<CountryData?> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = widget.country; // Initially show all countries
    searchController.addListener(_filterCountries); // Listen to search input
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    setState(() {
      // Filter the country list based on the search input
      filteredCountries = widget.country
          .where((country) => country!.country!.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        width: double.maxFinite,
        height: AppSizes.double500,
        child: Column(
          children: [
            // Add search field on top
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              TextField(
  controller: searchController,
  decoration: InputDecoration(
    labelText: 'Search country',
    labelStyle: TextStyle(
      fontFamily: FontFamilyName.montserrat
      // color: AppColors.blueThemeColor
    ),
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.lightGrey, 
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
         color: AppColors.lightGrey,
        
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.blueThemeColor, 
        width: 1.0, 
      ),
    ),
  ),
),
            ),
            Expanded(
              child: ListView(
                children: filteredCountries.map((country) {
                  return RadioListTile<String>(
                    activeColor: AppColors.blueThemeColor,
                    title: Text(country!.country!, style: tbFormTextResidence()),
                    value: country.country!,
                    groupValue: widget.selectedCountry,
                    onChanged: (value) {
                      widget.onSelected({
                        'country': country.country!,
                        'id': country.id.toString(), // Assuming id is an int, convert to String
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing, // Move radio button to the right
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class CountryDialog extends StatelessWidget {
//   final String? selectedPostcode;
//   // final Function(String?) onSelected;
//    final Function(Map<String, String>?) onSelected;
//   final List<CountryData?> country; // Example postcodes

//   CountryDialog({Key? key, this.selectedPostcode, required this.onSelected, required this.country}) : super(key: key);

//   @override
//     Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.transparent,
//       contentPadding: EdgeInsets.zero,  // Remove padding around the content
//       content: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15)
//         ),
//         width: double.maxFinite,
//         height: AppSizes.double500,
//         child: ListView(
//           children: country.map((country) => RadioListTile<String>(
//             activeColor: AppColors.blueThemeColor,            
//             title: Text(country!.country!,style: tbFormTextResidence(),),
//             value: country.country!,
//             groupValue: selectedPostcode,
//             onChanged: (value) {
//               // onSelected(value);
//                 onSelected({
//                 'country': country.country!,
//                 'id': country.id.toString() // Assuming id is an int, convert it to String
//               });
//             },
//             controlAffinity: ListTileControlAffinity.trailing,  // Move radio button to the right
//           )).toList(),
//         ),
//       ),
     
//     );
//   }
// }


class TBGuestUserDialog extends StatelessWidget {
  const TBGuestUserDialog(
      {super.key,});

  @override
  Widget build(BuildContext context) {
    final dynamicSize = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0),
      backgroundColor: AppColors.primaryColor,
      content: SizedBox(
        height: dynamicSize.height * 0.2,
        width: dynamicSize.width * 0.65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: AppSizes.double50,
              backgroundColor: AppColors.fantedBlueColor,
              child: Image.asset(
                AppImages.guestpopup,
                scale: 3,
                // color: AppColors.blueThemeColor,
              ),
            ),
            Spacer(),
            // SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(top:8.0,left: 15,right: 15),
              child: AutoSizeText(
                ConstantString.guestAccountMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                  minFontSize: 12,  
              ),
            ),
            SizedBox(height: AppSizes.double10),
          ],
        ),
      ),
      actions: <Widget>[
        const Divider(height: 0, color: AppColors.lightGrey),
        Padding(
          padding: const EdgeInsets.only(left:15.0,right: 15.0,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                TextButton(
                  onPressed: () {
              Get.back();
            },
                  child: Text(
                    ConstantString.cancel.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.mediumGreyCancel,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                Container(
                  width: 1.0,
                  height: AppSizes.double25,
                  color: AppColors.lightGrey,
                ),
              TextButton(
                onPressed:() async {
              var deviceToke = '';
              if (GSAPIHeaders.fcmToken != null && GSAPIHeaders.fcmToken!.isNotEmpty) {
                deviceToke = GSAPIHeaders.fcmToken ?? '';
              }
              await GS.clearUserData();
              await GS.clearAll();
              Log.info('LOGOUT TOKE: $deviceToke');
              GSAPIHeaders.fcmToken = deviceToke;
              Get.offAll(() => const LoginScreen());
            },
                child: Text(
                  ConstantString.continueTitle.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.textButtonBlueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}