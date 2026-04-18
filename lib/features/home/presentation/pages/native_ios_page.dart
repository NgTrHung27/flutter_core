import 'package:flutter/material.dart';
import '../../../../core/utils/native_ios_util.dart';

class NativeIosPage extends StatefulWidget {
  const NativeIosPage({super.key});

  @override
  State<NativeIosPage> createState() => _NativeIosPageState();
}

class _NativeIosPageState extends State<NativeIosPage> {
  String _batteryLevel = 'Chưa xác định';
  Map<String, String>? _deviceInfo;
  bool _isLoadingBattery = false;
  bool _isLoadingDevice = false;

  Future<void> _getBatteryLevel() async {
    setState(() => _isLoadingBattery = true);
    final result = await NativeIosUtil.getBatteryLevel();
    setState(() {
      _batteryLevel = result;
      _isLoadingBattery = false;
    });
  }

  Future<void> _getDeviceInfo() async {
    setState(() => _isLoadingDevice = true);
    final result = await NativeIosUtil.getDeviceInfo();
    setState(() {
      _deviceInfo = result;
      _isLoadingDevice = false;
    });
  }

  Future<void> _vibrate() async {
    await NativeIosUtil.vibrate(duration: 300);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã rung thiết bị!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOS Native Method Channel'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFeatureCard(
                title: 'Trạng thái Pin',
                icon: Icons.battery_std,
                color: Colors.green,
                isLoading: _isLoadingBattery,
                content: Text(
                  _batteryLevel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _getBatteryLevel,
                buttonLabel: 'Lấy thông tin Pin',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                title: 'Thông tin Thiết bị',
                icon: Icons.phone_android,
                color: Colors.blue,
                isLoading: _isLoadingDevice,
                content: _deviceInfo == null
                    ? const Text('Chưa có thông tin')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _deviceInfo!.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '${e.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(child: Text(e.value)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                onPressed: _getDeviceInfo,
                buttonLabel: 'Lấy Info Thiết bị',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                title: 'Phản hồi Haptic (Rung)',
                icon: Icons.vibration,
                color: Colors.orange,
                content: const Text('Nhấn để rung thiết bị native'),
                onPressed: _vibrate,
                buttonLabel: 'Rung ngay!',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
    required VoidCallback onPressed,
    required String buttonLabel,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: isLoading ? const CircularProgressIndicator() : content,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
