import 'package:dio/dio.dart';

import '../network/network_manager.dart';
import '../network/network_status.dart';
import '../utils/logger.dart';
import 'api_exception.dart';

/// Dio interceptor nâng cấp:
/// 1. Log mọi request/response/error.
/// 2. Check [NetworkManager] **trước khi gửi request** — nếu offline,
///    throw [NetworkApiException] ngay mà không tốn connection timeout.
/// 3. Nếu mạng yếu (2G/E), tự động tăng timeout cho request đó
///    và log cảnh báo.
class ApiInterceptor extends Interceptor {
  ApiInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final status = NetworkManager.instance.currentStatus;

    // ── Offline guard ────────────────────────────────────────────────
    if (!status.isConnected) {
      logger.w(
        '[ApiInterceptor] Blocked request (offline): ${options.method} ${options.path}',
      );
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkApiException('Không có kết nối mạng'),
          type: DioExceptionType.connectionError,
        ),
      );
    }

    // ── Weak network — tăng timeout ──────────────────────────────────
    if (status.quality == NetworkQuality.weak) {
      final timeout = status.quality.recommendedTimeout;
      options.connectTimeout = timeout;
      options.receiveTimeout = timeout;
      options.sendTimeout = timeout;
      logger.w(
        '[ApiInterceptor] Weak network (${status.latencyMs}ms) — '
        'timeout extended to ${timeout.inSeconds}s '
        'for ${options.method} ${options.path}',
      );
    }

    logger.i(
      '[ApiInterceptor] REQUEST[${options.method}] → ${options.path}'
      '${status.latencyMs != null ? " (latency: ${status.latencyMs}ms)" : ""}',
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
      '[ApiInterceptor] RESPONSE[${response.statusCode}] ← ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = NetworkManager.instance.currentStatus;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      // Timeout xảy ra khi mạng yếu — log thêm context
      logger.e(
        '[ApiInterceptor] TIMEOUT on ${err.requestOptions.path} '
        '— network quality: ${status.quality.name}, latency: ${status.latencyMs}ms',
      );
    } else if (err.type == DioExceptionType.connectionError) {
      logger.e(
        '[ApiInterceptor] CONNECTION ERROR on ${err.requestOptions.path}: ${err.message}',
      );
    } else {
      logger.e(
        '[ApiInterceptor] ERROR[${err.response?.statusCode}] ← ${err.requestOptions.path}: ${err.message}',
      );
    }

    // Detect SSL pinning violation
    if (err.type == DioExceptionType.connectionError &&
        err.error.toString().contains('CẢNH BÁO')) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: Exception('Kết nối không an toàn. Vui lòng kiểm tra lại mạng!'),
          type: DioExceptionType.connectionError,
        ),
      );
    }

    super.onError(err, handler);
  }
}
