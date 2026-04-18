import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/configs/injector/injector_conf.dart';
import '../../../isolate_demo/presentation/bloc/isolate_bloc.dart';
import '../../../isolate_demo/presentation/bloc/isolate_event.dart';
import '../../../isolate_demo/presentation/bloc/isolate_state.dart';

// ---------------------------------------------------------
// WIDGET : RADAR QUAY LIÊN TỤC ĐỂ TEST ĐỨNG HÌNH (FREEZE)
// ---------------------------------------------------------
class RadarSpinner extends StatefulWidget {
  const RadarSpinner({super.key});

  @override
  State<RadarSpinner> createState() => _RadarSpinnerState();
}

class _RadarSpinnerState extends State<RadarSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 4),
              gradient: SweepGradient(
                colors: [
                  Colors.blueAccent.withValues(alpha: 0.1),
                  Colors.blueAccent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
              size: 30,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// MAIN PAGE
// ---------------------------------------------------------
class IsolateDemoPage extends StatelessWidget {
  const IsolateDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IsolateBloc>(),
      child: const IsolateDemoView(),
    );
  }
}

class IsolateDemoView extends StatelessWidget {
  const IsolateDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate Visual Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // KHU VỰC QUAN SÁT ANIMATION
              const Text(
                'Nhìn kỹ vòng Radar bên dưới\nNếu nó bị ĐỨNG HÌNH -> Main Thread bị block!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // FIX: Bọc tất cả các trạng thái vào một SizedBox có chiều cao CỐ ĐỊNH là 120
              // Điều này đảm bảo UI không bao giờ bị nhảy lên nhảy xuống khi state thay đổi
              SizedBox(
                height: 120,
                child: BlocBuilder<IsolateBloc, IsolateState>(
                  builder: (context, state) {
                    if (state is IsolateLoading) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const RadarSpinner(), // RADAR 80x80
                          const SizedBox(height: 16),
                          const Text('Đang tải & Parse dữ liệu...'),
                        ],
                      );
                    } else if (state is IsolateLoaded) {
                      return const Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 80, // Icon bằng đúng kích thước của Radar
                          color: Colors.green,
                        ),
                      );
                    } else if (state is IsolateError) {
                      return const Center(
                        child: Icon(Icons.error, size: 80, color: Colors.red),
                      );
                    }

                    // Trạng thái chờ (Initial)
                    return const Center(child: RadarSpinner());
                  },
                ),
              ),

              const SizedBox(height: 32),

              // KHU VỰC BÁO CÁO KẾT QUẢ
              BlocBuilder<IsolateBloc, IsolateState>(
                builder: (context, state) {
                  int count = 0;
                  String message = 'Bấm nút để tải cục JSON siêu to khổng lồ';

                  if (state is IsolateLoaded) {
                    count = state.data.totalRecords;
                    message =
                        'Thành công!\nDùng Isolate: ${state.usedIsolate}\nThời gian: ${state.timeTakenMs} ms';
                  } else if (state is IsolateError) {
                    message = 'Lỗi: ${state.message}';
                  } else if (state is IsolateLoading) {
                    message =
                        'Hãy để ý xem Radar có bị giật/đứng hình không...';
                  }

                  return Column(
                    children: [
                      Text(
                        'Tổng items: $count',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // KHU VỰC ĐIỀU KHIỂN
              BlocBuilder<IsolateBloc, IsolateState>(
                builder: (context, state) {
                  final isLoading = state is IsolateLoading;
                  return Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.read<IsolateBloc>().add(
                                const FetchPayloadEvent(useIsolate: false),
                              ),
                        icon: const Icon(Icons.warning, color: Colors.white),
                        label: const Text('API Parse (KHÔNG Isolate)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.read<IsolateBloc>().add(
                                const FetchPayloadEvent(useIsolate: true),
                              ),
                        icon: const Icon(Icons.speed, color: Colors.white),
                        label: const Text('API Parse (CÓ Isolate)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
