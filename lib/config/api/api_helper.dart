// Author - Rashmin Dungrani

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart' as getx;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/app/wights/dialogs/error_dialog.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_error_message.dart';
import 'package:team_balance/config/api/token/token_api.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/utils/app_widgets/app_loader.dart';
import 'package:team_balance/utils/app_widgets/toast.dart';
import '../log_helper.dart';
import 'network_info.dart';

enum HttpMethod {
  post,
  get,
  delete,
  patch,
  put,
  multipartPost,
}

extension HttpMethodExtension on HttpMethod {
  String get contentType {
    switch (this) {
      case HttpMethod.post:
        return 'application/x-www-form-urlencoded';
      case HttpMethod.get:
        return 'application/json';
      case HttpMethod.delete:
        return 'application/json';
      case HttpMethod.patch:
        return 'application/x-www-form-urlencoded';
      case HttpMethod.multipartPost:
        return 'application/x-www-form-urlencoded';
      default:
        return 'application/json';
    }
  }
}

late final NetworkInfo networkInfo;

final flashMessageController = FlashMessageController();

class ApiHelper {
  final String serviceName;
  final String endPoint;
  final String baseUrl;
  // final bool headerToken;
  // final bool useHeaderAccesskey;
  // final bool useHeaderSecretkey;

  final bool checkInternet;
  final bool showOverlay;
  final bool showTransparentOverlay;
  final bool showErrorDialog;
  final bool printRequest;
  final bool printResponse;
  final bool printHeaders;

  final Map<String, String>? additionalHeader;
  final Map<String, String>? useOnlyThisHeader;
  final int requestTimeoutSeconds;

  ApiHelper({
    required this.endPoint,
    this.baseUrl = ApiPaths.apiBaseUrl,
    this.serviceName = ' ',
    // this.headerToken = true,
    // this.useHeaderAccesskey = true,
    // this.useHeaderSecretkey = true,
    this.showOverlay = false,
    this.showTransparentOverlay = false,
    this.showErrorDialog = false,
    this.checkInternet = true,
    this.printRequest = false,
    this.printResponse = false,
    this.printHeaders = true,
    this.additionalHeader,
    this.useOnlyThisHeader,
    this.requestTimeoutSeconds = 60,
  });

