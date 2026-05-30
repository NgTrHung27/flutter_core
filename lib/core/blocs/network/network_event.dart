part of 'network_bloc.dart';

abstract class NetworkEvent {}

/// Kiểm tra trạng thái mạng ngay lập tức (on-demand).
class NetworkCheckRequested extends NetworkEvent {}

/// Internal event — phát ra khi NetworkManager stream có update.
class _NetworkStatusChanged extends NetworkEvent {
  final NetworkStatus status;
  _NetworkStatusChanged(this.status);
}
