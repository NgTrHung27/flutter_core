import 'dart:async';
import 'package:flutter/material.dart';

class MemoryLeakPage extends StatefulWidget {
  const MemoryLeakPage({super.key});

  @override
  State<MemoryLeakPage> createState() => _MemoryLeakPageState();
}

class _MemoryLeakPageState extends State<MemoryLeakPage> {
  // --- The Ghost that stays ---
  // This Timer is NEVER cancelled. Even after you leave this page,
  // it will continue to run and hold a reference to this State object.
  // This prevents the Garbage Collector (GC) from reclaiming the memory.
  late Timer _leakingTimer;
  int _counter = 0;

  // We also create a large object to make the leak more visible in DevTools
  final List<String> _heavyData = [];

  @override
  void initState() {
    super.initState();

    // INTENTIONAL LEAK: We start a timer and don't cancel it in dispose()
    _leakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _counter++;
      // Adding data continuously to increase memory usage
      _heavyData.add(
        'Data Item $_counter: ${DateTime.now().toIso8601String()}',
      );
      debugPrint('Leaking Timer: $_counter items in memory');
    });
  }

  @override
  void dispose() {
    // WRONG: We "forgot" to call _leakingTimer.cancel()
    // In a real app, ALWAYS call .cancel() here.
    _leakingTimer.cancel(); // Cắt đứt sợi dây tham chiếu
    debugPrint('MemoryLeakPage disposed, but Timer still running! (LEAK)');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Ghost Page (Leak)'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.bug_report, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'WARNING: This page leaks memory!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'A periodic Timer was started in initState() and is NOT cancelled in dispose().\n\n'
              'Strategy for DevTools:\n'
              '1. Go back and enter this page 5-10 times.\n'
              '2. Watch the "Memory" tab in DevTools.\n'
              '3. Notice the blue line (RSS/Heap) stepping up.\n'
              '4. Press "Force GC" and notice it doesn\'t go back down.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Data count: ${_heavyData.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
