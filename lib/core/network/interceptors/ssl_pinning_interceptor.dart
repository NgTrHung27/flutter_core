import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../../api/api_url.dart';
import '../../utils/logger.dart';

class SslPinningInterceptor extends Interceptor {
  final String secureDomain = ApiUrl.domain;

  // Nhận danh sách mã Pin từ Injector truyền vào
  final List<String> allowedFingerprints;

  SslPinningInterceptor({required this.allowedFingerprints});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Nếu không phải domain an toàn, cho phép request
    if (!options.uri.host.contains(secureDomain)) {
      return super.onRequest(options, handler);
    }
    // Kiểm tra chứng chỉ SSL
    try {
      final List<String> cleanFingerprints = allowedFingerprints
          .map((e) => e.replaceAll(':', ' '))
          .toList();

      final String checkResult = await HttpCertificatePinning.check(
        serverURL: 'https://${ApiUrl.domain}',
        sha: SHA.SHA256,
        allowedSHAFingerprints: cleanFingerprints,
        timeout: 50,
      );

      if (checkResult.contains("CONNECTION_SECURE")) {
        super.onRequest(options, handler);
      }
    } catch (e) {
      logger.e('🚨 NATIVE SSL PINNING ERROR: $e');
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: "CẢNH BÁO: Kết nối bị chặn do sai chứng chỉ SSL!",
        ),
      );
    }
  }
}
