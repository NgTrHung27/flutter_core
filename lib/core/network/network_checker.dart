import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';
import 'network_manager.dart';
import 'network_status.dart';

/// Type alias cho function trả về Either thông qua network.
typedef EitherNetwork<T> = Future<Either<Failure, T>> Function();

/// Service wrapper để check network trước khi thực hiện một operation.
///
/// Tích hợp trực tiếp với [NetworkManager] thay vì phụ thuộc
/// vào [InternetConnectionChecker] trực tiếp.
///
/// Ví dụ trong Repository:
/// ```dart
/// return _networkInfo.guardNetwork(
///   connected: () => _remoteSource.fetchData(),
///   notConnected: () async => Left(const NetworkFailure()),
///   weakNetwork: (latency) async => Left(WeakNetworkFailure(latency)),
/// );
/// ```
class NetworkInfo {
  final NetworkManager _manager;

  const NetworkInfo(this._manager);

  // ─── Basic check ───────────────────────────────────────────────────────────

  /// Trả về `true` nếu hiện tại có internet (từ snapshot cuối của Manager).
  bool get isConnected => _manager.isConnected;

  /// Chất lượng kết nối hiện tại.
  NetworkQuality get quality => _manager.quality;

  /// Snapshot trạng thái mạng đầy đủ.
  NetworkStatus get currentStatus => _manager.currentStatus;

  /// Stream để listen trạng thái thay đổi.
  Stream<NetworkStatus> get statusStream => _manager.networkStatusStream;

  // ─── Guard helpers ─────────────────────────────────────────────────────────

  /// Chạy [connected] nếu có mạng, [notConnected] nếu không có mạng.
  ///
  /// [weakNetwork] optional — được gọi thay vì [connected] khi mạng yếu (2G/E).
  /// Nếu không truyền [weakNetwork], mạng yếu vẫn chạy [connected] bình thường.
  Future<Either<Failure, T>> guardNetwork<T>({
    required EitherNetwork<T> connected,
    required EitherNetwork<T> notConnected,
    Future<Either<Failure, T>> Function(int latencyMs)? weakNetwork,
  }) async {
    final status = _manager.currentStatus;

    if (!status.isConnected) {
      return notConnected.call();
    }

    if (weakNetwork != null && status.quality == NetworkQuality.weak) {
      return weakNetwork(status.latencyMs ?? 9999);
    }

    return connected.call();
  }

  /// Backward-compatible overload — giống API cũ [check].
  Future<Either<Failure, T>> check<T>({
    required EitherNetwork<T> connected,
    required EitherNetwork<T> notConnected,
  }) {
    return guardNetwork(connected: connected, notConnected: notConnected);
  }
}
