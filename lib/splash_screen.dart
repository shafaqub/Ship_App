import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.nextScreen, super.key});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _splashTimer = Timer(const Duration(seconds: 10), _openNextScreen);
  }

  void _openNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.15,
            colors: [Color(0xFF07172E), Color(0xFF020A1B), Color(0xFF010611)],
          ),
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
                  Image.asset(
                    'assets/images/InterviewMe_logo.png',
                    width: 124,
                    height: 124,
                  ),
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
