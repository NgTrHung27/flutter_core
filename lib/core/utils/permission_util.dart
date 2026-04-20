// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

enum PermissionType {
  calendar,
  camera,
  contacts,
  location,
  locationAlways,
  locationWhenInUse,
  mediaLibrary,
  microphone,
  phone,
  photos,
  photosAddOnly,
  reminders,
  sensors,
  sms,
  speech,
  storage,
  ignoreBatteryOptimizations,
  notification,
  accessMediaLocation,
  activityRecognition,
  bluetooth,
  manageExternalStorage,
  systemAlertWindow,
  requestInstallPackages,
  appTrackingTransparency,
  criticalAlerts,
  accessNotificationPolicy,
  bluetoothScan,
  bluetoothAdvertise,
  bluetoothConnect,
  nearbyWifiDevices,
  videos,
  audio,
  scheduleExactAlarm,
  sensorsAlways,
  calendarWriteOnly,
  calendarFullAccess,
  assistant,
  backgroundRefresh,
}

class PermissionUtil {
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    // If permanently denied, open settings
    if (status.isPermanentlyDenied) {
      await AppSettings.openAppSettings();
      return false;
    }

    // Request permission - shows native dialog
    final result = await permission.request();

    if (result.isGranted) {
      return true;
    }

    // After user denies, check again
    final newStatus = await permission.status;
    if (newStatus.isPermanentlyDenied) {
      await AppSettings.openAppSettings();
      return false;
    }

    return false;
  }

  static Future<PermissionStatus> checkPermission(Permission permission) =>
      permission.status;

  static Future<Map<PermissionType, PermissionStatus>>
  checkAllPermissions() async {
    return {
      PermissionType.camera: await Permission.camera.status,
      PermissionType.storage: await Permission.storage.status,
      PermissionType.location: await Permission.location.status,
      PermissionType.locationAlways: await Permission.locationAlways.status,
      PermissionType.locationWhenInUse:
          await Permission.locationWhenInUse.status,
      PermissionType.microphone: await Permission.microphone.status,
      PermissionType.bluetooth: await Permission.bluetooth.status,
      PermissionType.bluetoothScan: await Permission.bluetoothScan.status,
      PermissionType.bluetoothAdvertise:
          await Permission.bluetoothAdvertise.status,
      PermissionType.bluetoothConnect: await Permission.bluetoothConnect.status,
      PermissionType.contacts: await Permission.contacts.status,
      PermissionType.phone: await Permission.phone.status,
      PermissionType.sms: await Permission.sms.status,
      PermissionType.calendar: await Permission.calendar.status,
      PermissionType.calendarWriteOnly:
          await Permission.calendarWriteOnly.status,
      PermissionType.calendarFullAccess:
          await Permission.calendarFullAccess.status,
      PermissionType.photos: await Permission.photos.status,
      PermissionType.photosAddOnly: await Permission.photosAddOnly.status,
      PermissionType.mediaLibrary: await Permission.mediaLibrary.status,
      PermissionType.videos: await Permission.videos.status,
      PermissionType.audio: await Permission.audio.status,
      PermissionType.reminders: await Permission.reminders.status,
      PermissionType.speech: await Permission.speech.status,
      PermissionType.sensors: await Permission.sensors.status,
      PermissionType.sensorsAlways: await Permission.sensorsAlways.status,
      PermissionType.activityRecognition:
          await Permission.activityRecognition.status,
      PermissionType.accessMediaLocation:
          await Permission.accessMediaLocation.status,
      PermissionType.ignoreBatteryOptimizations:
          await Permission.ignoreBatteryOptimizations.status,
      PermissionType.notification: await Permission.notification.status,
      PermissionType.accessNotificationPolicy:
          await Permission.accessNotificationPolicy.status,
      PermissionType.manageExternalStorage:
          await Permission.manageExternalStorage.status,
      PermissionType.systemAlertWindow:
          await Permission.systemAlertWindow.status,
      PermissionType.requestInstallPackages:
          await Permission.requestInstallPackages.status,
      PermissionType.appTrackingTransparency:
          await Permission.appTrackingTransparency.status,
      PermissionType.criticalAlerts: await Permission.criticalAlerts.status,
      PermissionType.nearbyWifiDevices:
          await Permission.nearbyWifiDevices.status,
      PermissionType.scheduleExactAlarm:
          await Permission.scheduleExactAlarm.status,
      PermissionType.assistant: await Permission.assistant.status,
      PermissionType.backgroundRefresh:
          await Permission.backgroundRefresh.status,
    };
  }

  static Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }

  static Future<bool> requestByType(PermissionType type) {
    return requestPermission(type.permission);
  }
}

