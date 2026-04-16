import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_route_path.dart';

class ProfilingPage extends StatefulWidget {
  const ProfilingPage({super.key});

  @override
  State<ProfilingPage> createState() => _ProfilingPageState();
}

class _ProfilingPageState extends State<ProfilingPage> {
  bool _showComplexUI = false;
  String _cpuResult = 'Result will appear here';

  // --- CPU Profiling (UI Thread) ---
  // Heavy synchronous task to spike the UI Thread.
  void _runHeavyComputation() {
    setState(() {
      _cpuResult = 'Calculating...';
    });

    // We use a small delay to ensure the UI updates before the block
    Future.delayed(const Duration(milliseconds: 100), () {
      final watch = Stopwatch()..start();
      final result = _fibonacci(40); // This will take some time
      watch.stop();

      if (mounted) {
        setState(() {
          _cpuResult =
              'Fibonacci(40) = $result\nTime: ${watch.elapsedMilliseconds}ms';
        });
      }
    });
  }

  int _fibonacci(int n) {
    if (n <= 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }

  // --- CPU Profiling (Raster Thread) ---
  // Toggling complex UI to spike the Raster Thread.
  Widget _buildComplexWidget() {
    return Column(
      children: List.generate(20, (index) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.2),
                BlendMode.srcOver,
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Complex Raster Widget'),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DevTools Profiling Lab')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              '1. CPU Profiling (UI Thread)',
              'Click to run a heavy sync task. Watch the Performance tab / UI Thread.',
            ),
            ElevatedButton.icon(
              onPressed: _runHeavyComputation,
              icon: const Icon(Icons.bolt),
              label: const Text('Run Fibonacci(40)'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_cpuResult, textAlign: TextAlign.center),
            ),
            const Divider(height: 32),
            _buildSectionHeader(
              '2. CPU Profiling (Raster Thread)',
              'Toggle complex UI with many shadows & filters. Watch the Raster Thread.',
            ),
            SwitchListTile(
              title: const Text('Show Complex UI'),
              subtitle: const Text('May cause frame drops (Jank)'),
              value: _showComplexUI,
              onChanged: (val) => setState(() => _showComplexUI = val),
            ),
            if (_showComplexUI) _buildComplexWidget(),
            const Divider(height: 32),
            _buildSectionHeader(
              '3. Memory Profiling (Memory Leaks)',
              'Navigate to the leak page to see how forgotten resources consume RAM.',
            ),
            ElevatedButton.icon(
              onPressed: () => context.goNamed(AppRoute.memoryLeak.name),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Go to Memory Leak Page'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
