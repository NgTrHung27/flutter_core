import 'package:flutter/material.dart';

import '../../../../core/themes/app_color.dart';

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: RepaintBoundary(
        child: CircularProgressIndicator(color: AppColor.purple),
      ),
    );
  }
}
