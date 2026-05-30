import 'package:equatable/equatable.dart';

/// Phân loại chất lượng kết nối dựa trên latency đo được.
enum NetworkQuality {
  /// Kết nối tốt — latency < 300ms
  fast,

  /// Kết nối chậm — latency 300–1500ms (3G trở xuống)
  slow,

  /// Kết nối cực yếu — latency > 1500ms hoặc sắp timeout (2G/E/GPRS)
  weak,

  /// Không có kết nối
  offline,
}

extension NetworkQualityX on NetworkQuality {
  bool get isUsable => this != NetworkQuality.offline;
  bool get isWeak => this == NetworkQuality.weak;
  bool get isFast => this == NetworkQuality.fast;

  String get label {
    switch (this) {
      case NetworkQuality.fast:
        return 'Kết nối tốt';
      case NetworkQuality.slow:
        return 'Kết nối chậm';
      case NetworkQuality.weak:
        return 'Mạng rất yếu (2G/E)';
      case NetworkQuality.offline:
        return 'Không có mạng';
    }
  }

  /// Dio timeout nên dùng theo chất lượng mạng.
  Duration get recommendedTimeout {
    switch (this) {
      case NetworkQuality.fast:
        return const Duration(seconds: 15);
      case NetworkQuality.slow:
        return const Duration(seconds: 30);
      case NetworkQuality.weak:
        return const Duration(seconds: 60);
      case NetworkQuality.offline:
        return const Duration(seconds: 5);
    }
  }
}

/// Snapshot của trạng thái mạng tại một thời điểm.
class NetworkStatus extends Equatable {
  final bool isConnected;
  final NetworkQuality quality;

  /// Latency đo được (ms). null nếu offline hoặc chưa đo.
  final int? latencyMs;

  /// Loại kết nối platform (wifi / mobile / none…).
  final String? connectionType;

  const NetworkStatus({
    required this.isConnected,
    required this.quality,
    this.latencyMs,
    this.connectionType,
  });

  const NetworkStatus.offline()
      : isConnected = false,
        quality = NetworkQuality.offline,
        latencyMs = null,
        connectionType = null;

  factory NetworkStatus.fromLatency({
    required int latencyMs,
    String? connectionType,
  }) {
    final NetworkQuality quality;
    if (latencyMs < 300) {
      quality = NetworkQuality.fast;
    } else if (latencyMs < 1500) {
      quality = NetworkQuality.slow;
    } else {
      quality = NetworkQuality.weak;
    }

    return NetworkStatus(
      isConnected: true,
      quality: quality,
      latencyMs: latencyMs,
      connectionType: connectionType,
    );
  }

  @override
  List<Object?> get props => [isConnected, quality, latencyMs, connectionType];

  @override
  String toString() =>
      'NetworkStatus(connected: $isConnected, quality: ${quality.name}, latency: ${latencyMs}ms, type: $connectionType)';
}
