import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/network/network_bloc.dart';
import '../../widgets/no_internet_widget.dart';
import '../../widgets/weak_network_banner.dart';

/// Widget wrapper tự động xử lý các trạng thái mạng.
///
/// - **Mất mạng**: thay thế toàn bộ [child] bằng [NoInternetWidget].
/// - **Mạng yếu (2G/E)**: hiển thị [WeakNetworkBanner] ở trên cùng,
///   giữ nguyên [child] bên dưới — không cản người dùng.
/// - **Mạng tốt**: render [child] bình thường, không có gì thêm.
///
/// **Lưu ý**: Cần có [NetworkBloc] ở widget tree cha.
/// Đặt ở root trong [FlutterCoreApp] hoặc wrap từng screen tùy nhu cầu.
///
/// ```dart
/// // Wrap toàn bộ app (đặt trong FlutterCoreApp):
/// BlocProvider.value(
///   value: getIt<NetworkBloc>(),
///   child: NetworkAwareWidget(child: router),
/// )
///
/// // Chỉ wrap 1 screen cụ thể:
/// NetworkAwareWidget(
///   onRetry: () => bloc.add(FetchEvent()),
///   child: HomeScreen(),
/// )
/// ```
class NetworkAwareWidget extends StatelessWidget {
  final Widget child;

  /// Callback khi nhấn "Thử lại" trên NoInternetWidget.
  final VoidCallback? onRetry;

  /// Custom widget thay thế NoInternetWidget khi offline.
  final Widget? offlineWidget;

  /// Nếu `true`, sẽ hiển thị NoInternetWidget khi offline.
  /// Nếu `false`, chỉ show WeakNetworkBanner — child vẫn hiển thị.
  /// Mặc định: `true`.
  final bool blockOnOffline;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.onRetry,
    this.offlineWidget,
    this.blockOnOffline = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType ||
          (prev is NetworkConnected &&
              curr is NetworkConnected &&
              prev.isWeak != curr.isWeak),
      builder: (context, state) {
        // ── Offline ─────────────────────────────────────────────────
        if (state is NetworkDisconnected && blockOnOffline) {
          return offlineWidget ??
              NoInternetWidget(onRetry: onRetry);
        }

        // ── Weak network + Connected ─────────────────────────────────
        final isWeak =
            state is NetworkConnected && state.isWeak;
        final latency =
            state is NetworkConnected ? state.latencyMs : null;

        return Column(
          children: [
            WeakNetworkBanner(
              isVisible: isWeak,
              latencyMs: latency,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
