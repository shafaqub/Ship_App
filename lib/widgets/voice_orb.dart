import 'dart:math' as math;

import 'package:flutter/material.dart';

class VoiceOrb extends StatefulWidget {
  const VoiceOrb({
    super.key,
    this.active = false,
    this.speaking = false,
    this.size = 190,
  });

  final bool active;
  final bool speaking;
  final double size;

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
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
        final pulse = math.sin(_controller.value * math.pi * 2);

        final scale = widget.active
            ? 1.0 + (pulse + 1) * 0.025
            : 0.96;

        final glow = widget.speaking
            ? 0.35 + ((pulse + 1) * 0.10)
            : widget.active
                ? 0.22
                : 0.10;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8FEAFF).withOpacity(0.95),
                  const Color(0xFF28B8FF).withOpacity(0.75),
                  const Color(0xFF0877C9).withOpacity(0.45),
                  const Color(0xFF02172D).withOpacity(0.2),
                ],
                stops: const [
                  0.0,
                  0.38,
                  0.72,
                  1.0,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25C7FF).withOpacity(glow),
                  blurRadius: widget.speaking ? 55 : 35,
                  spreadRadius: widget.speaking ? 10 : 4,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.48,
                height: widget.size * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF020B1A),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