extension PermissionTypeExtension on PermissionType {
  String get displayName {
    switch (this) {
      case PermissionType.camera:
        return 'Camera';
      case PermissionType.storage:
        return 'Storage';
      case PermissionType.location:
        return 'Location';
      case PermissionType.locationAlways:
        return 'Location Always';
      case PermissionType.locationWhenInUse:
        return 'Location When In Use';
      case PermissionType.microphone:
        return 'Microphone';
      case PermissionType.bluetooth:
        return 'Bluetooth';
      case PermissionType.bluetoothScan:
        return 'Bluetooth Scan';
      case PermissionType.bluetoothAdvertise:
        return 'Bluetooth Advertise';
      case PermissionType.bluetoothConnect:
        return 'Bluetooth Connect';
      case PermissionType.contacts:
        return 'Contacts';
      case PermissionType.phone:
        return 'Phone';
      case PermissionType.sms:
        return 'SMS';
      case PermissionType.calendar:
        return 'Calendar';
      case PermissionType.calendarWriteOnly:
        return 'Calendar Write Only';
      case PermissionType.calendarFullAccess:
        return 'Calendar Full Access';
      case PermissionType.photos:
        return 'Photos';
      case PermissionType.photosAddOnly:
        return 'Photos Add Only';
      case PermissionType.mediaLibrary:
        return 'Media Library';
      case PermissionType.videos:
        return 'Videos';
      case PermissionType.audio:
        return 'Audio';
      case PermissionType.reminders:
        return 'Reminders';
      case PermissionType.speech:
        return 'Speech';
      case PermissionType.sensors:
        return 'Sensors';
      case PermissionType.sensorsAlways:
        return 'Sensors Always';
      case PermissionType.activityRecognition:
        return 'Activity Recognition';
      case PermissionType.accessMediaLocation:
        return 'Access Media Location';
      case PermissionType.ignoreBatteryOptimizations:
        return 'Ignore Battery Optimizations';
      case PermissionType.notification:
        return 'Notification';
      case PermissionType.accessNotificationPolicy:
        return 'Access Notification Policy';
      case PermissionType.manageExternalStorage:
        return 'Manage External Storage';
      case PermissionType.systemAlertWindow:
        return 'System Alert Window';
      case PermissionType.requestInstallPackages:
        return 'Request Install Packages';
      case PermissionType.appTrackingTransparency:
        return 'App Tracking Transparency';
      case PermissionType.criticalAlerts:
        return 'Critical Alerts';
      case PermissionType.nearbyWifiDevices:
        return 'Nearby Wifi Devices';
      case PermissionType.scheduleExactAlarm:
        return 'Schedule Exact Alarm';
      case PermissionType.assistant:
        return 'Assistant';
      case PermissionType.backgroundRefresh:
        return 'Background Refresh';
    }
  }