  String get url =>
      serviceName != 'GetLocation' ? baseUrl + endPoint : endPoint;

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> get() async {
    final result = await _execute(HttpMethod.get, {});

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) => Right(r.cleanDecodedReponse),
    );
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> post({
    required Map<String, dynamic> body,
    bool isFormData = false,
  }) async {
    final result =
        await _execute(HttpMethod.post, body, isFormData: isFormData);
    print("result1: ${result.toString()}");

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) {
        return Right(r.cleanDecodedReponse);
      },
    );
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> put(
      {required Map<String, dynamic> body}) async {
    final result = await _execute(HttpMethod.put, body);

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) => Right(r.cleanDecodedReponse),
    );
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> patch(
      {required Map<String, dynamic> body}) async {
    final result = await _execute(HttpMethod.patch, body);

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) => Right(r.cleanDecodedReponse),
    );
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> delete(
      {required Map<String, dynamic> body, bool isFormData = false}) async {
    final result =
        await _execute(HttpMethod.delete, body, isFormData: isFormData);

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) => Right(r.cleanDecodedReponse),
    );
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> postMultipart({
    required Map<String, dynamic> body,
    Map<String, List<File>>? imageFile,
  }) async {
    final result =
        await _execute(HttpMethod.multipartPost, body, imageFileMap: imageFile);

    return result.fold(
      (l) => Left(l.cleanDecodedReponse),
      (r) {
        return Right(r.cleanDecodedReponse);
      },
    );
  }

  Future<Either<Response, Response>> _execute(
      HttpMethod method, Map<String, dynamic> body,
      {Map<String, List<File>>? imageFileMap, bool isFormData = false}) async {
    _printApiDetial(method: method, body: body);
    if (showTransparentOverlay) {
      LoadingOverlay.of(getx.Get.context!).showTransparent();
    } else if (showOverlay) {
      LoadingOverlay.of(getx.Get.context!).show();
    }
    if (checkInternet && !await networkInfo.checkIsConnected) {
      if (showOverlay || showTransparentOverlay) {
        LoadingOverlay.of(getx.Get.context!).hide();
      }

      // final flashMessageController = FlashMessageController();
      flashMessageController.showMessage(ToastType.info, 'No Internet');
      // showTopFlashMessage(ToastType.info, 'No internet');
      return Left(Response('', 400));
    }

    Response response;
    StreamedResponse? streamedResponse;

    try {
      switch (method) {
        case HttpMethod.post:
          response = await Client()
              .post(
                Uri.parse(url),
                headers: await getHeaders(method),
                body: isFormData ? body : jsonEncode(body),
              )
              .timeout(Duration(seconds: requestTimeoutSeconds),
                  onTimeout: () => throw TimeoutException(null));
          print("response==: ${response.body}");

          break;
        case HttpMethod.get:
          print("response====>>>>>>>>>>>>");
          response = await Client()
              .get(
                Uri.parse(url),
                headers: await getHeaders(method),
              )
              .timeout(Duration(seconds: requestTimeoutSeconds),
                  onTimeout: () => throw TimeoutException(null));
          print(await getHeaders(method));

          break;
        case HttpMethod.patch:
          response = await Client()
              .patch(
                Uri.parse(url),
                headers: await getHeaders(method),
                body: body,
              )
              .timeout(Duration(seconds: requestTimeoutSeconds),
                  onTimeout: () => throw TimeoutException(null));
          break;
        case HttpMethod.put:
          response = await Client()
              .put(
                Uri.parse(url),
                headers: await getHeaders(method),
                body: body,
              )
              .timeout(Duration(seconds: requestTimeoutSeconds),
                  onTimeout: () => throw TimeoutException(null));
          break;
        case HttpMethod.delete:
          response = await Client()
              .delete(
                Uri.parse(url),
                headers: await getHeaders(method),
                body: isFormData ? body : jsonEncode(body),
              )
              .timeout(Duration(seconds: requestTimeoutSeconds),
                  onTimeout: () => throw TimeoutException(null));
          break;
        case HttpMethod.multipartPost:
          final request = MultipartRequest("POST", Uri.parse(url));
          // convert Map<String, dynamic> to Map<String, String>
          final Map<String, String> stringMap = {};
          body.forEach((key, value) {
            stringMap[key] = value.toString();
          });
          request.headers.addAll(await getHeaders(method));
          // print(request.headers);
          request.fields.addAll(stringMap);
          // Log.info('*** imageFileMap ***');
          // Log.info(imageFileMap);
          if (imageFileMap != null) {
            imageFileMap.forEach((fieldName, imageFile) async {
              Log.info('$fieldName added');

              // from Map<String, File> every image and field_name will add to request files
              Log.info("MEDIA COUNT: ${imageFile.length}");
              for (File media in imageFile) {
                Log.info('FieldName: $fieldName');
                Log.info('MediaPath: ${media.path}');
                var contentType = getContentType(media.path);
                request.files.add(
                  await MultipartFile.fromPath(fieldName, media.path,
                      contentType: MediaType.parse(contentType)),
                );
              }
            });
          }

          streamedResponse = await request
              .send()
              .timeout(Duration(seconds: requestTimeoutSeconds));

          final resbody = await streamedResponse.stream.bytesToString();
          // convert StreamResponse (which uses MultipartRequest) to Response (http)
          response = Response(resbody, streamedResponse.statusCode,
              headers: streamedResponse.headers);
          break;
      }
    } on TimeoutException {
      Log.error('timeout exception thrown');
      response = Response("Request Timeout",
          408); // 408 is Request Timeout response status code
      // set body message to request timeout in network info class
      networkInfo.isConnected = false;
      networkInfo.requestStaus = EnumRequestStatus.requestTimeout;
    } catch (e) {
      Log.error(e);
      response = Response(
          e.toString(), 600); // 600 is i just takes as a socket exception
    }

    if (showOverlay || showTransparentOverlay) {
      LoadingOverlay.of(getx.Get.context!).hide();
    }

    _printResponse(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.cleanDecodedReponse;
      //print("decoded: ${decoded.hasStatusNum(1)}");
      // ! this is project wise conditions
      if (decoded.hasStatusNum('1') || decoded.hasStatusNum('0')) {
        return Right(response);
      } else if (decoded.hasStatusNum('OK')) {
        return Right(response);
      }
      // else if (decoded.hasStatusNum('failed') &&
      //     decoded.containsKey('message')) {
      //   return Left(response);
      // }
      // else if (decoded.hasStatusNum('msg') &&
      //     decoded.containsKey('msg') &&
      //     decoded['msg'] == 'Invalid token') {
      //   showTopFlashMessage(ToastType.failure, "Session expired!");
      //   await clearDataAndNavigateToLogin();
      //   return Left(response);
      // }
      else if (serviceName == 'refresh_token' && decoded.containsKey('data')) {
        return Right(response);
      } else {
        if (showErrorDialog) {
          Log.info(decoded);
          if (decoded.hasMessage && decoded['message'] != 'Invalid API key') {
            showTopFlashMessage(ToastType.failure,
                decoded['message'] ?? "Something went wrong");
          }
        }
        return Left(response);
      }
    } else {
      final decoded = response.cleanDecodedReponse;
      Log.info('INVALID RESPINSE $decoded');
      if (decoded.containsKey('msg') &&
          decoded['msg'] == 'No JWT-Token found.') {
        showTopFlashMessage(ToastType.failure,
            "You are currently logged in on another device.");
        await clearDataAndNavigateToLogin();
      }
      if (decoded.containsKey('message') &&
          decoded['message'] == 'No log in found.') {
        // showTopFlashMessage(ToastType.failure,
        //     "You are currently logged in on another device.");
        await clearDataAndNavigateToLogin();
      }

      print("response.statusCode: ${response.statusCode}");
      // showTopFlashMessage(ToastType.failure, decoded['message']);
      return Left(response);
    }
  }

  String getContentType(String filePath) {
    var fileType = filePath.split('.').last.toLowerCase();
    switch (fileType) {
      case 'gif':
      case 'WebP':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image/$fileType';
      case 'mp4':
      case 'mov':
        return 'video/$fileType';
      default:
        return 'application/octet-stream';
    }
  }

  Future<Map<String, String>> getHeaders(HttpMethod method) async {
    print(' thi sis cervice name ---->> ${serviceName}');
//  var isGuestLogin = await GS.readGuestLogin();

    final Map<String, String> headers = {};
    headers['Content-Type'] = method.contentType;

    if (useOnlyThisHeader != null) {
      headers.addAll(useOnlyThisHeader!);
      return headers;
    }
    headers['platform'] = Platform.isIOS ? 'ios' : 'android';
    if (serviceName == "refresh_token") {
      headers['platform'] = Platform.isIOS ? 'ios' : 'android';
    } else {
      headers['device_type'] = Platform.isIOS ? 'ios' : 'android';
      headers['device_token'] = GSAPIHeaders.fcmToken ?? '';
      headers['is_testdata'] = AppConfig.isTestData.toString();
      await PackageInfo.fromPlatform().then((value) {
      headers['app_version'] = value.version.toString();    
      });
      
    }

    if (serviceName == "phone_number_otp") {
      Log.success("IN phone_number_otp: ${GSAPIHeaders.loginToken} ");
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else if (serviceName == "resend_otp_for_profile_update") {
      Log.success(
          "IN serviceName == resend_otp_for_profile_update: ${GSAPIHeaders.loginToken} ");
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else if (GSAPIHeaders.userToken != null) {
      Log.success(
          "IN GSAPIHeaders.userToken != null: ${GSAPIHeaders.userToken} ");
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.userToken}';
    } else if (serviceName == "refresh_token") {
      Log.success(
          "IN serviceName == refresh_token (user): ${GSAPIHeaders.userToken} ");
      Log.success(
          "IN serviceName == refresh_token (login): ${GSAPIHeaders.loginToken} ");
    } else if (serviceName == "verify_loggin_account") {
      Log.success(
        "IN serviceName == verify_loggin_account ${GSAPIHeaders.loginToken}",
      );
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else if (serviceName == "resend_otp") {
      Log.success(
        "IN serviceName == resend_otp ${GSAPIHeaders.loginToken}",
      );
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else if (serviceName == "guest_login_token") {
      Log.success(
        "IN serviceName == guest_login_token ${GSAPIHeaders.loginToken}",
      );
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else if (serviceName == "resend_otp_for_profile_update") {
      Log.success(
        "IN serviceName == resend_otp_for_profile_update ${GSAPIHeaders.loginToken}",
      );
      print('code is here 123');
      headers['Authorization'] = 'Bearer ${GSAPIHeaders.loginToken}';
    } else {
      final hasWrittenBearerToken = await TokenAPI.getTokenApi();
      Log.info('not adding token coz this is Token API');
      if (!hasWrittenBearerToken) {
        showTopFlashMessage(ToastType.failure, APIErrorMsg.somethingWentWrong);
        Log.error('API_HELPER :: Bearer token is NULL');
      } else {
        print('code is here 789');
        headers['Authorization'] = 'Bearer ${GSAPIHeaders.bearerToken}';
      }
    }

    if (additionalHeader != null) {
      headers.addAll(additionalHeader!);
    }

    if (printHeaders) {
      Log.error('*** HEADER in $endPoint API ***');
      Log.error(headers.toPrettyString());
    }
    print("headers: $headers");
    return headers;
  }

  // API info...
  void _printApiDetial({
    required HttpMethod method,
    required Map<String, dynamic> body,
  }) {
    // if (kReleaseMode || printRequest == false) return;
    Log.info("""

╔════════════════════════════════════════════════════════════════════════════╗
║     API REQUEST                                                            ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Type   :- ${method.name}
║ URL    :- $url
║ Params :- ${jsonEncode(body)}
╚════════════════════════════════════════════════════════════════════════════╝
""");
  }

  // API resposne info...
  void _printResponse(Response response) {
    late final String responseBody;
    if (printResponse) {
      try {
        responseBody = Map<String, dynamic>.from(jsonDecode(response.body))
            .toPrettyString();
      } catch (e) {
        Log.error("-- RESPONSE BODY IS NOT PROPER in $endPoint API --");
        responseBody = response.body;
      }
    }
    if (printResponse &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      Log.success("""
╔════════════════════════════════════════════════════════════════════════════╗
║      API RESPONSE                                                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║ API        :- $endPoint
║ StatusCode :- ${response.statusCode}
║ Response   :- 

$responseBody

╚════════════════════════════════════════════════════════════════════════════╝
""");
    } else if (printResponse) {
      Log.error("""
╔════════════════════════════════════════════════════════════════════════════╗
║      API RESPONSE                                                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║ API        :- $endPoint
║ StatusCode :- ${response.statusCode}
║ Response   :- 

$responseBody

╚════════════════════════════════════════════════════════════════════════════╝
""");
    }
  }

  void _showApiErrorDialog(Response response) {
    try {
      if (showErrorDialog) {
        if (response.statusCode == 600) {
          errorDialog(
              title: APIErrorMsg.underMaintainanceTitle,
              message: APIErrorMsg.httpErrorMsg);
          return;
        }
        if (response.statusCode == 408) {
          showTopFlashMessage(
              ToastType.failure, APIErrorMsg.requestTimeOutTitle);
          return;
        }
        if (response.body.isEmpty) {
          Log.error('Response body is empty');
          showTopFlashMessage(
              ToastType.failure, APIErrorMsg.somethingWentWrong);
          return;
        }
        final decoded = jsonDecode(response.body);
        if (decoded.containsKey('error')) {
          final String errorTypeKey = decoded['error'].keys.toList()[0];
          errorDialog(title: decoded['error'][errorTypeKey][0]);
        } else if (decoded.containsKey('data') &&
            (decoded['data'].containsKey('errors') ||
                decoded['data'].containsKey('error'))) {
          String errorName = 'errors';
          if (decoded['data'].containsKey('error')) {
            errorName = 'error';
          }
          final String errorTypeKey =
              decoded['data'][errorName].keys.toList()[0];
          errorDialog(title: decoded['data'][errorName][errorTypeKey][0]);
        } else if (decoded.containsKey('message')) {
          errorDialog(title: decoded['message']);
        } else {
          Log.error(
              "*******  Error key not contains so not showing errorDialog ********");
          Log.error('decoded = $decoded');
        }
      }
    } catch (e, stacktrace) {
      Log.error(
          '-------------- stacktrace _showApiErrorDialog ----------------');
      Log.error(stacktrace);
    }
  }
}

extension APIResponse on Response? {
  Map<String, dynamic> get cleanDecodedReponse {
    if (this == null) return {};
    try {
      return jsonDecode(this!.body.removeNotice);
    } catch (e, stacktrace) {
      Log.error("**** While Decoding API response");
      Log.error("response");
      Log.error(this!.body);
      Log.error("** stacktrace **");
      Log.error(stacktrace);
      throw Exception("While decoding API response");
    }
  }
}

extension APIBody on String? {
  String get removeNotice {
    if (this == null) {
      return "{}";
    }
    if (this!.startsWith('{') || this!.startsWith('[')) {
      return this!;
    }
    final startIndex = this!.indexOf('{');
    if (startIndex == -1) {
      // debugPrint("not starting with {");
      Log.info(this);
      return "{}";
    }
    return this!.substring(startIndex);
  }
}

extension APIMapBody on Map<String, dynamic> {
  bool hasStatusNum(String value, {bool printStatus = false}) {
    if (containsKey('status')) {
      final result = this['status'].toString() == value.toString();
      if (printStatus) {
        Log.info('API body status - ${this['status']}');
      }
      return result;
    }
    // print('hasStatusNumber - status param not contain');
    return false;
  }

  bool get hasMessage {
    return containsKey('message');
  }

  String toPrettyString() {
    var encoder = const JsonEncoder.withIndent("     ");
    return encoder.convert(this);
  }
}
