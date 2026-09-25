import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.nextScreen,
    this.onInitialize,
    super.key,
  });

  final Widget nextScreen;
  final Future<void> Function()? onInitialize;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
  with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _logoController;
  bool _dingPlayed = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addListener(_handleLogoProgress);
    _startStartup();
  }

  void _handleLogoProgress() {
    if (!_dingPlayed && _logoController.value >= 0.72) {
      _dingPlayed = true;
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _startStartup() async {
    try {
      await Future.wait<void>([
        _logoController.forward(),
        widget.onInitialize?.call() ?? Future<void>.value(),
      ]);
    } catch (_) {
      // Login is the existing safe fallback when optional startup work fails.
    }
    if (mounted) _openNextScreen();
  }

  void _openNextScreen() {
    if (!mounted) return;
    _waveController.stop(canceled: false);
    _logoController.stop(canceled: false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.985, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _waveController.stop(canceled: false);
    _logoController.stop(canceled: false);
    _waveController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF020A1B),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.17,
              height: size.height * 0.22,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) => CustomPaint(
                  painter: WavePainter(_waveController.value),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedLogo(),
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Interview',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Me',
                          style: TextStyle(
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFF57D0FF),
                                  Color(0xFF8A78FF),
                                  Color(0xFFBB7BFF),
                                ],
                              ).createShader(const Rect.fromLTWH(0, 0, 180, 50)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    const logoSize = 220.0;
    const dotSize = logoSize * 0.15;
    final dotX = logoSize * 0.354 - dotSize / 2;
    final dotY = logoSize * 0.205 - dotSize / 2;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/interviewme-logo-v8.png',
            width: logoSize,
            height: logoSize,
          ),
          Positioned(
            left: dotX,
            top: dotY,
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                final raw = _logoController.value;
                final fallProgress = (raw / 0.72).clamp(0.0, 1.0);
                final fall = Curves.easeInCubic.transform(fallProgress);
                final impactProgress = ((raw - 0.72) / 0.28).clamp(0.0, 1.0);
                final impact = math.sin(impactProgress * math.pi);

                return Transform.translate(
                  offset: Offset(0, -logoSize * 0.32 * (1 - fall)),
                  child: Transform.scale(
                    scale: 1 + impact * 0.08,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF57D0FF).withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF57D0FF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  const WavePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = progress * math.pi * 2;
    final firstPath = _wavePath(
      size,
      phase,
      size.height * 0.52,
      26,
      12,
      88,
      140,
      -0.9,
    );
    final secondPath = _wavePath(
      size,
      phase * 1.12 + 1.5,
      size.height * 0.68,
      20,
      14,
      94,
      160,
      1.7,
    );

    _drawWave(canvas, size, firstPath, const [
      Color(0xAA36CFFF),
      Color(0x997B8CFF),
      Color(0xA8D864FF),
    ], 7, 10);
    _drawWave(canvas, size, secondPath, const [
      Color(0xAA7ADFFF),
      Color(0xA8C46BFF),
    ], 7, 10);
    _drawWave(canvas, size, firstPath, const [
      Color(0xFF51D8FF),
      Color(0xFF91A4FF),
      Color(0xFFE08AFF),
    ], 1.8, 0);
    _drawWave(canvas, size, secondPath, const [
      Color(0xFF81E5FF),
      Color(0xFFE083FF),
    ], 1.8, 0);
  }

  Path _wavePath(
    Size size,
    double phase,
    double center,
    double firstAmplitude,
    double secondAmplitude,
    double firstPeriod,
    double secondPeriod,
    double phaseMultiplier,
  ) {
    final path = Path()..moveTo(0, center);
    for (var x = 0.0; x <= size.width; x += 4) {
      path.lineTo(
        x,
        center +
            math.sin((x / firstPeriod) + phase) * firstAmplitude +
            math.sin((x / secondPeriod) + phase * phaseMultiplier) *
                secondAmplitude,
      );
    }
    return path;
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Path path,
    List<Color> colors,
    double width,
    double blur,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(colors: colors).createShader(Offset.zero & size);
    if (blur > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
