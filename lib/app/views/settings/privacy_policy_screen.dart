import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/constants/app_images.dart';
import 'package:team_balance/constants/string_constants.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/themes/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  
final controller = WebViewController();

@override
void initState() {
  super.initState();
  // const pdfUrl = AppConfig.privacyPolicyLink;
  // final googleDocsViewer = 'https://docs.google.com/gview?embedded=true&url=$pdfUrl';
  // controller
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..loadRequest(Uri.parse(googleDocsViewer));
}

  // @override
  // void dispose() {
  //   loginController.dispose();
  //   super.dispose();
  // }

Future<bool> isValidUrl(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    const imageScale = 3.0;
    var deviceSize = MediaQuery.of(context).size; 
       return Scaffold(
          extendBodyBehindAppBar: true,
      appBar: AppBar(
         systemOverlayStyle: SystemUiOverlayStyle.dark,  
       backgroundColor: Colors.white,
        elevation: 0,
      centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          
          child: Image.asset(AppImages.blackBackButton,scale: imageScale,)),
        title: Text(ConstantString.privacyPolicy,style: tbScreenBodyTitle(),),
      ),
           body:  Container(  
            width: deviceSize.width,          
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backGroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child:
           FutureBuilder<bool>(
    future: isValidUrl(AppConfig.privacyPolicyLink),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: AppLoader());
      } else if (snapshot.hasError || !(snapshot.data ?? false)) {
        return Center(child: Text('Error: PDF not found.'));
      } else {
        return PDF().cachedFromUrl(
          AppConfig.privacyPolicyLink,
          placeholder: (progress) => Center(child: AppLoader()),
          errorWidget: (error) => Center(child: Text('Error: $error')),
        );
      }
    },
  )
      )
    );
  }
}
