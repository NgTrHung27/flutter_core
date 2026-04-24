import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;
import 'performance_monitor.dart';

class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final PerformanceMonitor _monitor = PerformanceMonitor();
  Duration _lastFrameTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  @override
  void didUpdateWidget(PerformanceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _startMonitoring();
    } else if (!widget.enabled && oldWidget.enabled) {
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    _monitor.startMonitoring();
    _ticker.start();
  }

  void _stopMonitoring() {
    _ticker.stop();
    _monitor.stopMonitoring();
  }

  void _onTick(Duration elapsed) {
    final frameDuration = elapsed - _lastFrameTime;
    _lastFrameTime = elapsed;

    if (frameDuration.inMilliseconds > 0) {
      final fps = 1000 / frameDuration.inMilliseconds;
      _monitor.recordFrame(fps.clamp(0, 240));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StreamBuilder<PerformanceSnapshot>(
              stream: _monitor.snapshotStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? PerformanceSnapshot.empty();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FpsIndicator(fps: data.currentFps),
                      const SizedBox(width: 16),
                      _MetricLabel(
                        label: 'AVG',
                        value: data.averageFps.toStringAsFixed(1),
                      ),
                      const SizedBox(width: 8),
                      _MetricLabel(
                        label: 'MIN',
                        value: data.minFps.toStringAsFixed(1),
                        color: data.minFps < 30 ? Colors.red : null,
                      ),
                      const SizedBox(width: 8),
                      _MetricLabel(
                        label: 'MAX',
                        value: data.maxFps.toStringAsFixed(1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FpsIndicator extends StatelessWidget {
  final double fps;

  const _FpsIndicator({required this.fps});

  Color get _color {
    if (fps >= 50) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${fps.toStringAsFixed(0)} FPS',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MetricLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricLabel({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class FpsChart extends StatelessWidget {
  final PerformanceMonitor monitor;
  final double height;
  final double width;

  const FpsChart({
    super.key,
    required this.monitor,
    this.height = 100,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: StreamBuilder<List<PerformanceMetric>>(
          stream: monitor.metricsStream,
          builder: (context, snapshot) {
            final metrics = snapshot.data ?? [];
            final fpsMetrics = metrics
                .where((m) => m.type == PerformanceMetricType.fps)
                .toList();

            if (fpsMetrics.isEmpty) {
              return const Center(
                child: Text(
                  'No data',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return CustomPaint(
              painter: _FpsChartPainter(fpsMetrics),
              size: Size(width, height),
            );
          },
        ),
      ),
    );
  }
}

class _FpsChartPainter extends CustomPainter {
  final List<PerformanceMetric> metrics;

  _FpsChartPainter(this.metrics);

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    // Draw grid lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw 60 FPS reference line
    final referenceY = size.height - (60 / 120 * size.height);
    paint.color = Colors.orange.withValues(alpha: 0.5);
    canvas.drawLine(
      Offset(0, referenceY),
      Offset(size.width, referenceY),
      paint,
    );

    // Draw FPS line
    paint.color = Colors.green;
    final maxFps = metrics.map((m) => m.value).reduce(math.max);
    final minFps = metrics.map((m) => m.value).reduce(math.min);
    final range = (maxFps - minFps).clamp(1.0, 120);

    for (var i = 0; i < metrics.length; i++) {
      final x = (i / (metrics.length - 1)) * size.width;
      final normalizedValue = (metrics[i].value - minFps) / range;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FpsChartPainter oldDelegate) {
    return metrics != oldDelegate.metrics;
  }
}
