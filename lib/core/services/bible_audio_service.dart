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
  double _rate = 0.45;
  double _pitch = 1.0;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Platform.isAndroid) {
        await _tts.awaitSpeakCompletion(true);
        await _tts.setQueueMode(1); // QUEUE_FLUSH
      }
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(_rate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);

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

      _initialized = true;
      debugPrint('AUDIO_SERVICE: Initialized successfully');
    } catch (e) {
      debugPrint('AUDIO_SERVICE: Initialization failed: $e');
      rethrow;
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

    final buffer = StringBuffer();
    buffer.write('$bookName chapter $chapter. ');
    for (final v in verses) {
      final n = v['verse']?.toString() ?? '';
      final t = (v['text'] ?? '').toString().trim();
      if (t.isNotEmpty) {
        buffer.write('Verse $n. $t ');
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) return false;

    await _tts.stop();
    // Keep first payload moderate for Android TTS reliability on some OEM engines.
    final clipped = text.length > 3800 ? text.substring(0, 3800) : text;
    final result = await _tts.speak(clipped);
    debugPrint('AUDIO_SERVICE: speak result=$result, chars=${clipped.length}/${text.length}');
    return result == 1;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    // flutter_tts has inconsistent pause support across platforms.
    // We provide stop as a deterministic fallback.
    await stop();
  }
}
