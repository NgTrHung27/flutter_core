package com.example.flutter_core

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Vibrator
import android.os.VibrationEffect
import androidx.annotation.NonNull

class MainActivity : FlutterActivity(){
    // 1. Đặt tên Channel (Phải duy nhất)
    private val CHANNEL = "com.example.flutter_core/android_channel"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine)
        
        // 2. Lắng nghe tin nhắn từ Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
            call, result ->
            // 3. Kiểm tra xem Dart đang muốn gọi hàm gì
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "getDeviceInfo") {
                val deviceInfo = getDeviceInfo()
                result.success(deviceInfo)
            } else if (call.method == "vibrate") {
                vibrate(call.argument<Int>("duration") ?: 500)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    // Hàm Native Android thuần để lấy Pin
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }

    private fun getDeviceInfo(): Map<String, String> {
        val deviceInfo = HashMap<String, String>()
        deviceInfo["model"] = Build.MODEL
        deviceInfo["brand"] = Build.BRAND
        deviceInfo["version"] = Build.VERSION.RELEASE
        deviceInfo["sdk"] = Build.VERSION.SDK_INT.toString()
        return deviceInfo
    }

    private fun vibrate(duration: Int) {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(duration.toLong(), VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            vibrator.vibrate(duration.toLong())
        }
    }
}
