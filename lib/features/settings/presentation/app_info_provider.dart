import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  const AppInfo({required this.version, required this.buildNumber, required this.deviceName});

  final String version;
  final String buildNumber;
  final String deviceName;
}

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfo = DeviceInfoPlugin();

  String deviceName;
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    deviceName = '${info.manufacturer} ${info.model} (Android ${info.version.release})';
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    deviceName = '${info.name} (iOS ${info.systemVersion})';
  } else {
    deviceName = Platform.operatingSystem;
  }

  return AppInfo(version: packageInfo.version, buildNumber: packageInfo.buildNumber, deviceName: deviceName);
});
