import 'dart:io';
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

    // Wire handlers for state tracking
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
      // Minimal init - avoid problematic settings that differ across engines
      if (Platform.isAndroid) {
        // Don't use awaitSpeakCompletion or setQueueMode - they cause issues
      }
      try { await _tts.setLanguage('en-US'); } catch (_) {}
      try { await _tts.setSpeechRate(_rate); } catch (_) {}
      try { await _tts.setPitch(_pitch); } catch (_) {}
      try { await _tts.setVolume(1.0); } catch (_) {}

      _initialized = true;
      debugPrint('AUDIO_SERVICE: Initialized');
    } catch (e) {
      debugPrint('AUDIO_SERVICE: Init failed: $e');
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

    // Build simple text - keep under 1200 chars for reliability
    final buffer = StringBuffer();
    buffer.write('$bookName chapter $chapter. ');
    
    for (final v in verses) {
      if (_stopRequested) return false;
      final n = v['verse']?.toString() ?? '';
      final raw = (v['text'] ?? '').toString().trim();
      final t = _normalizeForTts(raw);
      if (t.isEmpty) continue;
      
      final addition = '$n. $t ';
      if (buffer.length + addition.length > 1200) break; // Stop at limit
      buffer.write(addition);
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) return false;

    _isPlaying = true;
    try {
      // Use a shorter timeout for the stop/speak transition
      await _tts.stop();
      
      // Fire and forget the speak call to avoid hanging the UI if the engine is busy
      _tts.speak(text).then((result) {
        debugPrint('AUDIO_SERVICE: speak background result=$result');
      }).catchError((e) {
        debugPrint('AUDIO_SERVICE: speak background error=$e');
      });
      
      return true;
    } catch (e) {
      debugPrint('AUDIO_SERVICE: speak failed: $e');
      _isPlaying = false;
      return false;
    }
  }

  String _normalizeForTts(String input) {
    // Remove characters that commonly break OEM TTS engines.
    final cleaned = input
        .replaceAll('¶', ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
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
