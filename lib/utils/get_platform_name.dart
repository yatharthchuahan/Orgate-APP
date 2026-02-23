import 'dart:io';

String getDevicePlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isLinux) return 'Linux';
  if (Platform.isFuchsia) return 'Fuchsia';
  return 'Unknown';
}
