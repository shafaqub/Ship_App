import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum GrokVoiceState {
  connecting,
  ready,
  listening,
  thinking,
  speaking,
  stopped,
  error,
}

class InterviewResult {
  final int number;
  final String question;
  final String answer;

  const InterviewResult({
    required this.number,
    required this.question,
    required this.answer,
  });
}

class QuestionEvaluation {
  final int questionNumber;
  final String question;
  final String answer;
  final int score;
  final String feedback;
  final String strength;
  final String improvement;

  const QuestionEvaluation({
    required this.questionNumber,
    required this.question,
    required this.answer,
    required this.score,
    required this.feedback,
    required this.strength,
    required this.improvement,
  });

  factory QuestionEvaluation.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuestionEvaluation(
      questionNumber:
          (json['questionNumber'] as num?)?.toInt() ?? 0,
      question:
          json['question']?.toString() ?? '',
      answer:
          json['answer']?.toString() ?? '',
      score:
          (json['score'] as num?)?.toInt() ?? 0,
      feedback:
          json['feedback']?.toString() ?? '',
      strength:
          json['strength']?.toString() ?? '',
      improvement:
          json['improvement']?.toString() ?? '',
    );
  }
}

class InterviewEvaluation {
  final int overallScore;
  final int technicalKnowledge;
  final int communication;
  final int clarity;
  final int confidence;
  final String summary;
  final List<String> recommendations;
  final List<QuestionEvaluation> questions;

  const InterviewEvaluation({
    required this.overallScore,
    required this.technicalKnowledge,
    required this.communication,
    required this.clarity,
    required this.confidence,
    required this.summary,
    required this.recommendations,
    required this.questions,
  });

  factory InterviewEvaluation.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawQuestions =
        json['questions'];

    final questions =
        <QuestionEvaluation>[];

