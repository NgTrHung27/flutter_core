import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../utils/logger.dart';
import '../api/api_url.dart';

/// Default Root CA fingerprint của Let's Encrypt (ISRG Root X1).
/// Sống đến năm 2035 - dùng làm backup khi Firebase lỗi.
const sslPinningRootCaBackup =
    "4E:60:2F:FB:2A:B3:D6:8F:7E:16:D7:C6:BB:62:3D:62:0C:9E:14:38:B7:13:A6:A9:5B:4B:04:D3:A8:70:4A:29";

/// Load SSL pins từ Firebase Remote Config.
/// Nếu Firebase lỗi hoặc không có config, trả về Root CA backup.
Future<List<String>> loadSslPins() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Tránh bị Firebase block do gọi quá nhiều
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.fetchAndActivate();

    // Trên Firebase, tạo key 'ssl_pins' với value là JSON array: ["MÃ_1", "MÃ_2"]
    final pinsJson = remoteConfig.getString('ssl_pins');
    if (pinsJson.isNotEmpty) {
      final parsedList = jsonDecode(pinsJson) as List<dynamic>;
      return parsedList.map((e) => e.toString()).toList();
    }
    return [sslPinningRootCaBackup];
  } catch (e) {
    logger.e(
      "⚠️ Lỗi tải Firebase Remote Config, sử dụng mã Root CA mặc định: $e",
    );
    return [sslPinningRootCaBackup];
  }
}

/// Xây dựng Dio instance với SSL Pinning đã được cấu hình.
///
/// SSL Pinning là kỹ thuật bảo mật giúp đảm bảo app chỉ giao tiếp
/// với server có chứng chỉ SSL hợp lệ, ngăn chặn tấn công MITM.
Dio buildDioWithSslPinning(List<String> sslPins) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiUrl.apiProduction,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Gắn SSL Pinning adapter vào Dio
  dio.httpClientAdapter = buildSslPinningAdapter(sslPins);

  return dio;
}

/// Xây dựng IOHttpClientAdapter với logic validate certificate.
///
/// Flow hoạt động:
/// 1. Khi server trả về chứng chỉ SSL, callback này được gọi
/// 2. Lấy certificate thực tế của server (dạng nhị phân DER)
/// 3. Băm SHA-256 để lấy fingerprint
/// 4. So sánh với danh sách pins đã load
/// 5. Cho phép hoặc reject request dựa trên kết quả
IOHttpClientAdapter buildSslPinningAdapter(List<String> sslPins) {
  return IOHttpClientAdapter(
    createHttpClient: () => HttpClient(),
    validateCertificate: (X509Certificate? cert, String host, int port) {
      // 1. Bỏ qua nếu gọi các domain bên thứ 3 (không cần pin)
      if (!host.contains(ApiUrl.domain)) return true;

      // 2. Chặn nếu rớt mạng hoặc hệ thống không cung cấp chứng chỉ
      if (cert == null) return false;

      // 3. Lấy chứng chỉ thực tế của server (dạng nhị phân DER) và băm ra SHA-256
      final serverFingerprint = sha256
          .convert(cert.der)
          .toString()
          .toUpperCase();

      // 4. Kiểm tra xem mã băm có nằm trong danh sách pins không
      final isSecure = sslPins.any((pin) {
        // Clean pin: bỏ dấu ":" và uppercase để so sánh chính xác
        final cleanPin = pin.replaceAll(':', '').toUpperCase();
        return serverFingerprint == cleanPin;
      });

      // 5. Nếu không an toàn, in log báo lỗi rõ ràng
      if (!isSecure) {
        logger.e(
          '🚨 DIO SSL PINNING ERROR: Chứng chỉ giả mạo!\n'
          'Mã Server trả về: $serverFingerprint',
        );
      }

      return isSecure;
    },
  );
}
