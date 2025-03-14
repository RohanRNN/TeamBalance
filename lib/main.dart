import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team_balance/api/firebase_api.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/views/chats/chat_message_screen.dart';
import 'package:team_balance/app/views/comment_screen.dart';
import 'package:team_balance/app/views/home_screen.dart';
import 'package:team_balance/app/views/login_screen.dart';
import 'package:team_balance/app/views/settings/my_business/ads%20plan/ads_plan_screen.dart';
import 'package:team_balance/app/views/settings/post/create_post_screen.dart';
import 'package:team_balance/app/views/tutorial_screen.dart';
import 'package:team_balance/config/api/api_helper.dart';
import 'package:team_balance/config/api/network_info.dart';
import 'package:team_balance/config/api/socket_utils.dart';
import 'package:team_balance/config/api/sqflite_database/database_helper.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/config/log_helper.dart';
import 'package:team_balance/constants/app_constants.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/firebase_options.dart';
import 'package:team_balance/in_app_purchase.dart';
import 'package:team_balance/utils/models/chat_list_model.dart';
import 'package:team_balance/utils/models/comment_model.dart';
import 'package:team_balance/utils/models/post_model.dart';
import 'package:team_balance/utils/models/user_model.dart';
import 'package:team_balance/utils/packages/data_connection_checker.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final dbHelper = DatabaseHelper();
bool isSocketListnerAdded = false;
String currentScreen = '';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await GetStorage.init();
    await dbHelper.init();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseApi().initNotifications();
    // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await Future.delayed(Duration(seconds: 1));
    //    FlutterNativeSplash.remove();
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    //  FlutterNativeSplash.remove();

    // Handle notification when app is terminated
    // RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // if (initialMessage != null) {
    //   await Future.delayed(Duration(milliseconds: 500)); // Ensure Firebase is stable
    //   FirebaseApi().handleNotificationNavigation(initialMessage);
    // }
//    FirebaseMessaging.instance.getInitialMessage().then((message) async {
//   await Future.delayed(Duration(seconds: 2));
//   if (message != null) {
//     // Ensure app is initialized before navigating
//     if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
//       FirebaseApi().handleNotificationNavigation(message);
//     }
//   }
// });

