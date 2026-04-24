import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/monitoring/devtools_panel.dart';
import '../../../core/monitoring/performance_monitor.dart';

class MonitoringDemoPage extends StatefulWidget {
  const MonitoringDemoPage({super.key});

  @override
  State<MonitoringDemoPage> createState() => _MonitoringDemoPageState();
}

class _MonitoringDemoPageState extends State<MonitoringDemoPage>
    with SingleTickerProviderStateMixin {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  bool _showPanel = true;
  Ticker? _ticker;
  bool _isSimulating = false;
  int _simulationType = 0;

  @override
  void initState() {
    super.initState();
    _monitor.startMonitoring();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _monitor.dispose();
    super.dispose();
  }

  void _startSimulation() {
    if (_isSimulating) return;

    setState(() => _isSimulating = true);

    _ticker = createTicker((elapsed) {
      // Simulate different performance scenarios
      double fps;
      switch (_simulationType) {
        case 0: // Normal
          fps = 58.0 + (elapsed.inMilliseconds % 400) / 100.0;
          break;
        case 1: // High load
          fps = 30.0 + (elapsed.inMilliseconds % 1000) / 100.0;
          break;
        case 2: // Janky
          fps = 15.0 + (elapsed.inMilliseconds % 2000) / 500.0;
          break;
        default:
          fps = 60.0;
      }

      _monitor.recordFrame(fps);
    });
    _ticker?.start();
  }

  void _stopSimulation() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    setState(() => _isSimulating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitoring Demo'),
        actions: [
          IconButton(
            icon: Icon(_showPanel ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPanel = !_showPanel),
            tooltip: _showPanel ? 'Hide Panel' : 'Show Panel',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSection(
                  'Real-time FPS Monitor',
                  'Live performance metrics displayed on screen',
                  _buildFpsDisplay(),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Simulation Controls',
                  'Simulate different performance scenarios',
                  _buildSimulationControls(),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Performance Tips',
                  'How to use the monitoring tools',
                  _buildTips(),
                ),
              ],
            ),
          ),
          if (_showPanel)
            Positioned(
              top: 16,
              right: 16,
              child: DevToolsPanel(
                monitor: _monitor,
                onClose: () => setState(() => _showPanel = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFpsDisplay() {
    return StreamBuilder<PerformanceSnapshot>(
      stream: _monitor.snapshotStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? PerformanceSnapshot.empty();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FpsBox(
                  label: 'Current',
                  value: data.currentFps,
                  color: _getFpsColor(data.currentFps),
                ),
                _FpsBox(
                  label: 'Average',
                  value: data.averageFps,
                  color: Colors.white,
                ),
                _FpsBox(
                  label: 'Min',
                  value: data.minFps,
                  color: _getFpsColor(data.minFps),
                ),
                _FpsBox(
                  label: 'Max',
                  value: data.maxFps,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (data.currentFps / 60).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(_getFpsColor(data.currentFps)),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.frameCount} frames recorded',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimulationControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select simulation type:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Normal'), icon: Icon(Icons.sentiment_satisfied)),
            ButtonSegment(value: 1, label: Text('High Load'), icon: Icon(Icons.sentiment_neutral)),
            ButtonSegment(value: 2, label: Text('Janky'), icon: Icon(Icons.sentiment_dissatisfied)),
          ],
          selected: {_simulationType},
          onSelectionChanged: (values) {
            setState(() => _simulationType = values.first);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSimulating ? null : _startSimulation,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Simulation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSimulating ? _stopSimulation : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _monitor.clearHistory(),
          icon: const Icon(Icons.refresh),
          label: const Text('Clear History'),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TipItem(
          icon: Icons.visibility,
          title: 'Enable Performance Overlay',
          description: 'Toggle the DevTools panel using the eye icon in the top right.',
        ),
        _TipItem(
          icon: Icons.speed,
          title: 'Monitor FPS',
          description: 'Green = 50+ FPS, Orange = 30-50 FPS, Red = <30 FPS.',
        ),
        _TipItem(
          icon: Icons.bug_report,
          title: 'Detect Jank',
          description: 'Look for sudden drops in FPS to identify performance issues.',
        ),
        _TipItem(
          icon: Icons.history,
          title: 'Use History',
          description: 'Clear history before each test run for accurate measurements.',
        ),
      ],
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 50) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }
}

class _FpsBox extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FpsBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Text(
            'FPS',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
