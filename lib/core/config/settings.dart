import 'package:package_info_plus/package_info_plus.dart';

class Settings {
  static late String version;
  static late String baseUrl;
  static late bool isDev;

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    // Check if version contains 'dev' (case insensitive)
    isDev = version.toLowerCase().contains('dev');

    if (isDev) {
      baseUrl = 'http://192.168.1.5:5002';
    } else {
      baseUrl = 'https://wallet-api.bagdja.com';
    }
  }
}
