import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeIosUtil {
  // Đặt tên Channel khớp với Swift
  static const platform = MethodChannel('com.example.flutter_core/ios_channel');

  static Future<String> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return 'Pin hiện tại: $result%';
    } on PlatformException catch (e) {
      return "Lỗi Native: '${e.message}'.";
    } catch (_) {
      return "Hàm chưa được implement hoặc sai tên.";
    }
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'getDeviceInfo',
      );
      return result.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } on PlatformException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (_) {
      return {"error": "Lỗi hệ thống"};
    }
  }

  static Future<void> vibrate({int duration = 500}) async {
    try {
      await platform.invokeMethod('vibrate', {'duration': duration});
    } on PlatformException catch (e) {
      debugPrint("Vibrate error: ${e.message}");
    }
  }
}