    if (rawQuestions is List) {
      for (final item in rawQuestions) {
        if (item is Map) {
          questions.add(
            QuestionEvaluation.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final rawRecommendations =
        json['recommendations'];

    final recommendations =
        <String>[];

    if (rawRecommendations is List) {
      for (final item in rawRecommendations) {
        final text =
            item?.toString().trim() ?? '';

        if (text.isNotEmpty) {
          recommendations.add(text);
        }
      }
    }

    return InterviewEvaluation(
      overallScore:
          (json['overallScore'] as num?)?.toInt() ?? 0,
      technicalKnowledge:
          (json['technicalKnowledge'] as num?)?.toInt() ?? 0,
      communication:
          (json['communication'] as num?)?.toInt() ?? 0,
      clarity:
          (json['clarity'] as num?)?.toInt() ?? 0,
      confidence:
          (json['confidence'] as num?)?.toInt() ?? 0,
      summary:
          json['summary']?.toString() ?? '',
      recommendations:
          recommendations,
      questions:
          questions,
    );
  }
}

class GrokVoiceService extends ChangeNotifier {
  GrokVoiceService();

  WebSocketChannel? _channel;

  StreamSubscription? _socketSubscription;

  StreamSubscription<Uint8List>?
      _recordingSubscription;

  final AudioRecorder _recorder =
      AudioRecorder();

  GrokVoiceState _state =
      GrokVoiceState.connecting;

  String _assistantText = '';
  String _userText = '';
  String? _errorMessage;

  bool _connected = false;
  bool _microphoneEnabled = false;
  bool _isSpeaking = false;

  bool _commitInProgress = false;
  bool _hasSentAudioForCurrentTurn = false;
  bool _waitingForServerCommit = false;

  AudioSource? _audioSource;
  SoundHandle? _soundHandle;

  bool _audioStreamReady = false;
  bool _audioPlaybackStarted = false;

  String _currentAssistantTranscript = '';

  final List<String> _questions = [];
  final List<String> _answers = [];

  bool _interviewComplete = false;

  InterviewEvaluation? _evaluation;

  bool _evaluationReady = false;

  bool _finalResponseFinished = false;

  bool _evaluationError = false;

  String? _evaluationErrorMessage;

  GrokVoiceState get state => _state;

  String get assistantText =>
      _assistantText;

  String get userText =>
      _userText;

  String get errorMessage =>
      _errorMessage ?? '';

  bool get connected =>
      _connected;

  bool get microphoneEnabled =>
      _microphoneEnabled;

  bool get isSpeaking =>
      _isSpeaking;

  bool get interviewComplete =>
      _interviewComplete;

  InterviewEvaluation? get evaluation =>
      _evaluation;

  bool get evaluationReady =>
      _evaluationReady;

  bool get finalResponseFinished =>
      _finalResponseFinished;

  bool get evaluationError =>
      _evaluationError;

  String get evaluationErrorMessage =>
      _evaluationErrorMessage ?? '';

  /*
   * Navigation is allowed only after:
   *
   * 1. The five-question interview completed.
   * 2. The final Grok spoken response finished.
   * 3. AI evaluation is ready.
   */
  bool get canOpenEvaluation =>
      _interviewComplete &&
      _finalResponseFinished &&
      _evaluationReady &&
      _evaluation != null;

  List<InterviewResult>
      get interviewResults {
    final count =
        _questions.length <
                _answers.length
            ? _questions.length
            : _answers.length;

    return List.generate(
      count.clamp(0, 5),
      (index) => InterviewResult(
        number: index + 1,
        question:
            _questions[index],
        answer:
            _answers[index],
      ),
    );
  }

  void _setState(
    GrokVoiceState newState,
  ) {
    _state = newState;
    notifyListeners();
  }

  void _setError(
    String message,
  ) {
    _errorMessage = message;
    _state =
        GrokVoiceState.error;
    notifyListeners();
  }

  Future<void> connect() async {
    if (_connected) {
      return;
    }

    try {
      _errorMessage = null;

      _interviewComplete = false;

      _evaluation = null;

      _evaluationReady = false;

      _finalResponseFinished = false;

      _evaluationError = false;

      _evaluationErrorMessage = null;

      _setState(
        GrokVoiceState.connecting,
      );

      debugPrint(
        '==========================================',
      );

      debugPrint(
        'Initializing Grok voice...',
      );

      debugPrint(
        '==========================================',
      );

      if (!SoLoud
          .instance
          .isInitialized) {
        await SoLoud.instance.init();
      }

      await _prepareAudioStream();

      const url =
          'ws://10.0.2.2:5000/voice';

      debugPrint(
        'Connecting to voice server: $url',
      );

      _channel =
          WebSocketChannel.connect(
        Uri.parse(url),
      );

      await _channel!.ready;

      _connected = true;

      debugPrint(
        'Connected to InterviewMe voice server.',
      );

      _socketSubscription =
          _channel!.stream.listen(
        _handleServerMessage,

        onError: (error) {
          debugPrint(
            'Voice WebSocket error: $error',
          );

          _connected = false;

          _setError(
            'Voice connection error.',
          );
        },

        onDone: () {
          debugPrint(
            'Voice WebSocket disconnected.',
          );

          _connected = false;

          _isSpeaking = false;

          _microphoneEnabled = false;

          if (_state !=
              GrokVoiceState.error) {
            _setState(
              GrokVoiceState.stopped,
            );
          }
        },

        cancelOnError: false,
      );
    } catch (e) {
      debugPrint(
        'Voice connection failed: $e',
      );

      _connected = false;

      _setError(
        'Could not connect to Grok.',
      );
    }
  }

  Future<void>
      _prepareAudioStream() async {
    if (_audioStreamReady &&
        _audioSource != null) {
      return;
    }

    try {
      debugPrint(
        'Creating 24 kHz mono PCM audio stream...',
      );

      _audioSource =
          await SoLoud
              .instance
              .setBufferStream(
        maxBufferSizeBytes:
            20 * 1024 * 1024,
        bufferingType:
            BufferingType.released,
        sampleRate: 24000,
        channels: Channels.mono,
        format: BufferType.s16le,
      );

      _audioStreamReady = true;

      debugPrint(
        'SoLoud audio stream ready.',
      );
    } catch (e) {
      debugPrint(
        'Could not prepare SoLoud stream: $e',
      );

      _audioStreamReady = false;

      _audioSource = null;

      rethrow;
    }
  }

  void _resetAudioStreamForNewResponse() {
    try {
      if (_soundHandle != null) {
        try {
          SoLoud.instance.stop(
            _soundHandle!,
          );
        } catch (_) {}

        _soundHandle = null;
      }

      if (_audioSource != null) {
        try {
          SoLoud.instance
              .resetBufferStream(
            _audioSource!,
          );
        } catch (e) {
          debugPrint(
            'Buffer reset warning: $e',
          );
        }
      }

      _audioPlaybackStarted = false;

      debugPrint(
        'Grok audio playback stream reset.',
      );
    } catch (e) {
      debugPrint(
        'Audio stream reset warning: $e',
      );
    }
  }

  void _handleServerMessage(
    dynamic rawMessage,
  ) {
    try {
      final message =
          jsonDecode(
            rawMessage.toString(),
          ) as Map<String, dynamic>;

      final type =
          message['type']?.toString();

      if (type == 'ping') {
        return;
      }

      debugPrint(
        'Voice server event: $type',
      );

      switch (type) {
        case 'connected':
          debugPrint(
            'Voice server connected.',
          );
          break;

        case 'ready':
          debugPrint(
            'Grok is ready.',
          );

          _errorMessage = null;

          _setState(
            GrokVoiceState.ready,
          );

          break;

        case 'speaking_started':
          debugPrint(
            '==========================================',
          );

          debugPrint(
            'GROK STARTED SPEAKING',
          );

          debugPrint(
            '==========================================',
          );

          _isSpeaking = true;

          _currentAssistantTranscript =
              '';

          _assistantText = '';

          _resetAudioStreamForNewResponse();

          _setState(
            GrokVoiceState.speaking,
          );

          break;

        case 'assistant_text':
          final delta =
              message['text']
                      ?.toString() ??
                  '';

          if (delta.isEmpty) {
            break;
          }

          _currentAssistantTranscript +=
              delta;

          _assistantText =
              _cleanTranscript(
            _currentAssistantTranscript,
          );

          notifyListeners();

          break;

        case 'audio':
          final audioBase64 =
              message['audio']
                  ?.toString();

          if (audioBase64 == null ||
              audioBase64.isEmpty) {
            break;
          }

          _playAudioChunk(
            audioBase64,
          );

          break;

        case 'audio_committed':
          debugPrint(
            'Audio committed successfully.',
          );

          _waitingForServerCommit =
              false;

          _commitInProgress = false;

          if (!_interviewComplete) {
            _setState(
              GrokVoiceState.thinking,
            );
          }

          break;

        case 'speaking_stopped':
          debugPrint(
            'Grok finished speaking.',
          );

          _isSpeaking = false;

          final finalText =
              _cleanTranscript(
            _currentAssistantTranscript,
          );

          if (finalText.isNotEmpty) {
            _assistantText =
                finalText;
          }

          if (!_interviewComplete ||
              !_finalResponseFinished) {
            _setState(
              GrokVoiceState.ready,
            );
          }

          notifyListeners();

          break;

        case 'response_finished':
          debugPrint(
            'Grok response finished.',
          );

          final finalText =
              _cleanTranscript(
            _currentAssistantTranscript,
          );

          if (finalText.isNotEmpty) {
            _assistantText =
                finalText;
          }

          if (_interviewComplete) {
            _finalResponseFinished =
                true;

            _isSpeaking = false;

            _state =
                GrokVoiceState.stopped;
          }

          notifyListeners();

          break;

        case 'user_text':
          final text =
              message['text']
                      ?.toString() ??
                  '';

          if (text.isNotEmpty) {
            _userText = text;

            debugPrint(
              'User said: $text',
            );

            notifyListeners();
          }

          break;

        case 'interview_complete':
          _handleInterviewComplete(
            message,
          );

          break;

        case 'evaluation_ready':
          _handleEvaluationReady(
            message,
          );

          break;

        case 'evaluation_error':
          final errorText =
              message['message']
                      ?.toString() ??
                  'Could not generate AI evaluation.';

          debugPrint(
            'AI evaluation error: $errorText',
          );

          _evaluationError = true;

          _evaluationErrorMessage =
              errorText;

          notifyListeners();

          break;

        case 'error':
          final errorText =
              message['message']
                      ?.toString() ??
                  'Unknown Grok voice error.';

          debugPrint(
            'Grok voice error: $errorText',
          );

          _commitInProgress = false;

          _waitingForServerCommit =
              false;

          _setError(
            errorText,
          );

          break;

        case 'closed':
          _connected = false;

          _isSpeaking = false;

          _microphoneEnabled =
              false;

          if (_state !=
              GrokVoiceState.error) {
            _setState(
              GrokVoiceState.stopped,
            );
          }

          break;

        default:
          debugPrint(
            'Unknown voice message: $type',
          );
      }
    } catch (e) {
      debugPrint(
        'Voice message parsing error: $e',
      );
    }
  }

  void _handleInterviewComplete(
    Map<String, dynamic> message,
  ) {
    final questionList =
        message['questions'];

    final answerList =
        message['answers'];

    _questions.clear();

    _answers.clear();

    if (questionList is List) {
      for (final item in questionList) {
        final text =
            item?.toString() ??
                '';

        if (text.trim().isNotEmpty &&
            _questions.length < 5) {
          _questions.add(
            _cleanTranscript(text),
          );
        }
      }
    }

    if (answerList is List) {
      for (final item in answerList) {
        final text =
            item?.toString() ??
                '';

        if (text.trim().isNotEmpty &&
            _answers.length < 5) {
          _answers.add(
            _cleanTranscript(text),
          );
        }
      }
    }

    _interviewComplete =
        true;

    _microphoneEnabled =
        false;

    _commitInProgress =
        false;

    _waitingForServerCommit =
        false;

    /*
     * IMPORTANT:
     *
     * Do NOT mark finalResponseFinished here.
     *
     * Grok still has to say the final
     * interview-completion message.
     */
    _isSpeaking = false;

    _state =
        GrokVoiceState.thinking;

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'FIVE QUESTION INTERVIEW COMPLETE',
    );

    debugPrint(
      'Questions: ${_questions.length}',
    );

    debugPrint(
      'Answers: ${_answers.length}',
    );

    debugPrint(
      'Waiting for final Grok response + AI evaluation...',
    );

    debugPrint(
      '==========================================',
    );

    for (final result
        in interviewResults) {
      debugPrint(
        'Q${result.number}: ${result.question}',
      );

      debugPrint(
        'A${result.number}: ${result.answer}',
      );
    }

    notifyListeners();
  }

  void _handleEvaluationReady(
    Map<String, dynamic> message,
  ) {
    final rawEvaluation =
        message['evaluation'];

    if (rawEvaluation is! Map) {
      debugPrint(
        'Evaluation message did not contain a valid evaluation object.',
      );

      return;
    }

    try {
      _evaluation =
          InterviewEvaluation.fromJson(
        Map<String, dynamic>.from(
          rawEvaluation,
        ),
      );

      _evaluationReady = true;

      _evaluationError = false;

      _evaluationErrorMessage = null;

      debugPrint(
        '==========================================',
      );

      debugPrint(
        'AI EVALUATION RECEIVED',
      );

      debugPrint(
        'Overall score: ${_evaluation!.overallScore}',
      );

      debugPrint(
        'Question evaluations: ${_evaluation!.questions.length}',
      );

      debugPrint(
        'Final response finished: $_finalResponseFinished',
      );

      debugPrint(
        'Can open evaluation: $canOpenEvaluation',
      );

      debugPrint(
        '==========================================',
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Could not parse AI evaluation: $e',
      );

      _evaluationError = true;

      _evaluationErrorMessage =
          'Could not read AI evaluation.';
      
      notifyListeners();
    }
  }

  String _cleanTranscript(
    String text,
  ) {
    return text
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  void _playAudioChunk(
    String audioBase64,
  ) {
    try {
      if (!_audioStreamReady ||
          _audioSource == null) {
        debugPrint(
          'Audio stream is not ready. Recreating it...',
        );

        _prepareAudioStream().then(
          (_) {
            if (_audioSource != null) {
              _playAudioChunk(
                audioBase64,
              );
            }
          },
        );

        return;
      }

      final bytes =
          base64Decode(
        audioBase64,
      );

      if (bytes.isEmpty) {
        return;
      }

      if (!_audioPlaybackStarted) {
        _soundHandle =
            SoLoud.instance.play(
          _audioSource!,
          looping: false,
          paused: false,
        );

        _audioPlaybackStarted =
            true;

        debugPrint(
          '==========================================',
        );

        debugPrint(
          'GROK AUDIO PLAYBACK STARTED',
        );

        debugPrint(
          'Audio bytes: ${bytes.length}',
        );

        debugPrint(
          '==========================================',
        );
      }

      SoLoud.instance
          .addAudioDataStream(
        _audioSource!,
        bytes,
      );
    } catch (e) {
      debugPrint(
        'Grok audio playback error: $e',
      );
    }
  }

  Future<void>
      toggleMicrophone() async {
    if (_interviewComplete) {
      debugPrint(
        'Interview already complete.',
      );

      return;
    }

    if (_microphoneEnabled) {
      await stopMicrophone();
    } else {
      await startMicrophone();
    }
  }

  Future<void>
      startMicrophone() async {
    if (!_connected) {
      debugPrint(
        'Cannot start microphone: not connected.',
      );

      return;
    }

    if (_interviewComplete) {
      return;
    }

    if (_isSpeaking) {
      debugPrint(
        'Cannot start microphone while Grok is speaking.',
      );

      return;
    }

    if (_commitInProgress ||
        _waitingForServerCommit) {
      debugPrint(
        'Cannot start microphone while previous commit is pending.',
      );

      return;
    }

    if (_microphoneEnabled) {
      return;
    }

    try {
      final permission =
          await _recorder.hasPermission();

      if (!permission) {
        _setError(
          'Microphone permission denied.',
        );

        return;
      }

      debugPrint(
        'Preparing microphone for a new turn...',
      );

      _hasSentAudioForCurrentTurn =
          false;

      await _recordingSubscription
          ?.cancel();

      _recordingSubscription =
          null;

      try {
        await _recorder.stop();
      } catch (_) {}

      await Future.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      final stream =
          await _recorder.startStream(
        const RecordConfig(
          encoder:
              AudioEncoder.pcm16bits,
          sampleRate: 24000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );

      _recordingSubscription =
          stream.listen(
        _sendMicrophoneAudio,

        onError: (error) {
          debugPrint(
            'Microphone stream error: $error',
          );
        },
      );

      _microphoneEnabled =
          true;

      debugPrint(
        'Microphone started.',
      );

      _setState(
        GrokVoiceState.listening,
      );
    } catch (e) {
      debugPrint(
        'Could not start microphone: $e',
      );

      _microphoneEnabled =
          false;

      _setError(
        'Could not start microphone.',
      );
    }
  }

  void _sendMicrophoneAudio(
    Uint8List data,
  ) {
    if (!_microphoneEnabled ||
        !_connected ||
        _interviewComplete) {
      return;
    }

    if (data.isEmpty) {
      return;
    }

    if (_waitingForServerCommit) {
      return;
    }

    try {
      _channel?.sink.add(
        jsonEncode({
          'type': 'audio',
          'audio':
              base64Encode(data),
        }),
      );

      _hasSentAudioForCurrentTurn =
          true;
    } catch (e) {
      debugPrint(
        'Could not send microphone audio: $e',
      );
    }
  }

  Future<void>
      stopMicrophone() async {
    if (!_microphoneEnabled) {
      return;
    }

    if (_commitInProgress ||
        _waitingForServerCommit) {
      debugPrint(
        'Commit already pending.',
      );

      return;
    }

    _commitInProgress = true;

    _microphoneEnabled =
        false;

    debugPrint(
      'Stopping microphone...',
    );

    try {
      await _recordingSubscription
          ?.cancel();

      _recordingSubscription =
          null;

      try {
        await _recorder.stop();
      } catch (_) {}

      await Future.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!_hasSentAudioForCurrentTurn) {
        debugPrint(
          'No microphone audio was captured.',
        );

        _commitInProgress =
            false;

        _setState(
          GrokVoiceState.ready,
        );

        return;
      }

      if (!_connected) {
        _commitInProgress =
            false;

        return;
      }

      debugPrint(
        'Requesting audio commit.',
      );

      _waitingForServerCommit =
          true;

      _channel?.sink.add(
        jsonEncode({
          'type': 'commit',
        }),
      );

      _setState(
        GrokVoiceState.thinking,
      );

      _hasSentAudioForCurrentTurn =
          false;
    } catch (e) {
      debugPrint(
        'Could not stop microphone: $e',
      );

      _commitInProgress =
          false;

      _waitingForServerCommit =
          false;

      _setError(
        'Could not process microphone input.',
      );
    }
  }

  @override
  void dispose() {
    debugPrint(
      'Disposing Grok voice service...',
    );

    _microphoneEnabled =
        false;

    _connected = false;

    _recordingSubscription
        ?.cancel();

    _socketSubscription
        ?.cancel();

    try {
      _recorder.stop();
    } catch (_) {}

    try {
      if (_soundHandle != null) {
        SoLoud.instance.stop(
          _soundHandle!,
        );

        _soundHandle = null;
      }
    } catch (_) {}

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;

    try {
      if (SoLoud
          .instance
          .isInitialized) {
        SoLoud.instance.deinit();
      }
    } catch (_) {}

    super.dispose();
  }
}