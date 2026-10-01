import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLogoBackground extends StatefulWidget {
  final Widget child;

  const AnimatedLogoBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedLogoBackground> createState() => _AnimatedLogoBackgroundState();
}

class _AnimatedLogoBackgroundState extends State<AnimatedLogoBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isTickerEnabled = TickerMode.valuesOf(context).enabled;
    if (isTickerEnabled) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
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
      builder: (context, child) {
        return CustomPaint(
          painter: _LogoBackgroundPainter(progress: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _LogoBackgroundPainter extends CustomPainter {
  final double progress;

  _LogoBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw base gradient across the entire background
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = AppColors.backgroundGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final t = progress * 2 * math.pi;

    // 2. Draw subtle glowing ambient light orbs (Cyan & Purple)
    final cyanX = size.width * 0.25 + math.sin(t) * 25;
    final cyanY = size.height * 0.28 + math.cos(t * 0.8) * 20;
    final cyanRadius = size.width * 0.35;

    final cyanGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.15 + math.sin(t) * 0.04),
          AppColors.accentBlue.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cyanX, cyanY), radius: cyanRadius));

    canvas.drawCircle(Offset(cyanX, cyanY), cyanRadius, cyanGlowPaint);

    final purpleX = size.width * 0.75 - math.cos(t * 0.7) * 30;
    final purpleY = size.height * 0.72 + math.sin(t * 0.9) * 25;
    final purpleRadius = size.width * 0.4;

    final purpleGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.12 + math.cos(t) * 0.03),
          AppColors.accentBlue.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(purpleX, purpleY), radius: purpleRadius));

    canvas.drawCircle(Offset(purpleX, purpleY), purpleRadius, purpleGlowPaint);

    // 3. Draw subtle floating glowing dots matching the logo's glowing i-dot
    final dots = [
      (0.15, 0.20, 7.0, AppColors.accentCyan, 0.7),
      (0.82, 0.18, 9.0, AppColors.accentPurple, 0.6),
      (0.12, 0.75, 6.0, AppColors.accentBlue, 0.5),
      (0.88, 0.82, 8.0, AppColors.accentCyan, 0.65),
      (0.50, 0.12, 5.0, AppColors.glowingDot, 0.8),
      (0.35, 0.88, 10.0, AppColors.accentPurple, 0.4),
      (0.68, 0.60, 6.5, AppColors.accentCyan, 0.75),
    ];

    for (int i = 0; i < dots.length; i++) {
      final dot = dots[i];
      final speedMultiplier = (i % 3 + 1) * 0.5;
      final offsetY = (math.sin(t * speedMultiplier + i) * 15);
      final offsetX = (math.cos(t * speedMultiplier * 0.8 + i) * 10);

      final dx = size.width * dot.$1 + offsetX;
      final dy = size.height * dot.$2 + offsetY;
      final r = dot.$3;
      final color = dot.$4;
      final baseAlpha = dot.$5;

      final pulseAlpha = (baseAlpha + math.sin(t * 1.5 + i) * 0.2).clamp(0.1, 0.9);

      final glowPaint = Paint()
        ..color = color.withValues(alpha: pulseAlpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dx, dy), r * 2.2, glowPaint);

      final corePaint = Paint()..color = color.withValues(alpha: pulseAlpha);
      canvas.drawCircle(Offset(dx, dy), r, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
