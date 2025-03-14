import 'package:team_balance/app/controllers/cache/get_storage.dart';
import 'package:team_balance/config/api/api_endpoints.dart';
import 'package:team_balance/config/api/api_helper.dart';

import '../../log_helper.dart';

abstract class TokenAPI {
  // * 👽 RefreshToken

  // static Future<bool> postRefreshTokenApi({bool handleErrors = true}) async {
  //   final apiHelper = ApiHelper(
  //     serviceName: "RefreshToken",
  //     endPoint: ApiPaths.refreshToken,
  //     showErrorDialog: handleErrors,
  //   );
  //   final result = await apiHelper.post(body: {});
  //   return result.fold((l) {
  //     return false;
  //   }, (r) async {
  //     try {
  //       // print(r);
  //       // * Write tempToken as secretKey in LS Headers
  //       if (r.containsKey('tempToken')) {
  //         await GSAPIHeaders.writeSecretKey(r['tempToken']);
  //         return true;
  //       } else {
  //         Log.error("RefreshToken not contains tempToken");
  //         Log.error(r);
  //       }

  //       // NameOfModel.fromJson(r).data;
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //     return false;
  //   });
  // }

  // // * 👽 Encrypt GUID
  // static Future<bool> postEncryptGuidApi(
  //     {required String guid, bool handleErrors = true}) async {
  //   final apiHelper = ApiHelper(
  //     serviceName: "Encrypt GUID",
  //     endPoint: ApiPaths.encryptGuid,
  //     showErrorDialog: handleErrors,
  //   );
  //   final result = await apiHelper.post(body: {
  //     "guid": guid,
  //   });
  //   return result.fold((l) {
  //     return false;
  //   }, (r) async {
  //     try {
  //       Log.info(r);
  //       // * Save Encrypt GUID as accessKey in LSAPIHeaders
  //       if (r.containsKey('encrypted_value')) {
  //         await GSAPIHeaders.writeAccessKey(r['encrypted_value']);
  //         return true;
  //       }
  //     } catch (e, stacktrace) {
  //       Log.error('\n******** $e ********\n$stacktrace');
  //     }
  //     return false;
  //   });
  // }

  static Future<bool> getTokenApi({bool handleErrors = true}) async {
    
    final apiHelper = ApiHelper(
      serviceName: "refresh_token",
      endPoint: ApiPaths.refresh_token,
      showErrorDialog: handleErrors,
    );
    final result = await apiHelper.get();
    // final result = await apiHelper.post(body: {}, isFormData: true);
    
    print('${result}');

    return result.fold((l) {
     print('this is =======>111');
      return false;
    }, (r) async {
      print('this is =======>222');
      try {
        print(r['data']['token']);
        // print(r);
        // * Write Bearer Token in LS Headers
        if (r.containsKey('data')) {
          await GSAPIHeaders.writeBearerToken(r['data']['token']);
          print(r['data']['token']);
          return true;
        } else {
          Log.error("token not contains data");
          Log.error(r);
        }
      } catch (e, stacktrace) {
        Log.error('\n******** $e ********\n$stacktrace');
      }
      return false;
    });
  }
}
