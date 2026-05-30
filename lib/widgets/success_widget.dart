import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/image_assets.dart';

/// Widget hiển thị trạng thái thành công.
///
/// ```dart
/// SuccessWidget(
///   title: 'Đặt hàng thành công!',
///   subtitle: 'Đơn hàng của bạn đang được xử lý.',
///   onDone: () => context.go(AppRoute.home.path),
/// )
/// ```
class SuccessWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onDone;
  final String? doneLabel;

  const SuccessWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onDone,
    this.doneLabel,
  });

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            // ── Animated SVG illustration ──────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Transform.scale(
                scale: _scaleAnim.value,
                child: SvgPicture.asset(
                  preDoneSVG,
                  width: 140.w,
                  height: 140.w,
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Title ──────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, child) =>
                  Opacity(opacity: _fadeAnim.value, child: child),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.subtitle != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (widget.onDone != null) ...[
                    SizedBox(height: 32.h),
                    FilledButton(
                      onPressed: widget.onDone,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 36.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        widget.doneLabel ?? 'Xong',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
