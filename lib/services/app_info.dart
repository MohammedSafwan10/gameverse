import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Version comes from the installed binary, including build-name overrides.
abstract final class AppInfo {
  static final version = ValueNotifier<String>('Unavailable');
  static Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version.value = '${info.version} (${info.buildNumber})';
    } catch (_) {
      // Package metadata must never prevent offline games from launching.
      version.value = 'Unavailable';
    }
  }
}
