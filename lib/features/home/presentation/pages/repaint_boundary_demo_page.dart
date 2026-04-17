import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_color.dart';

class RepaintBoundaryDemoPage extends StatelessWidget {
  const RepaintBoundaryDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RepaintBoundary Demo Lab'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(
              title: "🔴 PHẦN 1: KHÔNG CÓ RepaintBoundary",
              subtitle:
                  "Khi vòng xoay Loading chạy, cả vùng Background sẽ bị vẽ lại (repaint) liên tục. Hãy bật 'Highlight Repaints' để thấy cả vùng này nhấp nháy.",
              useRepaintBoundary: false,
            ),
            const Divider(height: 50, thickness: 5),
            _buildSection(
              title: "🟢 PHẦN 2: CÓ RepaintBoundary",
              subtitle:
                  "Vòng xoay Loading được cô lập. Chỉ có đúng cái vòng xoay nhấp nháy vẽ lại, Background tĩnh bên dưới hoàn toàn đứng yên.",
              useRepaintBoundary: true,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required bool useRepaintBoundary,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Background "nặng" để dễ thấy hiện tượng repaint
            const HeavyBackgroundWidget(),

            // Widget Loading
            if (useRepaintBoundary)
              const RepaintBoundary(
                child: CircularProgressIndicator(color: AppColor.purple),
              )
            else
              const CircularProgressIndicator(color: AppColor.purple),
          ],
        ),
      ],
    );
  }
}

/// Một widget giả lập background "nặng" với nhiều phần tử
/// để thấy rõ vùng bị repaint khi bật Highlight Repaints.
class HeavyBackgroundWidget extends StatelessWidget {
  const HeavyBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          return Icon(
            Icons.grid_on,
            size: 10,
            color: Colors.blue.withValues(alpha: 0.2),
          );
        },
      ),
    );
  }
}
