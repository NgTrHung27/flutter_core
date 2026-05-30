part of 'network_bloc.dart';

sealed class NetworkState extends Equatable {
  const NetworkState();
}

/// Trạng thái khởi tạo — chưa biết trạng thái mạng.
class NetworkInitial extends NetworkState {
  const NetworkInitial();

  @override
  List<Object?> get props => [];
}

/// Có kết nối internet, kèm thông tin chất lượng.
class NetworkConnected extends NetworkState {
  final NetworkQuality quality;
  final int? latencyMs;
  final String? connectionType;

  const NetworkConnected({
    required this.quality,
    this.latencyMs,
    this.connectionType,
  });

  /// Mạng yếu (2G/E/GPRS) — vẫn connected nhưng cần cảnh báo UI.
  bool get isWeak => quality == NetworkQuality.weak;

  /// Mạng bình thường hoặc tốt.
  bool get isHealthy => !isWeak;

  @override
  List<Object?> get props => [quality, latencyMs, connectionType];

  @override
  String toString() =>
      'NetworkConnected(quality: ${quality.name}, latency: ${latencyMs}ms, type: $connectionType)';
}

/// Không có kết nối internet.
class NetworkDisconnected extends NetworkState {
  const NetworkDisconnected();

  @override
  List<Object?> get props => [];
}