  String get description {
    switch (this) {
      case PermissionType.camera:
        return 'Chụp ảnh và quét mã QR';
      case PermissionType.storage:
        return 'Truy cập và lưu trữ file';
      case PermissionType.location:
        return 'Xác định vị trí';
      case PermissionType.locationAlways:
        return 'Truy cập vị trí luôn luôn';
      case PermissionType.locationWhenInUse:
        return 'Truy cập vị trí khi sử dụng';
      case PermissionType.microphone:
        return 'Ghi âm giọng nói';
      case PermissionType.bluetooth:
        return 'Kết nối Bluetooth';
      case PermissionType.bluetoothScan:
        return 'Quét thiết bị Bluetooth';
      case PermissionType.bluetoothAdvertise:
        return 'Quảng bá Bluetooth';
      case PermissionType.bluetoothConnect:
        return 'Kết nối thiết bị Bluetooth';
      case PermissionType.contacts:
        return 'Truy cập danh bạ';
      case PermissionType.phone:
        return 'Truy cập thông tin điện thoại';
      case PermissionType.sms:
        return 'Gửi và nhận tin nhắn SMS';
      case PermissionType.calendar:
        return 'Truy cập lịch';
      case PermissionType.calendarWriteOnly:
        return 'Ghi lịch sự kiện';
      case PermissionType.calendarFullAccess:
        return 'Truy cập đầy đủ lịch';
      case PermissionType.photos:
        return 'Truy cập ảnh';
      case PermissionType.photosAddOnly:
        return 'Chỉ thêm ảnh';
      case PermissionType.mediaLibrary:
        return 'Truy cập thư viện media';
      case PermissionType.videos:
        return 'Truy cập video';
      case PermissionType.audio:
        return 'Truy cập audio';
      case PermissionType.reminders:
        return 'Quản lý nhắc nhở';
      case PermissionType.speech:
        return 'Nhận dạng giọng nói';
      case PermissionType.sensors:
        return 'Truy cập cảm biến';
      case PermissionType.sensorsAlways:
        return 'Cảm biến luôn hoạt động';
      case PermissionType.activityRecognition:
        return 'Nhận diện hoạt động';
      case PermissionType.accessMediaLocation:
        return 'Truy cập vị trí media';
      case PermissionType.ignoreBatteryOptimizations:
        return 'Bỏ qua tối ưu hóa pin';
      case PermissionType.notification:
        return 'Gửi thông báo';
      case PermissionType.accessNotificationPolicy:
        return 'Chính sách thông báo';
      case PermissionType.manageExternalStorage:
        return 'Quản lý bộ nhớ ngoài';
      case PermissionType.systemAlertWindow:
        return 'Hiển thị cửa sổ hệ thống';
      case PermissionType.requestInstallPackages:
        return 'Cài đặt ứng dụng';
      case PermissionType.appTrackingTransparency:
        return 'Theo dõi ứng dụng';
      case PermissionType.criticalAlerts:
        return 'Cảnh báo quan trọng';
      case PermissionType.nearbyWifiDevices:
        return 'Thiết bị Wifi gần';
      case PermissionType.scheduleExactAlarm:
        return 'Đặt báo chính xác';
      case PermissionType.assistant:
        return 'Trợ lý ảo';
      case PermissionType.backgroundRefresh:
        return 'Làm mới nền';
    }
  }

  Permission get permission {
    switch (this) {
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.location:
        return Permission.location;
      case PermissionType.locationAlways:
        return Permission.locationAlways;
      case PermissionType.locationWhenInUse:
        return Permission.locationWhenInUse;
      case PermissionType.microphone:
        return Permission.microphone;
      case PermissionType.bluetooth:
        return Permission.bluetooth;
      case PermissionType.bluetoothScan:
        return Permission.bluetoothScan;
      case PermissionType.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case PermissionType.bluetoothConnect:
        return Permission.bluetoothConnect;
      case PermissionType.contacts:
        return Permission.contacts;
      case PermissionType.phone:
        return Permission.phone;
      case PermissionType.sms:
        return Permission.sms;
      case PermissionType.calendar:
        return Permission.calendar;
      case PermissionType.calendarWriteOnly:
        return Permission.calendarWriteOnly;
      case PermissionType.calendarFullAccess:
        return Permission.calendarFullAccess;
      case PermissionType.photos:
        return Permission.photos;
      case PermissionType.photosAddOnly:
        return Permission.photosAddOnly;
      case PermissionType.mediaLibrary:
        return Permission.mediaLibrary;
      case PermissionType.videos:
        return Permission.videos;
      case PermissionType.audio:
        return Permission.audio;
      case PermissionType.reminders:
        return Permission.reminders;
      case PermissionType.speech:
        return Permission.speech;
      case PermissionType.sensors:
        return Permission.sensors;
      case PermissionType.sensorsAlways:
        return Permission.sensorsAlways;
      case PermissionType.activityRecognition:
        return Permission.activityRecognition;
      case PermissionType.accessMediaLocation:
        return Permission.accessMediaLocation;
      case PermissionType.ignoreBatteryOptimizations:
        return Permission.ignoreBatteryOptimizations;
      case PermissionType.notification:
        return Permission.notification;
      case PermissionType.accessNotificationPolicy:
        return Permission.accessNotificationPolicy;
      case PermissionType.manageExternalStorage:
        return Permission.manageExternalStorage;
      case PermissionType.systemAlertWindow:
        return Permission.systemAlertWindow;
      case PermissionType.requestInstallPackages:
        return Permission.requestInstallPackages;
      case PermissionType.appTrackingTransparency:
        return Permission.appTrackingTransparency;
      case PermissionType.criticalAlerts:
        return Permission.criticalAlerts;
      case PermissionType.nearbyWifiDevices:
        return Permission.nearbyWifiDevices;
      case PermissionType.scheduleExactAlarm:
        return Permission.scheduleExactAlarm;
      case PermissionType.assistant:
        return Permission.assistant;
      case PermissionType.backgroundRefresh:
        return Permission.backgroundRefresh;
    }
  }

