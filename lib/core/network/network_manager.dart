import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/logger.dart';
import 'network_status.dart';

/// Singleton quản lý toàn bộ trạng thái mạng của ứng dụng.
///
/// Kết hợp:
/// - [Connectivity] (connectivity_plus) để nhận platform events ngay lập tức
///   khi Wifi bật/tắt, chuyển từ Wifi sang 4G, v.v.
/// - [InternetConnectionChecker] để xác nhận thực sự có internet và đo latency.
///
/// Sử dụng:
/// ```dart
/// final manager = NetworkManager.instance;
/// manager.networkStatusStream.listen((status) { ... });
/// print(manager.currentStatus.quality);
/// ```
class NetworkManager {
  NetworkManager._();

  static final NetworkManager instance = NetworkManager._();

  // ─── Dependencies ─────────────────────────────────────────────────────────
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 4),
    checkInterval: const Duration(seconds: 5),
  );

  // ─── Internal state ────────────────────────────────────────────────────────
  final _statusController =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<InternetConnectionStatus>? _checkerSub;

  NetworkStatus _currentStatus = const NetworkStatus.offline();
  bool _initialized = false;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Stream phát [NetworkStatus] mỗi khi trạng thái mạng thay đổi.
  Stream<NetworkStatus> get networkStatusStream => _statusController.stream;

  /// Trạng thái mạng hiện tại (snapshot cuối cùng).
  NetworkStatus get currentStatus => _currentStatus;

  /// Có kết nối internet không?
  bool get isConnected => _currentStatus.isConnected;

  /// Chất lượng kết nối hiện tại.
  NetworkQuality get quality => _currentStatus.quality;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Khởi tạo manager và bắt đầu lắng nghe. Gọi trong [configureDepedencies].
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Lấy trạng thái hiện tại ngay khi khởi động
    await _refreshStatus();

    // 2. Lắng nghe platform connectivity events (ngay lập tức khi Wifi on/off)
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (e) => logger.e('[NetworkManager] Connectivity error: $e'),
    );

    // 3. Lắng nghe InternetConnectionChecker (ping định kỳ để xác nhận)
    _checkerSub = _connectionChecker.onStatusChange.listen(
      _onCheckerStatusChanged,
      onError: (e) => logger.e('[NetworkManager] Checker error: $e'),
    );

    logger.i('[NetworkManager] Initialized. Status: $_currentStatus');
  }

  /// Huỷ subscriptions. Gọi khi app dispose (optional).
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _checkerSub?.cancel();
    await _statusController.close();
    _initialized = false;
  }

  // ─── Private handlers ──────────────────────────────────────────────────────

  /// Platform event: Wifi/Mobile/None thay đổi.
  Future<void> _onConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    final type = _connectivityTypeLabel(results);
    logger.d('[NetworkManager] Connectivity changed → $type');

    if (results.contains(ConnectivityResult.none)) {
      _emit(const NetworkStatus.offline());
    } else {
      // Platform says connected — confirm với actual internet check + latency
      await _refreshStatus(connectionType: type);
    }
  }

  /// InternetConnectionChecker ping result.
  Future<void> _onCheckerStatusChanged(
    InternetConnectionStatus status,
  ) async {
    logger.d('[NetworkManager] Checker status → $status');

    if (status == InternetConnectionStatus.disconnected) {
      _emit(const NetworkStatus.offline());
    } else {
      await _refreshStatus();
    }
  }

  /// Đo latency thực tế và emit NetworkStatus mới.
  Future<void> _refreshStatus({String? connectionType}) async {
    try {
      final results = await _connectivity.checkConnectivity();
      final type = connectionType ?? _connectivityTypeLabel(results);

      if (results.contains(ConnectivityResult.none)) {
        _emit(const NetworkStatus.offline());
        return;
      }

      // Xác nhận internet thực sự và đo latency
      final latency = await _measureLatency();

      if (latency == null) {
        // Có kết nối platform nhưng không ping được → coi như offline
        _emit(const NetworkStatus.offline());
      } else {
        _emit(
          NetworkStatus.fromLatency(
            latencyMs: latency,
            connectionType: type,
          ),
        );
      }
    } catch (e) {
      logger.e('[NetworkManager] _refreshStatus error: $e');
      _emit(const NetworkStatus.offline());
    }
  }

  /// Ping và trả về latency (ms). null nếu không ping được.
  Future<int?> _measureLatency() async {
    try {
      final stopwatch = Stopwatch()..start();
      final hasConnection = await _connectionChecker.hasConnection;
      stopwatch.stop();

      if (!hasConnection) return null;
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  void _emit(NetworkStatus status) {
    if (_currentStatus == status) return; // Bỏ qua nếu không thay đổi
    _currentStatus = status;
    _statusController.add(status);
    logger.i('[NetworkManager] Status changed → $status');
  }

  static String _connectivityTypeLabel(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return 'wifi';
    if (results.contains(ConnectivityResult.mobile)) return 'mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'vpn';
    return 'none';
  }
}
