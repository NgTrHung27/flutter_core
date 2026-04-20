import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/permission_util.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    await PermissionUtil.checkAllPermissions();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onTogglePermission(PermissionType type, bool value) async {
    if (value) {
      final result = await PermissionUtil.requestByType(type);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Đã cấp quyền ${type.displayName}'
                  : 'Yêu cầu quyền ${type.displayName} bị từ chối',
            ),
            backgroundColor: result ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      final status = await type.permission.status;
      if (status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Để tắt quyền ${type.displayName}, vui lòng vào Cài đặt > Ứng dụng > Flutter Core > Quyền',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Mở Settings',
              textColor: Colors.white,
              onPressed: _openSettings,
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openSettings() async {
    await PermissionUtil.openAppSettings();
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Đã cấp';
      case PermissionStatus.denied:
        return 'Bị từ chối';
      case PermissionStatus.permanentlyDenied:
        return 'Từ chối vĩnh viễn';
      case PermissionStatus.restricted:
        return 'Bị hạn chế';
      case PermissionStatus.limited:
        return 'Hạn chế';
      case PermissionStatus.provisional:
        return 'Tạm thời';
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.grey;
      case PermissionStatus.limited:
        return Colors.blue;
      case PermissionStatus.provisional:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = PermissionType.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Quyền (42)'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Mở cài đặt',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Lưu ý',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Gạt toggle sang phải để xin cấp quyền\n'
                  '• Gạt toggle sang trái để tắt quyền (cần vào Settings)\n'
                  '• Quyền bị từ chối vĩnh viễn sẽ không hiện popup xin quyền',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final type = permissions[index];
                return _buildPermissionCard(type);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(PermissionType type) {
    return FutureBuilder<PermissionStatus>(
      future: type.permission.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? PermissionStatus.denied;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(type.icon, color: type.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: status.isGranted,
                  onChanged: (value) => _onTogglePermission(type, value),
                  activeThumbColor: type.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
