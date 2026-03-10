import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Offline/No-API audio service using device TTS.
///
/// This is a pragmatic baseline for "audio playback" without remote services.
/// It speaks chapter text and supports play/pause/stop and speed/pitch changes.
class BibleAudioService {
  BibleAudioService._();
  static final BibleAudioService instance = BibleAudioService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isPlaying = false;
  bool _stopRequested = false;
  double _rate = 0.45;
  double _pitch = 1.0;

  Future<void> initialize() async {
    if (_initialized) return;

    // Always wire handlers first so we can observe state even in partial init.
    _tts.setStartHandler(() {
      _isPlaying = true;
      debugPrint('AUDIO_SERVICE: TTS started');
    });
    _tts.setCompletionHandler(() {
      _isPlaying = false;
      debugPrint('AUDIO_SERVICE: TTS completed');
    });
    _tts.setCancelHandler(() {
      _isPlaying = false;
      debugPrint('AUDIO_SERVICE: TTS cancelled');
    });
    _tts.setErrorHandler((msg) {
      _isPlaying = false;
      debugPrint('AUDIO_SERVICE: TTS error: $msg');
    });

    try {
      if (Platform.isAndroid) {
        try { await _tts.awaitSpeakCompletion(true); } catch (_) {}
        try { await _tts.setQueueMode(1); } catch (_) {}
      }
      try { await _tts.setLanguage('en-US'); } catch (_) {}
      try { await _tts.setSpeechRate(_rate); } catch (_) {}
      try { await _tts.setPitch(_pitch); } catch (_) {}
      try { await _tts.setVolume(1.0); } catch (_) {}

      _initialized = true;
      debugPrint('AUDIO_SERVICE: Initialized (best-effort)');
    } catch (e) {
      debugPrint('AUDIO_SERVICE: Initialization failed, best-effort fallback active: $e');
      _initialized = true;
    }
  }

  bool get isPlaying => _isPlaying;
  double get rate => _rate;
  double get pitch => _pitch;

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.2, 0.8);
    await _tts.setSpeechRate(_rate);
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  Future<bool> speakChapter({
    required String bookName,
    required int chapter,
    required List<Map<String, dynamic>> verses,
  }) async {
    await initialize();
    _stopRequested = false;
    await _tts.stop();

    final chunks = <String>[];
    chunks.add('Reading $bookName chapter $chapter.');

    // Build small chunks so long chapters (e.g., Genesis 1) stay reliable.
    final current = StringBuffer();
    for (final v in verses) {
      final n = v['verse']?.toString() ?? '';
      final t = (v['text'] ?? '').toString().trim();
      if (t.isEmpty) continue;
      final sentence = 'Verse $n. $t ';

      if (current.length + sentence.length > 380) {
        if (current.isNotEmpty) {
          chunks.add(current.toString().trim());
          current.clear();
        }
      }
      current.write(sentence);
    }
    if (current.isNotEmpty) chunks.add(current.toString().trim());

    if (chunks.length <= 1) return false;

    // Fire-and-forget playback chain so UI returns immediately.
    unawaited(_speakChunks(chunks));
    return true;
  }

  Future<void> _speakChunks(List<String> chunks) async {
    for (final chunk in chunks) {
      if (_stopRequested) break;
      try {
        await _tts.speak(chunk);
        // Some Android TTS engines return before utterance is actually done.
        // Pace chunk submission to prevent queue overruns (notably Genesis 1).
        final ms = math.max(1500, chunk.length * 55);
        await Future.delayed(Duration(milliseconds: ms));
      } catch (e) {
        debugPrint('AUDIO_SERVICE: chunk speak failed: $e');
      }
    }
    _isPlaying = false;
  }

  Future<void> stop() async {
    _stopRequested = true;
    await _tts.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    // flutter_tts has inconsistent pause support across platforms.
    // We provide stop as a deterministic fallback.
    await stop();
  }
}
