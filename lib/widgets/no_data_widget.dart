import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/image_assets.dart';

/// Widget hiển thị khi không có dữ liệu (empty state).
///
/// ```dart
/// NoDataWidget(
///   title: 'Chưa có đơn hàng',
///   subtitle: 'Các đơn hàng của bạn sẽ xuất hiện ở đây.',
///   onRetry: () => bloc.add(RefreshEvent()),
/// )
/// ```
class NoDataWidget extends StatelessWidget {
  /// Tiêu đề chính (bắt buộc).
  final String title;

  /// Mô tả phụ (optional).
  final String? subtitle;

  /// Callback khi nhấn nút "Thử lại". Nếu null, nút không hiển thị.
  final VoidCallback? onRetry;

  /// Label của nút retry (mặc định: "Thử lại").
  final String? retryLabel;

  /// Ảnh custom thay thế ảnh mặc định.
  final String? customImagePath;

  const NoDataWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.retryLabel,
    this.customImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Illustration ───────────────────────────────────────────
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Image.asset(
                customImagePath ?? preEmptyBoxPNG,
                width: 180.w,
                height: 180.w,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 24.h),

            // ── Title ──────────────────────────────────────────────────
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Subtitle ───────────────────────────────────────────────
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Retry button ───────────────────────────────────────────
            if (onRetry != null) ...[
              SizedBox(height: 28.h),
              FilledButton.tonal(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  retryLabel ?? 'Thử lại',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
