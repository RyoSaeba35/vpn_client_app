import 'package:flutter/services.dart';

class VpnPlatform {
  static const MethodChannel _channel =
      MethodChannel('vpn/singbox');

  static Future<bool> prepareVpn() async {
    final result = await _channel.invokeMethod<bool>('prepareVpn');
    return result ?? false;
  }
}
