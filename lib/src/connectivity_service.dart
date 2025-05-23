import 'package:connectivity_plus/connectivity_plus.dart';

/// This class checks the connectivity status of the device.
/// It uses the [connectivity_plus] package to determine if the device is connected
/// to the internet or not.
/// It provides a static method [isConnected] that returns a [Future<bool>] indicating
/// whether the device is connected to the internet or not.
/// It is used in the [RetryOnConnectionChangeInterceptor] to determine if a request
/// should be retried when the device is connected to the internet.
class ConnectivityService {
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
