import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Audio service for Bible audio playback
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  /// Initialize audio service
  Future<void> init() async {
    if (_initialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    ));

    _initialized = true;
  }

  /// Current playing state
  Stream<bool> get playingStream => _player.playingStream;

  /// Current position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Duration stream
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Speed stream
  Stream<double> get speedStream => _player.speedStream;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Current playback speed
  double get speed => _player.speed;

  /// Current position
  Duration get position => _player.position;

  /// Total duration
  Duration? get duration => _player.duration;

  /// Set audio URL
  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  /// Set audio file path
  Future<void> setFilePath(String path) async {
    await _player.setFilePath(path);
  }

  /// Play audio
  Future<void> play() async {
    await _player.play();
  }

  /// Pause audio
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop audio
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Skip forward by given seconds
  Future<void> skipForward({int seconds = 30}) async {
    final newPosition = position + Duration(seconds: seconds);
    await seek(newPosition);
  }

  /// Skip backward by given seconds
  Future<void> skipBackward({int seconds = 30}) async {
    final newPosition = position - Duration(seconds: seconds);
    if (newPosition.isNegative) {
      await seek(Duration.zero);
    } else {
      await seek(newPosition);
    }
  }

  /// Dispose audio player
  void dispose() {
    _player.dispose();
  }
}

/// Provider for audio service
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Audio state
class AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final double speed;
  final String? currentChapter;
  final bool isLoading;
  final String? error;

  const AudioState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration,
    this.speed = 1.0,
    this.currentChapter,
    this.isLoading = false,
    this.error,
  });

  double get progress {
    if (duration == null || duration!.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration!.inMilliseconds;
  }

  AudioState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentChapter,
    bool? isLoading,
    String? error,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentChapter: currentChapter ?? this.currentChapter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Audio controller notifier
class AudioController extends StateNotifier<AudioState> {
  final AudioService _audioService;

  AudioController(this._audioService) : super(const AudioState()) {
    _init();
  }

  void _init() {
    _audioService.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _audioService.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioService.durationStream.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _audioService.speedStream.listen((speed) {
      state = state.copyWith(speed: speed);
    });
  }

  Future<void> playChapter(String bookId, int chapter) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // In real app, get URL from API
      // final url = await _apiService.getAudioUrl(bookId, chapter);
      // await _audioService.setUrl(url);
      
      state = state.copyWith(
        currentChapter: '$bookId $chapter',
        isLoading: false,
      );
      
      await _audioService.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
  }

  Future<void> skipForward() async {
    await _audioService.skipForward();
  }

  Future<void> skipBackward() async {
    await _audioService.skipBackward();
  }

  Future<void> stop() async {
    await _audioService.stop();
    state = const AudioState();
  }
}

/// Provider for audio controller
final audioControllerProvider = StateNotifierProvider<AudioController, AudioState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioController(audioService);
});