  IconData get icon {
    switch (this) {
      case PermissionType.camera:
        return Icons.camera_alt;
      case PermissionType.storage:
        return Icons.folder;
      case PermissionType.location:
      case PermissionType.locationAlways:
      case PermissionType.locationWhenInUse:
        return Icons.location_on;
      case PermissionType.microphone:
        return Icons.mic;
      case PermissionType.bluetooth:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return Icons.bluetooth;
      case PermissionType.contacts:
        return Icons.contacts;
      case PermissionType.phone:
        return Icons.phone;
      case PermissionType.sms:
        return Icons.sms;
      case PermissionType.calendar:
      case PermissionType.calendarWriteOnly:
      case PermissionType.calendarFullAccess:
        return Icons.calendar_month;
      case PermissionType.photos:
      case PermissionType.photosAddOnly:
        return Icons.photo;
      case PermissionType.mediaLibrary:
        return Icons.library_music;
      case PermissionType.videos:
        return Icons.videocam;
      case PermissionType.audio:
        return Icons.audiotrack;
      case PermissionType.reminders:
        return Icons.notifications_active;
      case PermissionType.speech:
        return Icons.record_voice_over;
      case PermissionType.sensors:
      case PermissionType.sensorsAlways:
        return Icons.sensors;
      case PermissionType.activityRecognition:
        return Icons.directions_run;
      case PermissionType.accessMediaLocation:
        return Icons.location_searching;
      case PermissionType.ignoreBatteryOptimizations:
        return Icons.battery_charging_full;
      case PermissionType.notification:
        return Icons.notifications;
      case PermissionType.accessNotificationPolicy:
        return Icons.policy;
      case PermissionType.manageExternalStorage:
        return Icons.storage;
      case PermissionType.systemAlertWindow:
        return Icons.window;
      case PermissionType.requestInstallPackages:
        return Icons.install_desktop;
      case PermissionType.appTrackingTransparency:
        return Icons.track_changes;
      case PermissionType.criticalAlerts:
        return Icons.warning_amber;
      case PermissionType.nearbyWifiDevices:
        return Icons.wifi;
      case PermissionType.scheduleExactAlarm:
        return Icons.alarm;
      case PermissionType.assistant:
        return Icons.assistant;
      case PermissionType.backgroundRefresh:
        return Icons.refresh;
    }
  }

  Color get color {
    switch (this) {
      case PermissionType.camera:
        return Colors.red;
      case PermissionType.storage:
        return Colors.amber;
      case PermissionType.location:
      case PermissionType.locationAlways:
      case PermissionType.locationWhenInUse:
        return Colors.green;
      case PermissionType.microphone:
        return Colors.blue;
      case PermissionType.bluetooth:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return Colors.indigo;
      case PermissionType.contacts:
        return Colors.purple;
      case PermissionType.phone:
        return Colors.teal;
      case PermissionType.sms:
        return Colors.orange;
      case PermissionType.calendar:
      case PermissionType.calendarWriteOnly:
      case PermissionType.calendarFullAccess:
        return Colors.pink;
      case PermissionType.photos:
      case PermissionType.photosAddOnly:
        return Colors.deepOrange;
      case PermissionType.mediaLibrary:
        return Colors.deepPurple;
      case PermissionType.videos:
        return Colors.redAccent;
      case PermissionType.audio:
        return Colors.cyan;
      case PermissionType.reminders:
        return Colors.lime;
      case PermissionType.speech:
        return Colors.lightBlue;
      case PermissionType.sensors:
      case PermissionType.sensorsAlways:
        return Colors.brown;
      case PermissionType.activityRecognition:
        return Colors.blueGrey;
      case PermissionType.accessMediaLocation:
        return Colors.lightGreen;
      case PermissionType.ignoreBatteryOptimizations:
        return Colors.greenAccent;
      case PermissionType.notification:
        return Colors.red.shade300;
      case PermissionType.accessNotificationPolicy:
        return Colors.blue.shade700;
      case PermissionType.manageExternalStorage:
        return Colors.grey;
      case PermissionType.systemAlertWindow:
        return Colors.amber.shade700;
      case PermissionType.requestInstallPackages:
        return Colors.blue.shade900;
      case PermissionType.appTrackingTransparency:
        return Colors.cyan.shade700;
      case PermissionType.criticalAlerts:
        return Colors.red.shade900;
      case PermissionType.nearbyWifiDevices:
        return Colors.blue.shade300;
      case PermissionType.scheduleExactAlarm:
        return Colors.amber.shade900;
      case PermissionType.assistant:
        return Colors.purple.shade300;
      case PermissionType.backgroundRefresh:
        return Colors.teal.shade300;
    }
  }
}
