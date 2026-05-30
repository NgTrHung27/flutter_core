import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/image_assets.dart';

/// Widget hiển thị khi mất kết nối internet.
///
/// Cung cấp nút "Thử lại" và nút "Mở Cài đặt Wifi" (dùng app_settings).
///
/// ```dart
/// NoInternetWidget(
///   onRetry: () => bloc.add(RetryEvent()),
/// )
/// ```
class NoInternetWidget extends StatefulWidget {
  /// Callback khi nhấn nút "Thử lại".
  final VoidCallback? onRetry;

  /// Tiêu đề custom (mặc định: "Không có kết nối mạng").
  final String? title;

  /// Mô tả custom.
  final String? subtitle;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.title,
    this.subtitle,
  });

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Pulsing illustration ───────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) =>
                  Transform.scale(scale: _pulseAnimation.value, child: child),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    preNoInternetPNG,
                    width: 180.w,
                    height: 180.w,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        icWifiSVG,
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onErrorContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // ── Title ──────────────────────────────────────────────────
            Text(
              widget.title ?? 'Không có kết nối mạng',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10.h),

            Text(
              widget.subtitle ??
                  'Vui lòng kiểm tra kết nối Wifi hoặc dữ liệu di động của bạn.',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // ── Action buttons ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retry
                if (widget.onRetry != null)
                  FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: Icon(Icons.refresh_rounded, size: 18.r),
                    label: Text(
                      'Thử lại',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 13.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                if (widget.onRetry != null) SizedBox(width: 12.w),

                // Open Wifi Settings
                OutlinedButton.icon(
                  onPressed: () => AppSettings.openAppSettings(
                    type: AppSettingsType.wifi,
                  ),
                  icon: SvgPicture.asset(
                    icWifiSVG,
                    width: 16.r,
                    height: 16.r,
                    colorFilter: ColorFilter.mode(
                      colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(
                    'Cài đặt Wifi',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 13.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
