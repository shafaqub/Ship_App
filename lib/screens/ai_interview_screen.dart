import 'package:flutter/material.dart';

import '../services/grok_voice_service.dart';
import '../widgets/voice_orb.dart';

import 'overall_results_screen.dart';

class AiInterviewScreen
    extends StatefulWidget {
  const AiInterviewScreen({
    super.key,
  });

  @override
  State<AiInterviewScreen> createState() =>
      _AiInterviewScreenState();
}

class _AiInterviewScreenState
    extends State<AiInterviewScreen> {
  late final GrokVoiceService
      _voiceService;

  bool _evaluationOpened =
      false;

  @override
  void initState() {
    super.initState();

    _voiceService =
        GrokVoiceService();

    _voiceService.addListener(
      _onVoiceChanged,
    );

    _connect();
  }

  Future<void> _connect() async {
    await _voiceService.connect();
  }

  void _onVoiceChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});

    _checkForEvaluation();
  }

  void _checkForEvaluation() {
    if (!mounted) {
      return;
    }

    if (_evaluationOpened) {
      return;
    }

    if (!_voiceService
        .canOpenEvaluation) {
      return;
    }

    final evaluation =
        _voiceService.evaluation;

    if (evaluation == null) {
      return;
    }

    _evaluationOpened = true;

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'OPENING AI EVALUATION SCREEN',
    );

    debugPrint(
      'Overall score: ${evaluation.overallScore}',
    );

    debugPrint(
      '==========================================',
    );

    /*
     * Wait one frame so the current voice-screen
     * state update has completed.
     */
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                OverallResultsScreen(
              evaluation:
                  evaluation,
            ),
          ),
        );
      },
    );
  }

  void _openEvaluationManually() {
    final evaluation =
        _voiceService.evaluation;

    if (evaluation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Evaluation is not ready yet.',
          ),
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            OverallResultsScreen(
          evaluation:
              evaluation,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.removeListener(
      _onVoiceChanged,
    );

    _voiceService.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final state =
        _voiceService.state;

    final statusText =
        switch (state) {
      GrokVoiceState.connecting =>
        'Connecting...',

      GrokVoiceState.ready =>
        'Ready',

      GrokVoiceState.listening =>
        'Listening',

      GrokVoiceState.thinking =>
        'Thinking...',

      GrokVoiceState.speaking =>
        'Grok is speaking',

      GrokVoiceState.stopped =>
        _voiceService
                .interviewComplete
            ? 'Preparing evaluation...'
            : 'Interview stopped',

      GrokVoiceState.error =>
        'Connection error',
    };

    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1A),

      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter:
                      _BackgroundPainter(),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(
                  height: 12,
                ),

                // =====================================================
                // TOP BAR
                // =====================================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      IconButton(
                        onPressed:
                            _voiceService
                                    .interviewComplete
                                ? null
                                : () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },

                        icon:
                            const Icon(
                          Icons.close_rounded,
                          color:
                              Colors.white70,
                          size: 28,
                        ),
                      ),

                      GestureDetector(
                        onTap:
                            _openEvaluationManually,

                        child:
                            Container(
                          margin:
                              const EdgeInsets
                                  .only(
                            right: 8,
                          ),

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              0.08,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              22,
                            ),

                            border:
                                Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.16,
                              ),
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [
                              const Icon(
                                Icons
                                    .analytics_outlined,
                                color:
                                    Colors.white,
                                size: 18,
                              ),

                              const SizedBox(
                                width: 7,
                              ),

                              Text(
                                _voiceService
                                        .evaluationReady
                                    ? 'Evaluation'
                                    : 'Evaluation',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      13,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // =====================================================
                // GROK QUESTION / TEXT
                // =====================================================

                if (_voiceService
                    .assistantText
                    .isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                    ),

                    child: Text(
                      _voiceService
                          .assistantText,

                      textAlign:
                          TextAlign.center,

                      maxLines: 5,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 22,
                        height: 1.35,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Text(
                    statusText,

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                const SizedBox(
                  height: 42,
                ),

                // =====================================================
                // VOICE ORB
                // =====================================================

                VoiceOrb(
                  active:
                      _voiceService
                          .connected,

                  speaking:
                      _voiceService
                          .isSpeaking,
                ),

                const Spacer(),

                // =====================================================
                // EVALUATION STATUS
                // =====================================================

                if (_voiceService
                    .interviewComplete)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                    ),

                    child: Text(
                      _voiceService
                              .evaluationReady
                          ? 'Evaluation ready. Opening results...'
                          : 'Analyzing your five answers...',

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),

                if (_voiceService
                    .evaluationError)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                    ),

                    child: Text(
                      _voiceService
                          .evaluationErrorMessage,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 18,
                ),

                // =====================================================
                // ERROR
                // =====================================================

                if (_voiceService.state ==
                    GrokVoiceState.error)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                    ),

                    child: Text(
                      _voiceService
                          .errorMessage,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 18,
                ),

                // =====================================================
                // MICROPHONE
                // =====================================================

                GestureDetector(
                  onTap:
                      _voiceService
                              .connected &&
                          !_voiceService
                              .interviewComplete
                      ? _voiceService
                          .toggleMicrophone
                      : null,

                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 200,
                    ),

                    width: 68,
                    height: 68,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color:
                          _voiceService
                                  .microphoneEnabled
                              ? const Color(
                                  0xFF16A9E8,
                                )
                              : const Color(
                                  0xFF172438,
                                ),

                      boxShadow:
                          [
                        BoxShadow(
                          color: _voiceService
                                  .microphoneEnabled
                              ? const Color(
                                  0xFF16A9E8,
                                ).withOpacity(
                                  0.35,
                                )
                              : Colors
                                  .transparent,

                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),

                    child: Icon(
                      _voiceService
                              .microphoneEnabled
                          ? Icons
                              .mic_rounded
                          : Icons
                              .mic_off_rounded,

                      color:
                          Colors.white,

                      size: 30,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  _voiceService
                          .interviewComplete
                      ? 'Interview complete'
                      : _voiceService
                              .microphoneEnabled
                          ? 'Tap to stop'
                          : 'Tap to speak',

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint =
        Paint()
          ..style =
              PaintingStyle.fill;

    final center = Offset(
      size.width * 0.5,
      size.height * 0.48,
    );

    final radius =
        size.width * 0.75;

    paint.shader =
        RadialGradient(
      colors: [
        const Color(0xFF0A2943)
            .withOpacity(0.35),

        const Color(0xFF020B1A)
            .withOpacity(0.0),
      ],
    ).createShader(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
    );

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {
    return false;
  }
}