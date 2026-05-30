import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/network_manager.dart';
import '../../network/network_status.dart';

part 'network_event.dart';
part 'network_state.dart';

/// Global BLoC theo dõi trạng thái mạng từ [NetworkManager].
///
/// Đăng ký là **lazy singleton** trong DI (không phải factory) vì toàn bộ app
/// chỉ cần một instance duy nhất.
///
/// Cách sử dụng:
/// ```dart
/// // Trong widget tree (đặt ở root, ví dụ FlutterCoreApp):
/// BlocProvider.value(value: getIt<NetworkBloc>())
///
/// // Listen state thay đổi:
/// context.watch<NetworkBloc>().state
///
/// // Trong feature BLoC — tự động handle qua NetworkInfo.guardNetwork()
/// ```
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkManager _manager;

  StreamSubscription<NetworkStatus>? _networkSub;

  NetworkBloc(this._manager) : super(const NetworkInitial()) {
    on<NetworkCheckRequested>(_onCheckRequested);
    on<_NetworkStatusChanged>(_onStatusChanged);

    // Subscribe vào stream ngay khi BLoC khởi tạo
    _networkSub = _manager.networkStatusStream.listen(
      (status) => add(_NetworkStatusChanged(status)),
    );

    // Emit trạng thái hiện tại ngay lập tức (từ snapshot cuối của manager)
    final current = _manager.currentStatus;
    if (current.isConnected || !_manager.isConnected) {
      add(_NetworkStatusChanged(current));
    }
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onCheckRequested(
    NetworkCheckRequested event,
    Emitter<NetworkState> emit,
  ) async {
    // NetworkManager tự refresh — chỉ cần emit snapshot hiện tại
    final status = _manager.currentStatus;
    emit(_mapStatusToState(status));
  }

  void _onStatusChanged(
    _NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) {
    emit(_mapStatusToState(event.status));
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  NetworkState _mapStatusToState(NetworkStatus status) {
    if (!status.isConnected) {
      return const NetworkDisconnected();
    }

    return NetworkConnected(
      quality: status.quality,
      latencyMs: status.latencyMs,
      connectionType: status.connectionType,
    );
  }

  @override
  Future<void> close() {
    _networkSub?.cancel();
    return super.close();
  }
}
