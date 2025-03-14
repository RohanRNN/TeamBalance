

import 'package:team_balance/config/app_config.dart';

abstract class ApiPaths {
  static const String apiBaseUrl = AppConfig.isInProduction
      ? " " //Live purpose
      // : "http://192.168.1.103:4000";
      // : "http://clientapp.narola.online:9581";
      // :"https://7cb4-110-227-216-48.ngrok-free.app";
      :"https://api.teambalance.uk";

// Auth APIs
  static const String refresh_token = "/auth/refreshtoken";
  static const String login_otp = "/auth/login_otp";
  static const String verify_loggin_account = "/auth/verify_loggin_account";
  static const String register = "/auth/register";
  static const String resend_otp = "/auth/resend_otp";
  static const String guest_login_token = "/auth/guest_login_token";  
  

// Home APIs  
  static const String get_residence = "/residence/get_residence";
  static const String update_residence = "/residence/update_residence";
  static const String create_residence = "/auth/create_residence";
  static const String get_allposts = "/post/get_allposts?";
  static const String get_post_user_profile = "/post/get_post_user_profile?";
  static const String like_dislike_post = "/post/like_dislike_post?"; 
  static const String get_myposts = "/post/get_myposts?"; 
  static const String delete_post = "/post/delete_post";
  static const String report_post = "/post/report_post";
  static const String create_comment = "/post/create_comment";
  static const String report_comment = "/post/report_comment";
  static const String create_post = "/post/create_post";
  static const String get_comments = "/post/get_comments?";
  static const String search_post = "/post/search-post?";
  // static const String update_residence = "/residence/update_residence";   
  static const String post_for_guest = "/guest/post_for_guest?";

// Profile APIs
  static const String update_profile = "/user/update_profile";  
  static const String get_profile = "/user/get_profile";
  static const String phone_number_otp = "/user/phone_number_otp";
  static const String block_user = "/user/block_user";
  static const String get_blocked_users = "/user/get_blocked_users?";
  static const String resend_otp_for_profile_update = "/user/resend_otp_for_profile_update";
 

// Settings APIs
  static const String user_logout = "/setting/user_logout"; 
  static const String delete_account = "/setting/delete_account";
  static const String help_and_support = "/setting/help_and_support";
  static const String get_notifications = "/setting/get_notifications?";


  //  Business APIs
  static const String get_master_data = "/business/get_master_data";
  static const String get_categories = "/business/get_categories";
  static const String create_business = "/business/create_business";
  static const String get_business_details = "/business/get_business_details";
  static const String update_business_details = "/business/update_business_details";
  static const String get_all_advertisements = "/business/get_all_advertisements?";
  static const String get_business_advertisement = "/business/get_business_advertisement?";
  static const String create_business_advertisement = "/business/create_business_advertisement?";
  static const String delete_business_advertisement = "/business/delete_business_advertisement?";
  static const String disable_enable_business_advertisement = "/business/disable_enable_business_advertisement?";
  static const String get_plans = "/plans/get_plans?";
  static const String post_purchase_plan_details = "/plans/post_purchase_plan_details";
     

// Images paths
static const profilePath = "${apiBaseUrl}/upload/profile-image/";
static const postMediaPath = "${apiBaseUrl}/upload/post-media/";
static const businessLogoMediaPath = "${apiBaseUrl}/upload/business-logo/";
// static const postVideoPath = "${apiBaseUrl}/upload/profile-image/";
static const postThumbnilePath = "${apiBaseUrl}/upload/thumbnail/";
static const commentMediaPath = "${apiBaseUrl}/upload/comment-media/";

// business ads
static const businessLogo = "${apiBaseUrl}/upload/business-logo/";
static const businessAdsMedia = "${apiBaseUrl}/upload/advertisement-media/";
static const businessAdsThumbnail = "${apiBaseUrl}/upload/advertisement-thumbnail/";

// chat apis
static const get_user_chatlist = "/chat/get_user_chatlist";

// get detsila api
static const get_post_details = "/setting/get-notification-post?";
static const get_comment_details = "/setting/get-notification-comment?";
static const get_message_details = "/setting/get-notification-message?";

}


abstract class SocketPaths {
  static const String socketUrl =
      //  "http://clientapp.narola.online:9581/"; //client app
      //  "https://7cb4-110-227-216-48.ngrok-free.app"; //live
      "https://api.teambalance.uk"; //live
      // "http://192.168.1.103:4000";

  static const String getUserId = 'get_user_id';
  static const String newMessage = 'new_message';
  static const String disconnectSocket = 'disconnect';
  static const String fetchInitialConversation = 'get_conversation_list';
  static const String getConversation = 'get_conversation';
  static const String socketMapping = 'socket_mapping';
  static const String getConversationListEvent = 'get_conversation_list_event';
  static const String previousConversations = 'previous_conversations';
  static const String conversationIdKey = 'conversationId';
  static const String blockUnblockUser = 'block_unblock_user';
  static const String blockUnblockResult = 'block_unblock_result';
  static const String typing = 'typing';
  static const String typingResult = 'typing_result';
  static const String messageDelivered = 'messageDelivered';
  static const String messageDeliveredResult = 'messageDeliveredResult';
  static const String onlineStatus = 'onlineStatus';
  static const String updateReadStatusOfMsg = 'updateReadStatusOfMsg';
  static const String updateMsgReadStatusResult = 'updateMsgReadStatusResult';
}


abstract class ApiStatus {
  static const int success = 1;
  static const int failed = 0;
}

abstract class SocketStatus {
  static const String success = "Success";
  static const String failed = "Failed";
}

