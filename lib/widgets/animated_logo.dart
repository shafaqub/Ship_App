import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AnimatedInterviewMeLogo extends StatefulWidget {
  final double width;
  final double height;

  const AnimatedInterviewMeLogo({
    super.key,
    this.width = 250,
    this.height = 250,
  });

  @override
  State<AnimatedInterviewMeLogo> createState() => _AnimatedInterviewMeLogoState();
}

class _AnimatedInterviewMeLogoState extends State<AnimatedInterviewMeLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _popController.addListener(() {
      if (!_soundPlayed && _popController.value >= 0.65) {
        _soundPlayed = true;
        SystemSound.play(SystemSoundType.alert);
      }
    });
    _popController.forward();
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Relative coordinates of the 'i' dot in interviewme-logo-v8.png (600x600 image)
    final dotX = widget.width * 0.354;
    final dotY = widget.height * 0.205;
    final dotSize = widget.width * 0.15;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          // 1. Base Logo Image
          Image.asset(
            'assets/interviewme-logo-v8.png',
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
          ),

          // 2. "Pop / Ding" Animated Glowing Orb Overlay over the 'i' dot
          Positioned(
            left: dotX - (dotSize / 2),
            top: dotY - (dotSize / 2),
            child: AnimatedBuilder(
              animation: _popController,
              builder: (context, child) {
                final raw = _popController.value;
                final landing = Curves.elasticOut.transform(raw);
                final verticalOffset = (1 - landing) * -widget.height * 0.28;
                final scale = raw < 0.68 ? 1.0 : 1.0 + (1 - raw) * 0.18;
                final flashOpacity = raw < 0.68 ? 0.25 : 0.45;

                return Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCyan.withValues(alpha: flashOpacity),
                            blurRadius: 22,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: flashOpacity * 0.6),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _IDotDingPainter(flashOpacity: flashOpacity),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IDotDingPainter extends CustomPainter {
  final double flashOpacity;

  _IDotDingPainter({required this.flashOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glowing core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: (flashOpacity + 0.2).clamp(0.0, 1.0)),
          AppColors.accentCyan.withValues(alpha: flashOpacity),
          AppColors.accentBlue.withValues(alpha: flashOpacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.65, corePaint);

  }

  @override
  bool shouldRepaint(covariant _IDotDingPainter oldDelegate) {
    return oldDelegate.flashOpacity != flashOpacity;
  }
}
