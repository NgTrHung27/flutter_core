import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/image_assets.dart';

/// Widget hiển thị khi có lỗi xảy ra (generic error state).
///
/// Đặt tên `AppErrorWidget` thay vì `ErrorWidget` vì Flutter SDK
/// đã có sẵn `ErrorWidget` là widget lỗi render mặc định.
///
/// ```dart
/// AppErrorWidget(
///   message: 'Có lỗi xảy ra, vui lòng thử lại.',
///   onRetry: () => bloc.add(RetryEvent()),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Thông báo lỗi hiển thị cho người dùng.
  final String? message;

  /// Callback khi nhấn "Thử lại". Nếu null, nút không hiển thị.
  final VoidCallback? onRetry;

  /// Label nút retry (mặc định: "Thử lại").
  final String? retryLabel;

  /// Ảnh custom thay thế ảnh mặc định.
  final String? customImagePath;

  const AppErrorWidget({
    super.key,
    this.message,
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
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              builder: (_, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Image.asset(
                customImagePath ?? preErrorPNG,
                width: 175.w,
                height: 175.w,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 24.h),

            // ── Title ──────────────────────────────────────────────────
            Text(
              'Ôi, có lỗi xảy ra!',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Error message ──────────────────────────────────────────
            if (message != null) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  message!,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: colorScheme.onErrorContainer,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // ── Retry button ───────────────────────────────────────────
            if (onRetry != null) ...[
              SizedBox(height: 28.h),
              FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: 18.r),
                label: Text(
                  retryLabel ?? 'Thử lại',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 13.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
