

import 'package:team_balance/utils/packages/data_connection_checker.dart';

enum EnumRequestStatus {
  allGood,
  noInternet,
  requestTimeout,
  somethingWentWrong,
}

abstract class NetworkInfo {
  bool isConnected = false;

  EnumRequestStatus requestStaus = EnumRequestStatus.allGood;
  Future<bool> get checkIsConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker connectionChecker;

  NetworkInfoImpl(
    this.connectionChecker, {
    this.isConnected = false,
    this.requestStaus = EnumRequestStatus.allGood,
  });

  @override
  Future<bool> get checkIsConnected async {
    isConnected = await connectionChecker.hasConnection;
    if (isConnected) {
      requestStaus = EnumRequestStatus.allGood;
    }
    return isConnected;
  }

  @override
  bool isConnected;

  @override
  EnumRequestStatus requestStaus;
}
