import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gameverse/services/app_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('app version reflects the installed binary rather than UI constants',
      () async {
    PackageInfo.setMockInitialValues(
        appName: 'GameVerse',
        packageName: 'com.nexdarklabs.gameverse',
        version: '9.4.2',
        buildNumber: '73',
        buildSignature: 'test');
    await AppInfo.initialize();
    expect(AppInfo.version.value, '9.4.2 (73)');
  });
}
