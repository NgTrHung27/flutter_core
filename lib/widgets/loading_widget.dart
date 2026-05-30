import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget loading dùng chung.
///
/// Hỗ trợ 3 kiểu: circular, dots (nhảy), và overlay (che toàn màn hình).
///
/// ```dart
/// LoadingWidget()                        // Centered circular
/// LoadingWidget.dots()                   // Animated dots
/// LoadingWidget.overlay(context)         // Full-screen overlay
/// ```
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;
  final _LoadingVariant _variant;

  const LoadingWidget({super.key, this.message, this.color, this.size})
    : _variant = _LoadingVariant.circular;

  const LoadingWidget.dots({super.key, this.message, this.color, this.size})
    : _variant = _LoadingVariant.dots;

  // ignore: unused_element
  const LoadingWidget._overlay({this.message})
      : color = null,
        size = null,
        _variant = _LoadingVariant.overlay;

  /// Hiển thị overlay bán trong suốt che toàn màn hình.
  static void show(
    BuildContext context, {
    String? message,
    Color? barrierColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (_) => LoadingWidget._overlay(message: message),
    );
  }

  /// Ẩn overlay loading.
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _LoadingVariant.circular:
        return _buildCircular(context);
      case _LoadingVariant.dots:
        return _DotsLoadingWidget(message: message, color: color);
      case _LoadingVariant.overlay:
        return _buildOverlay(context);
    }
  }

  Widget _buildCircular(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 48.r,
            height: size ?? 48.r,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: _buildCircular(context),
      ),
    );
  }
}

enum _LoadingVariant { circular, dots, overlay }

// ─── Dots Loading ──────────────────────────────────────────────────────────────

class _DotsLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;

  const _DotsLoadingWidget({this.message, this.color});

  @override
  State<_DotsLoadingWidget> createState() => _DotsLoadingWidgetState();
}

class _DotsLoadingWidgetState extends State<_DotsLoadingWidget>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0,
        end: -10,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _animations[i],
                builder: (_, _) => Transform.translate(
                  offset: Offset(0, _animations[i].value),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (widget.message != null) ...[
            SizedBox(height: 14.h),
            Text(
              widget.message!,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
