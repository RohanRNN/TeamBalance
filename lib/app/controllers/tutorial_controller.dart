
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/constants/app_images.dart';


class TutorialController extends GetxController {
  var indexCount = 0; 

static const screenImageArray = [
AppImages.tutorial1Img,
AppImages.tutorial2Img,
AppImages.tutorial3Img,
AppImages.tutorial4Img,
]; 

static const screenTitleArray = [
  'Welcome to TEAMBALANCE',
  'Explore your surroundings!',
  'Communicate with the people from your nearby!',
  'Promote your Business!',
  
];

static const screenDetailArray = [
'\tThe purpose of TeamBalance is to connect residents within the same postcode district.',
'\tTeamBalance strongly stands for cooperation and teamwork, where all the members are a part of a big team.',
'\tWho are willing to work together as a team by sharing ideas and information in order to help each other with the cost of the living crisis.',
'\tTeamBalance will provide an opportunity for local businesses to connect directly with their community.',

]; 

 void loginScreen() {
    
    Get.offAll(() => const LoginScreen());
  }


}
