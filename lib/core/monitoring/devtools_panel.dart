import 'package:flutter/material.dart';
import 'performance_monitor.dart';

class DevToolsPanel extends StatefulWidget {
  final PerformanceMonitor monitor;
  final VoidCallback? onClose;

  const DevToolsPanel({
    super.key,
    required this.monitor,
    this.onClose,
  });

  @override
  State<DevToolsPanel> createState() => _DevToolsPanelState();
}

class _DevToolsPanelState extends State<DevToolsPanel> {
  bool _isMinimized = false;
  bool _isPinned = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (!_isMinimized) ...[
            _buildPerformanceMetrics(),
            const Divider(color: Colors.white24, height: 1),
            _buildFpsChart(),
            const Divider(color: Colors.white24, height: 1),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          const Text(
            'DevTools',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 16,
              color: _isPinned ? Colors.blue : Colors.white54,
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Pin panel',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isMinimized ? Icons.add : Icons.remove,
              size: 16,
              color: Colors.white54,
            ),
            onPressed: () => setState(() => _isMinimized = !_isMinimized),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: _isMinimized ? 'Expand' : 'Minimize',
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white54),
              onPressed: widget.onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Close',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return StreamBuilder<PerformanceSnapshot>(
      stream: widget.monitor.snapshotStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? PerformanceSnapshot.empty();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'FPS',
                      value: data.currentFps.toStringAsFixed(0),
                      color: _getFpsColor(data.currentFps),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: 'AVG',
                      value: data.averageFps.toStringAsFixed(1),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'MIN',
                      value: data.minFps.toStringAsFixed(0),
                      color: data.minFps < 30 ? Colors.red : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: 'MAX',
                      value: data.maxFps.toStringAsFixed(0),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _MetricCard(
                label: 'Frames',
                value: '${data.frameCount}',
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFpsChart() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FPS History',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<PerformanceMetric>>(
            stream: widget.monitor.metricsStream,
            builder: (context, snapshot) {
              final metrics = snapshot.data ?? [];
              final fpsMetrics = metrics
                  .where((m) => m.type == PerformanceMetricType.fps)
                  .toList();

              return Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: fpsMetrics.isEmpty
                    ? const Center(
                        child: Text(
                          'No data',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      )
                    : CustomPaint(
                        painter: _DevToolsFpsChartPainter(fpsMetrics),
                        size: const Size(double.infinity, 80),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.monitor.isMonitoring) {
                  widget.monitor.stopMonitoring();
                } else {
                  widget.monitor.startMonitoring();
                }
                setState(() {});
              },
              icon: Icon(
                widget.monitor.isMonitoring ? Icons.stop : Icons.play_arrow,
                size: 16,
              ),
              label: Text(
                widget.monitor.isMonitoring ? 'Stop' : 'Start',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.monitor.isMonitoring
                    ? Colors.red
                    : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => widget.monitor.clearHistory(),
            icon: const Icon(Icons.refresh, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
            ),
            tooltip: 'Clear history',
          ),
        ],
      ),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 50) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevToolsFpsChartPainter extends CustomPainter {
  final List<PerformanceMetric> metrics;

  _DevToolsFpsChartPainter(this.metrics);

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 60 FPS reference line
    final referencePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final referenceY = size.height - (60 / 120 * size.height);
    canvas.drawLine(Offset(0, referenceY), Offset(size.width, referenceY), referencePaint);

    // Build path
    final path = Path();
    final maxFps = metrics.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    final minFps = metrics.map((m) => m.value).reduce((a, b) => a < b ? a : b);
    final range = (maxFps - minFps).clamp(1.0, 120.0);

    for (var i = 0; i < metrics.length; i++) {
      final x = (i / (metrics.length - 1).clamp(1, double.infinity)) * size.width;
      final normalizedValue = (metrics[i].value - minFps) / range;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    paint.color = Colors.green;
    canvas.drawPath(path, paint);

    // Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.style = PaintingStyle.fill;
    paint.color = Colors.green.withValues(alpha: 0.1);
    canvas.drawPath(fillPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DevToolsFpsChartPainter oldDelegate) {
    return metrics.length != oldDelegate.metrics.length;
  }
}
