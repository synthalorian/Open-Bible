import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio Bible provider for Text-to-Speech functionality
final audioBibleProvider = StateNotifierProvider<AudioBibleNotifier, AudioBibleState>((ref) {
  return AudioBibleNotifier();
});

class AudioBibleState {
  final bool isSpeaking;
  final double volume;
  final double pitch;
  final double rate;
  final String? currentVerse;
  final String selectedLanguage;
  
  AudioBibleState({
    this.isSpeaking = false,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.rate = 0.5,
    this.currentVerse,
    this.selectedLanguage = 'en-US',
  });
  
  AudioBibleState copyWith({
    bool? isSpeaking,
    double? volume,
    double? pitch,
    double? rate,
    String? currentVerse,
    String? selectedLanguage,
  }) {
    return AudioBibleState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      currentVerse: currentVerse ?? this.currentVerse,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class AudioBibleNotifier extends StateNotifier<AudioBibleState> {
  final FlutterTts _flutterTts = FlutterTts();
  
  AudioBibleNotifier() : super(AudioBibleState()) {
    _initTts();
    _loadSettings();
  }
  
  Future<void> _initTts() async {
    await _flutterTts.setLanguage(state.selectedLanguage);
    await _flutterTts.setVolume(state.volume);
    await _flutterTts.setPitch(state.pitch);
    await _flutterTts.setSpeechRate(state.rate);
    
    _flutterTts.setStartHandler(() {
      state = state.copyWith(isSpeaking: true);
    });
    
    _flutterTts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false, currentVerse: null);
    });
    
    _flutterTts.setErrorHandler((message) {
      state = state.copyWith(isSpeaking: false, currentVerse: null);
      debugPrint('TTS Error: $message');
    });
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      volume: prefs.getDouble('tts_volume') ?? 1.0,
      pitch: prefs.getDouble('tts_pitch') ?? 1.0,
      rate: prefs.getDouble('tts_rate') ?? 0.5,
      selectedLanguage: prefs.getString('tts_language') ?? 'en-US',
    );
  }
  
  Future<void> speakVerse(String verse, {String? reference}) async {
    if (state.isSpeaking) {
      await stopSpeaking();
    }
    
    final normalizedVerse = _normalizeForTts(verse);
    if (normalizedVerse.isEmpty) return;
    
    // Truncate to safe limit for single verse
    String textToSpeak = reference != null 
        ? '$reference. $normalizedVerse' 
        : normalizedVerse;
        
    if (textToSpeak.length > 3500) {
      textToSpeak = textToSpeak.substring(0, 3500);
    }
    
    state = state.copyWith(currentVerse: textToSpeak);
    await _flutterTts.stop();
    
    // Apply current audio settings before speaking
    await _flutterTts.setVolume(state.volume);
    await _flutterTts.setPitch(state.pitch);
    await _flutterTts.setSpeechRate(state.rate);
    
    _flutterTts.speak(textToSpeak); // Fire and forget
  }
  
  Future<void> speakChapter(List<String> verses, String reference) async {
    if (state.isSpeaking) {
      await stopSpeaking();
    }
    
    // Normalize and limit text for TTS reliability
    final buffer = StringBuffer();
    buffer.write('$reference. ');
    
    for (final verse in verses) {
      final normalized = _normalizeForTts(verse);
      if (normalized.isEmpty) continue;
      
      // Strict limit for reliability across all Android engines
      if (buffer.length + normalized.length + 2 > 3500) break;
      buffer.write(normalized);
      buffer.write(' ');
    }
    
    final textToSpeak = buffer.toString().trim();
    if (textToSpeak.isEmpty) return;
    
    state = state.copyWith(currentVerse: textToSpeak);
    await _flutterTts.stop();
    
    // Apply current audio settings before speaking
    await _flutterTts.setVolume(state.volume);
    await _flutterTts.setPitch(state.pitch);
    await _flutterTts.setSpeechRate(state.rate);
    
    _flutterTts.speak(textToSpeak); // Fire and forget
  }
  
  String _normalizeForTts(String input) {
    // Remove characters that commonly break OEM TTS engines
    return input
        .replaceAll('¶', ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    state = state.copyWith(isSpeaking: false, currentVerse: null);
  }
  
  Future<void> pauseSpeaking() async {
    await _flutterTts.pause();
    state = state.copyWith(isSpeaking: false);
  }
  
  Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_volume', volume);
    await _flutterTts.setVolume(volume);
    state = state.copyWith(volume: volume);
  }
  
  Future<void> setPitch(double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
    await _flutterTts.setPitch(pitch);
    state = state.copyWith(pitch: pitch);
  }
  
  Future<void> setRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', rate);
    await _flutterTts.setSpeechRate(rate);
    state = state.copyWith(rate: rate);
  }
  
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_language', language);
    await _flutterTts.setLanguage(language);
    state = state.copyWith(selectedLanguage: language);
  }
  
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return List<String>.from(languages);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