// Check for notification data when app is killed
FirebaseMessaging.instance.getInitialMessage().then((message) async {
  await Future.delayed(Duration(seconds: 1));
  if (message != null) {  
    UserModel? user = await GS.readUserData(); 
    if (await GS.readRememberMe() == true && user != null) { 
          if(message.data['noti_type'] == AppConstants.notiTypePostlike )
    { 
      await Future.delayed(Duration(seconds: 3));
      PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
      //  Get.to(
      Get.to(
            () => CommentScreen(
                  postModelData: postModel,
                ),
            arguments: {
                "postId": postModel.id,
                "index": 1,
                "postModel": postModel,
              });
    } else if(message.data['noti_type'] == AppConstants.notiTypePostcomment)
    {
      await Future.delayed(Duration(seconds: 3));
      PostModel postModel = PostModel.fromJson(jsonDecode(message.data['noti_data']));
      CommentModel commentModel = CommentModel.fromJson(jsonDecode(message.data['noti_comment_data'])[0]);
      //  Get.to(
      Get.to(
            () => CommentScreen(
                  postModelData: postModel,
                ),
            arguments: {
                "postId": postModel.id,
                "index": 1,
                "postModel": postModel,
                "postCommentModel": commentModel,
              });
    }
    else if(message.data['noti_type'] == AppConstants.notiTypeNewmessage)
    {
      await Future.delayed(Duration(seconds: 2));
      Map<String, dynamic> notiData = jsonDecode(message.data['noti_data']);
      if(notiData['is_new_conversation'] == 1){
      int senderId = notiData['data']['getNewMessageFromConvo']['sender_id'];
      int messageId = notiData['data']['getNewMessageFromConvo']['id'];
      int conversationId = notiData['data']['getNewMessageFromConvo']['conversation_id'];
      var conversationData =  ConversationModel(
            id: notiData['data']['getNewMessageFromConvo']['conversation_id'],
            createdby: notiData['data']['getNewMessageFromConvo']['sender_id'],
            receiverid: notiData['data']['getNewMessageFromConvo']['receiver_id'],
            conversationid: notiData['data']['getNewMessageFromConvo']['conversation_id'],
            senderid: notiData['data']['getNewMessageFromConvo']['sender_id'],
            messagecontent: notiData['data']['getNewMessageFromConvo']['message_content'],
            readat: true,
            profileuserid: notiData['data']['getNewMessageFromConvo']['sender_id'],
            fullname:notiData['data']['getNewMessageFromConvo']['full_name'],
            profileimage: notiData['data']['getNewMessageFromConvo']['profile'],
            createdAt:notiData['data']['getNewMessageFromConvo']['message_created_at'],
            isDelete: false,
          );
      Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        messageIdFromNotification: messageId,
        ),arguments: {
          "conversationData":conversationData
  });
      }else{
      int senderId = notiData['data']['sender_id'];
      int messageId = notiData['data']['message_id'];
      int conversationId = notiData['data']['conversation_id'];
      var conversationData =  ConversationModel(
            id: notiData['data']['conversation_id'],
            createdby: notiData['data']['sender_id'],
            receiverid: notiData['data']['receiver_id'],
            conversationid: notiData['data']['conversation_id'],
            senderid: notiData['data']['sender_id'],
            messagecontent: notiData['data']['message_content'],
            readat: true,
            profileuserid: notiData['data']['sender_id'],
            fullname:notiData['data']['full_name'],
            profileimage: notiData['data']['profile'],
            createdAt:notiData['data']['message_created_at'],
            isDelete: false,
          );
      Get.to(() => ChatMessageScreen(
          isFromConversationScreen: true, 
        conversationId: conversationId,
        messageIdFromNotification: messageId,
        ),arguments: {
          "conversationData": conversationData
  });
      }
      // int senderId = notiData['data']['sender_id'];
      // int messageId = notiData['data']['message_id'];
      // chatWithAdmin(userId: senderId, messageId :messageId);

    }  
    }
  }
});
    runApp(const MyApp());
  } catch (e, stackTrace) {
    Log.info("in main function catch");
    Log.error(e);
    Log.error(stackTrace);
  } 
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Widget initScreen = const TutorialScreen();
  AppLifecycleState? _appLifecycleState;
  // Widget initScreen = const LoginScreen();

  void initState() {
    _getInitScreen();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> isRunningOnSimulator() async {
    // Add logic to detect the simulator if needed
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });

    if (state == AppLifecycleState.resumed) {
      print("App is in the foreground");
      SocketUtils.joinSocket();
      // Handle app resumed state (foreground)
    } else if (state == AppLifecycleState.paused) {
      SocketUtils.disconnetSocket();
      SocketUtils.socket.disconnect();
      print("App is in the background");
    }
  }

  void _getInitScreen() async {
    networkInfo = NetworkInfoImpl(DataConnectionChecker());
    await GSAPIHeaders.readAll();
    await GS.readUserData();
    UserModel? user = await GS.readUserData();
    print('Value for GS.readRememberMe() ======>>>>> ${GS.readRememberMe()}');
    print(
        'Value for GS.readTutorialSeen() ======>>>>> ${await GS.readTutorialSeen()}');
    if (await GS.readTutorialSeen() == true) {
      if (await GS.readRememberMe() == true && user != null) {
        setState(() {
          SocketUtils.joinSocket();
          initScreen = HomeScreen(
            isFromContinueAsGuest: false,
            isFromChatScreen: false,
            indexForScreen: 0,
          );
        });
      } else {
        print(
            "==========> await GS.readRememberMe() == false==> ${await GS.readRememberMe() == false}");
        print("==========> user == null == false==> ${user == null}");
        print(
            "========================Tutorial is True from main file=======================");
        setState(() {
          initScreen = LoginScreen();
        });
        await dbHelper.clearDatabase();
        //  GS.clearAll();
        var deviceToke = '';
        if (GSAPIHeaders.fcmToken != null) {
          deviceToke = GSAPIHeaders.fcmToken ?? '';
        }
        GSAPIHeaders.bearerToken = null;
        GSAPIHeaders.userToken = null;
        GSAPIHeaders.fcmToken = null;
        GSAPIHeaders.loginToken = null;
        GSAPIHeaders.isGuestAccount = 0;
        // GS.clearAll();
        GS.clearUserData();
        Log.info('LOGOUT TOKE: $deviceToke');
        GSAPIHeaders.fcmToken = deviceToke;
      }
    } else {
      print(
          "==========> await GS.readRememberMe() == false==> ${await GS.readRememberMe() == false}");
      print("==========> user == null == false==> ${user == null}");
      print(
          "========================Tutorial is False from main file=======================");
      await dbHelper.clearDatabase();
      //  GS.clearAll();
      var deviceToke = '';
      if (GSAPIHeaders.fcmToken != null) {
        deviceToke = GSAPIHeaders.fcmToken ?? '';
      }
      await GS.clearAll();
      Log.info('LOGOUT TOKE: $deviceToke');
      GSAPIHeaders.fcmToken = deviceToke;
    }

    await Firebase.initializeApp();
    if (Platform.isIOS && await isRunningOnSimulator()) {
      print("Skipping topic subscription on iOS Simulator.");
      return;
    }
    await FirebaseApi().firebaseInit(context);
    //  //  requestAPNSToken();

    // code for Ina
    await InAppPurchaseUtils.inAppPurchaseUtilsInstance.initialize();

    if (!AppConfig.isLandscapeOrientationSupported) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(AppImages.backGroundImg), context);
    return GetMaterialApp(
        builder: (context, child) {
          return MediaQuery(
            child: child!,
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.0), boldText: false),
          );
        },
        title: 'TeamBalance',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        debugShowCheckedModeBanner: false,
        home: initScreen);
  }
}
