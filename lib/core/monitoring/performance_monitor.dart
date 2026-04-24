import 'dart:async';
import 'package:flutter/foundation.dart';

enum PerformanceMetricType {
  fps,
  memory,
  cpu,
  frameTime,
  renderTime,
}

class PerformanceMetric {
  final PerformanceMetricType type;
  final double value;
  final DateTime timestamp;
  final String? label;

  PerformanceMetric({
    required this.type,
    required this.value,
    required this.timestamp,
    this.label,
  });

  @override
  String toString() =>
      '${type.name}: $value at ${timestamp.toIso8601String()}';
}

class PerformanceSnapshot {
  final double currentFps;
  final double averageFps;
  final double minFps;
  final double maxFps;
  final int frameCount;
  final Duration totalFrameTime;
  final DateTime timestamp;

  PerformanceSnapshot({
    required this.currentFps,
    required this.averageFps,
    required this.minFps,
    required this.maxFps,
    required this.frameCount,
    required this.totalFrameTime,
    required this.timestamp,
  });

  factory PerformanceSnapshot.empty() => PerformanceSnapshot(
        currentFps: 0,
        averageFps: 0,
        minFps: 0,
        maxFps: 0,
        frameCount: 0,
        totalFrameTime: Duration.zero,
        timestamp: DateTime.now(),
      );

  @override
  String toString() =>
      'FPS: $currentFps (avg: $averageFps, min: $minFps, max: $maxFps)';
}

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final _metricsController = StreamController<List<PerformanceMetric>>.broadcast();
  final _snapshotController = StreamController<PerformanceSnapshot>.broadcast();

  final List<PerformanceMetric> _metrics = [];
  final List<double> _fpsHistory = [];
  final Stopwatch _frameTimer = Stopwatch()..start();

  bool _isMonitoring = false;
  int _frameCount = 0;
  Duration _totalFrameTime = Duration.zero;
  double _minFps = 60;
  double _maxFps = 0;

  Stream<List<PerformanceMetric>> get metricsStream => _metricsController.stream;
  Stream<PerformanceSnapshot> get snapshotStream => _snapshotController.stream;

  bool get isMonitoring => _isMonitoring;
  List<PerformanceMetric> get currentMetrics => List.unmodifiable(_metrics);
  PerformanceSnapshot get currentSnapshot => _calculateSnapshot();

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _metrics.clear();
    _fpsHistory.clear();
    _frameCount = 0;
    _totalFrameTime = Duration.zero;
    _minFps = 60;
    _maxFps = 0;
    _frameTimer.reset();
    _frameTimer.start();
    debugPrint('[PerformanceMonitor] Started monitoring');
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _frameTimer.stop();
    _emitSnapshot();
    debugPrint('[PerformanceMonitor] Stopped monitoring');
  }

  void recordFrame(double fps) {
    if (!_isMonitoring) return;

    _frameCount++;
    _fpsHistory.add(fps);

    if (fps < _minFps) _minFps = fps;
    if (fps > _maxFps) _maxFps = fps;

    final metric = PerformanceMetric(
      type: PerformanceMetricType.fps,
      value: fps,
      timestamp: DateTime.now(),
    );
    _metrics.add(metric);

    if (_metrics.length > 300) {
      _metrics.removeAt(0);
    }
    if (_fpsHistory.length > 300) {
      _fpsHistory.removeAt(0);
    }

    _emitMetrics();
  }

  void recordMetric(PerformanceMetricType type, double value, {String? label}) {
    if (!_isMonitoring) return;

    final metric = PerformanceMetric(
      type: type,
      value: value,
      timestamp: DateTime.now(),
      label: label,
    );
    _metrics.add(metric);

    if (_metrics.length > 300) {
      _metrics.removeAt(0);
    }

    _emitMetrics();
  }

  void recordMemoryUsage(int bytes, {String? label}) {
    recordMetric(PerformanceMetricType.memory, bytes.toDouble(), label: label);
  }

  void recordCpuUsage(double percentage, {String? label}) {
    recordMetric(PerformanceMetricType.cpu, percentage, label: label);
  }

  void _emitMetrics() {
    if (!_metricsController.isClosed) {
      _metricsController.add(List.unmodifiable(_metrics));
    }
  }

  void _emitSnapshot() {
    if (!_snapshotController.isClosed) {
      _snapshotController.add(_calculateSnapshot());
    }
  }

  PerformanceSnapshot _calculateSnapshot() {
    final avgFps = _fpsHistory.isEmpty
        ? 0.0
        : _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;

    return PerformanceSnapshot(
      currentFps: _fpsHistory.isEmpty ? 0 : _fpsHistory.last,
      averageFps: avgFps,
      minFps: _minFps,
      maxFps: _maxFps,
      frameCount: _frameCount,
      totalFrameTime: _totalFrameTime,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    stopMonitoring();
    _metricsController.close();
    _snapshotController.close();
  }

  void clearHistory() {
    _metrics.clear();
    _fpsHistory.clear();
    _emitMetrics();
    _emitSnapshot();
  }
}
