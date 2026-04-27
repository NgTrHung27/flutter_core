import AudioToolbox  // Thư viện để rung (Haptic)
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    // 1. Khai báo Channel iOS
    let iosChannel = FlutterMethodChannel(
      name: "com.hungdevmobile.flutter_core/ios_channel",
      binaryMessenger: controller.binaryMessenger)

    // 2. Lắng nghe tin nhắn từ Dart
    iosChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if call.method == "getBatteryLevel" {
        self.receiveBatteryLevel(result: result)
      } else if call.method == "getDeviceInfo" {
        self.receiveDeviceInfo(result: result)
      } else if call.method == "vibrate" {
        self.vibrateDevice(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Hàm Native lấy Pin iOS
  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true  // Phải bật cờ này lên mới lấy được pin

    if device.batteryState == UIDevice.BatteryState.unknown {
      result(
        FlutterError(
          code: "UNAVAILABLE",
          message: "Không có thông tin pin (Có thể bạn đang dùng Simulator).",
          details: nil))
    } else {
      // Pin iOS trả về từ 0.0 -> 1.0, nên phải nhân 100
      result(Int(device.batteryLevel * 100))
    }
  }

  // Hàm Native lấy Info iOS
  private func receiveDeviceInfo(result: FlutterResult) {
    let device = UIDevice.current
    let info: [String: String] = [
      "model": device.model,  // VD: iPhone
      "name": device.name,
      "systemName": device.systemName,  // VD: iOS
      "systemVersion": device.systemVersion,  // VD: 17.0
      "identifierForVendor": device.identifierForVendor?.uuidString ?? "Unknown",
    ]
    result(info)
  }

  // Hàm Native Rung (Haptic Feedback)
  private func vibrateDevice(result: FlutterResult) {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
    result(nil)
  }
}
