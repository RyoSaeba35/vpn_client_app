import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef start_vpn_func = Void Function(Pointer<Utf8> configPath);
typedef StartVpn = void Function(Pointer<Utf8> configPath);

typedef stop_vpn_func = Void Function();
typedef StopVpn = void Function();

// Load the library depending on platform
final DynamicLibrary singboxLib = () {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open("libsingbox.so");
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open("libsingbox.dylib");
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("singbox.dll");
  } else {
    throw UnsupportedError("This platform is not supported.");
  }
}();

// Bind functions
final StartVpn startVPN = singboxLib
    .lookup<NativeFunction<start_vpn_func>>('StartVPN')
    .asFunction();

final StopVpn stopVPN = singboxLib
    .lookup<NativeFunction<stop_vpn_func>>('StopVPN')
    .asFunction();
