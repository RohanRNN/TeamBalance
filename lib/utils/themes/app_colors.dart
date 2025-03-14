import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Colors.white;
  static const Color textFieldHintColor = Colors.grey;
  static const Color textFieldTextColor = Color.fromARGB(255, 168, 167, 167);
  static const Color textButtonTextColor = Color.fromARGB(255, 0, 128, 246);
  static const Color chatTextFieldBackground = Color.fromARGB(255, 84, 84, 84);
  static const Color backgroundColor = Color.fromARGB(255, 56, 56, 56);
  static const Color darkBackgroundColor = Color.fromARGB(255, 28, 28, 28);

  static const Color bottomTabBackgroundColor = Color.fromARGB(150, 56, 56, 56);

  static const Color blueThemeColor = Color.fromARGB(255, 8, 101, 206);

  static const Color mediumBlueThemeColor = Color.fromARGB(255, 1, 136, 233);

  static const Color lightBlueThemeColor = Color.fromARGB(255, 0, 143, 246);

  static const Color textButtonBlueColor = Color.fromARGB(255, 0, 136, 247);

  static const Color fantedBlueColor = Color.fromARGB(255, 207, 227, 244);

  static const Color searchBarColor = Color.fromARGB(255, 237, 241, 244);

  static const Color placeHolderGray = Color.fromARGB(255, 236, 236, 236);

  static const Color blueThemeColorDark = Color.fromARGB(255, 68, 25, 211);

  static const Color checkColor = Colors.white;

  static const Color textBoldColor = Colors.black;

  static const Gradient appGraadient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromARGB(225,0,117,255), Color.fromARGB(255,0,68,148)],
  );

  static const Gradient blackGraadient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      black,
      black,
    ],
  );

  static const Color black = Color.fromRGBO(41, 41, 41, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color darkGrey = Color.fromRGBO(102, 102, 102, 1);
  static const Color mediumGrey = Color.fromRGBO(133, 133, 133, 1);
  static const Color mediumGreyCancel = Color.fromRGBO(149, 149, 149, 1);
  static const Color textFormMediumGrey = Color.fromRGBO(168, 168, 168, 1);
  static const Color lightGrey = Color.fromRGBO(216, 216, 216, 1);
  static const Color moreLightGrey = Color.fromRGBO(232, 230, 230, 1);
  static const Color moreLightGreyToggelSwitch = Color.fromRGBO(245, 245, 245, 1);
  static const Color lightLightGrey = Color.fromRGBO(242, 241, 241, 1);
  static const Color lightGreen = Color.fromRGBO(49, 173, 88, 1);
  static const Color mediumGreyText = Color.fromARGB(225, 115, 115, 115);
  static const Color darkGreyText = Color.fromARGB(225, 41, 41, 41);
  

  static const planContainerColors = [
    Color.fromRGBO(226, 246, 254, 1),
    Color.fromRGBO(205, 236, 228, 1),
    Color.fromRGBO(255, 238, 234, 1),
  ];

    static const planLineColors = [
    Color.fromRGBO(5, 181, 250, 1),
    Color.fromRGBO(4, 177, 134, 1),
    Color.fromRGBO(248, 124, 96, 1),
  ];

  // Added by jyoti
  static const Color lightGrey1 = Color(0xFF474747);
  static const Color lightBlack = Color(0xFF565656);
  static const Color mediumBlack = Color.fromARGB(255, 54, 53, 53);
}
