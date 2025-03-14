import 'package:flutter/material.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/utils/themes/app_colors.dart';


TextStyle tbAuthTextFieldStyle() {
  return const TextStyle(
    fontSize:13,
    color: AppColors.textFormMediumGrey,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbTextFieldStyle() {
  return const TextStyle(
    fontSize:12,
    color: AppColors.mediumGreyText,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbFormValueTextStyle() {
  return const TextStyle(
    fontSize:16,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbTextFieldProfileStyle() {
  return const TextStyle(
    fontSize:12,
    color: AppColors.mediumGreyText,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbFormTextProfileStyle() {
  return const TextStyle(
    fontSize:14,
    color: AppColors.darkGreyText,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbFormTextResidence() {
  return const TextStyle(
    fontSize:17,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbFormTextRecidenceStyle() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbFormTextStyle() {
  return const TextStyle(
    fontSize:14,
    color: AppColors.darkGreyText,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbSettingsLable() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbCategoryLable() {
  return const TextStyle(
    fontSize:16,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}



UnderlineInputBorder tbUnderlineInputBorder() {
  return const UnderlineInputBorder(
    borderSide: BorderSide(color: AppColors.textFieldHintColor),
  );
}




Widget tbAppBarBackButton({required VoidCallback onTap}) {
  return Padding(
    padding: EdgeInsets.only(left:15,),
    child: GestureDetector(
      onTap: onTap,
      child: Image.asset(AppImages.backImg,scale: 2.5,),
    ),
  );
}

TextStyle tbNavigationBarTitleStyle() {
  return const TextStyle(
    fontFamily: FontFamilyName.montserrat,
    fontSize: 18,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
  );
}

TextStyle tbTextButton() {
  return const TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbScreenBodyTitle() {
  return const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbReportReasonTitle() {
  return const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPlaceHolderText() {
  return const TextStyle(
    fontSize: 12,
    color: AppColors.mediumGrey,
    fontFamily: FontFamilyName.montserrat
  );
}



TextStyle tbScreenBodyDescription() {
  return const TextStyle(
    fontSize: 14,
    color: AppColors.mediumGrey,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbTextFieldTitleStyle() {
  return const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbTextFieldSearchStyle() {
  return const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbTextButtonStyle() {
  return const TextStyle(
           fontSize:17,
          // fontSize:18,
           color:AppColors.textButtonTextColor,
           fontWeight: FontWeight.w600,
          //  fontFamily: FontFamilyName.montserrat
         );
}

TextStyle tbResendTextButtonStyle() {
  return const TextStyle(
           fontSize:18,
           color:AppColors.textButtonTextColor,
           fontWeight: FontWeight.w600,
          //  fontFamily: FontFamilyName.montserrat
         );
}

UnderlineInputBorder tbFocusInputBorder() {
  return  UnderlineInputBorder(
    borderSide: BorderSide(color: AppColors.blueThemeColor),
  );
}


TextStyle tbTextButtonStyleDeactive() {
  return const TextStyle(
           fontSize:17.5,
           color:AppColors.mediumGrey,
           fontWeight: FontWeight.w600,
          //  fontFamily: FontFamilyName.montserrat
         );
}

TextStyle tbTextButtonStyleGrey() {
  return const TextStyle(
           fontSize:16,
           color:AppColors.mediumGrey,
           fontWeight: FontWeight.w500,
           fontFamily: FontFamilyName.montserrat
         );
}

Widget tbScreenButton({required Function onTap,String title = '',double height=0, double width=0}) {
  return  Container(                    
                    // height: height*.062,
                    // width: width*.68,
                    height: 55,
                    width: width*.68,
                    decoration: BoxDecoration(
                    gradient: AppColors.appGraadient,                  
                    borderRadius: BorderRadius.circular(18.0)
                    ),
                      child: InkWell(
                    onTap: () {            
                      onTap();
                    },
                    child:  Center(
                    child: Text(
                      title,
                      style: tbTextButton(),
                    ),
                    ),
                    ),
                    );
}

Widget tbCustomLoader({double height=0, double width=0}) {
  return    Center(
                                  child: Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: Offset(0, 5), // X and Y offset
                                        ),
                                      ],
                                    ),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 20),
                                              Text(
                                                'Loading...',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
}


TextStyle tbAdsTitle() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostUserName() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostDescription() {
  return const TextStyle(
    fontSize:11,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbCreatePostText() {
  return const TextStyle(
    fontSize:18,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostUserNameBlack() {
  return const TextStyle(
    fontSize:14,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbNotification() {
  return const TextStyle(
    fontSize:13,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}
TextStyle tbNotificationTime() {
  return const TextStyle(
    fontSize:11,
    color: AppColors.mediumGrey,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbPostDescriptionBlack() {
  return const TextStyle(
    fontSize:14,
    height: 1.75,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostDescriptionTimeBlack() {
  return const TextStyle(
    fontSize:11,
    height: 1.75,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}


TextStyle tbReportReason() {
  return const TextStyle(
    fontSize:14,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbNoDataFoundTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontFamily: FontFamilyName.montserrat,
    color: AppColors.darkGrey,
    fontWeight: FontWeight.w600,
  );
}

TextStyle tbAdsLeftTextStyle() {
  return const TextStyle(
    color: AppColors.mediumBlueThemeColor, 
    fontSize: 11, 
    fontFamily: FontFamilyName.montserrat,
    fontWeight: FontWeight.w600
    );
}

TextStyle tbOtpTextStyle() {
  return const TextStyle(fontSize: 20, 
  color: Color.fromRGBO(30, 60, 87, 1), 
  fontWeight: FontWeight.w700,
  // fontFamily: FontFamilyName.montserrat
  );

}

TextStyle tbMediaTextSelected() {
  return const TextStyle(
    color: AppColors.mediumBlueThemeColor, 
    fontSize: 15, 
    fontFamily: FontFamilyName.montserrat,
    fontWeight: FontWeight.w600
    );
}

TextStyle tbMediaTextNormal() {
  return const TextStyle(
    color: AppColors.black, 
    fontSize: 15, 
    fontFamily: FontFamilyName.montserrat,
    fontWeight: FontWeight.w400
    );
}



TextStyle tbAdsStatusTextStyle() {
  return const TextStyle(
    color: AppColors.white, 
    fontSize: 11, 
    fontFamily: FontFamilyName.montserrat,
    fontWeight: FontWeight.w600
    );
}


TextStyle helpAndSupport() {
  return const TextStyle(color: AppColors.black,
                          fontFamily: FontFamilyName.montserrat,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          fontSize: 13);
}

TextStyle helpAndSupportBody() {
  return const TextStyle(color: AppColors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamilyName.montserrat,
                          height: 1.4,
                          fontSize: 13.5);
}

TextStyle tbAdsText() {
  return const TextStyle(
    fontSize:14,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

Widget tbNavigationBarTitle(String title) {
  return Text(
    title,
    style: tbNavigationBarTitleStyle(),
  );
}

TextStyle tbButtonTextStyle() {
  return const TextStyle(
    fontSize: 15,
    fontFamily: FontFamilyName.montserrat,
    color: AppColors.white,
    fontWeight: FontWeight.w600,
  );
}

TextStyle tbChatTextStyleBlack() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.textBoldColor,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbChatTextStyleWhite() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.white,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbChatTimeStyle() {
  return const TextStyle(
    fontSize:15,
    color: AppColors.lightGrey,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbBlockUserList() {
  return const TextStyle(
    fontSize:15,
    height: 1.75,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbBlockUserListWhite() {
  return const TextStyle(
    fontSize:16,
    height: 1.75,
    color: AppColors.blueThemeColor,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostDateAndTime() {
  return TextStyle(
    fontSize:10,
    height: 1.75,
    color: Colors.grey.shade700,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostDateAndTimeForMedia() {
  return const TextStyle(
    fontSize:10,
    height: 1.75,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbPostMoreOption() {
  return const TextStyle(
    fontSize:12,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamilyName.montserrat
  );
}

TextStyle tbGuestUserTitleTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontFamily: FontFamilyName.montserrat,
    color: AppColors.darkGrey,
    fontWeight: FontWeight.w600,
  );
}

TextStyle tbGuestUserMessageTextStyle() {
  return const TextStyle(
    fontSize: 14,
    fontFamily: FontFamilyName.montserrat,
    color: Color.fromARGB(255, 191, 186, 186),
    fontWeight: FontWeight.w600,    
  );
}