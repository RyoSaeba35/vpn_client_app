import 'package:flutter/services.dart';

class SingBoxHelper {
  static const MethodChannel _channel = MethodChannel('vpn/singbox');

  static Future<bool> startVPN(String config) async {
    return await _channel.invokeMethod('startVpn', {'config': config});
  }

  static Future<bool> stopVPN() async {
    return await _channel.invokeMethod('stopVpn');
  }
}
