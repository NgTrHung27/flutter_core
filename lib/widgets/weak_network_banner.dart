import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/image_assets.dart';

/// Banner mỏng hiển thị ở top màn hình khi mạng yếu (2G/E/GPRS).
///
/// Không che nội dung chính — chỉ push content xuống nhẹ.
/// Tự slide-in khi visible, slide-out khi ẩn.
///
/// ```dart
/// Column(
///   children: [
///     WeakNetworkBanner(
///       isVisible: networkState is NetworkConnected &&
///                  (networkState as NetworkConnected).isWeak,
///       latencyMs: latency,
///     ),
///     Expanded(child: MyContent()),
///   ],
/// )
/// ```
class WeakNetworkBanner extends StatelessWidget {
  final bool isVisible;
  final int? latencyMs;

  const WeakNetworkBanner({
    super.key,
    required this.isVisible,
    this.latencyMs,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isVisible ? _buildBanner(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final latencyText = latencyMs != null ? ' · ${latencyMs}ms' : '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD), // Amber warning
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icWifiSVG,
            width: 16.r,
            height: 16.r,
            colorFilter: const ColorFilter.mode(
              Color(0xFF856404),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Mạng rất yếu (2G/E)$latencyText — Kết nối chậm',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF856404),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.signal_cellular_alt_1_bar_rounded,
            size: 16.r,
            color: const Color(0xFF856404),
          ),
        ],
      ),
    );
  }
}
