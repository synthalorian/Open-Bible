import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

/// Audio Bible widget with TTS controls
class AudioBibleWidget extends ConsumerWidget {
  final String verseText;
  final String? verseReference;
  final List<String>? chapterVerses;
  
  const AudioBibleWidget({
    super.key,
    required this.verseText,
    this.verseReference,
    this.chapterVerses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioBibleProvider);
    final audioNotifier = ref.read(audioBibleProvider.notifier);
    
    return Column(
      children: [
        // Main TTS button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: audioState.isSpeaking
                ? () => audioNotifier.stopSpeaking()
                : () => _startSpeaking(audioNotifier),
            icon: Icon(
              audioState.isSpeaking ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            label: Text(
              audioState.isSpeaking ? 'Stop' : 'Read Aloud',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: audioState.isSpeaking
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        
        // Audio controls (shown when speaking)
        if (audioState.isSpeaking) ...[
          const AudioControlsWidget(),
        ],
      ],
    );
  }
  
  void _startSpeaking(AudioBibleNotifier audioNotifier) {
    if (chapterVerses != null && chapterVerses!.isNotEmpty) {
      audioNotifier.speakChapter(chapterVerses!, verseReference ?? '');
    } else {
      audioNotifier.speakVerse(verseText, reference: verseReference);
    }
  }
}

/// Audio controls for volume, pitch, and rate
class AudioControlsWidget extends ConsumerWidget {
  const AudioControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioBibleProvider);
    final audioNotifier = ref.read(audioBibleProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Volume
          Row(
            children: [
              const Icon(Icons.volume_down, size: 20),
              Expanded(
                child: Slider(
                  value: audioState.volume,
                  onChanged: (value) => audioNotifier.setVolume(value),
                  min: 0,
                  max: 1,
                ),
              ),
              const Icon(Icons.volume_up, size: 20),
            ],
          ),
          
          // Speed
          Row(
            children: [
              const Text('Slow', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: audioState.rate,
                  onChanged: (value) => audioNotifier.setRate(value),
                  min: 0.0,
                  max: 1.0,
                ),
              ),
              const Text('Fast', style: TextStyle(fontSize: 12)),
            ],
          ),
          
          // Pitch
          Row(
            children: [
              const Text('Low', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: audioState.pitch,
                  onChanged: (value) => audioNotifier.setPitch(value),
                  min: 0.5,
                  max: 2.0,
                ),
              ),
              const Text('High', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact audio button for verses
class CompactAudioButton extends ConsumerWidget {
  final String verseText;
  final String? verseReference;
  
  const CompactAudioButton({
    super.key,
    required this.verseText,
    this.verseReference,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioBibleProvider);
    final audioNotifier = ref.read(audioBibleProvider.notifier);
    
    final isCurrentlyPlaying = audioState.currentVerse == verseText && audioState.isSpeaking;
    
    return IconButton(
      icon: Icon(
        isCurrentlyPlaying ? Icons.stop_circle : Icons.play_circle_outline,
        color: isCurrentlyPlaying
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        if (isCurrentlyPlaying) {
          audioNotifier.stopSpeaking();
        } else {
          audioNotifier.speakVerse(verseText, reference: verseReference);
        }
      },
      tooltip: isCurrentlyPlaying ? 'Stop' : 'Read Aloud',
    );
  }
}

/// Floating audio controls for bottom sheet
class FloatingAudioControls extends ConsumerWidget {
  const FloatingAudioControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioBibleProvider);
    final audioNotifier = ref.read(audioBibleProvider.notifier);
    
    if (!audioState.isSpeaking) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () => audioNotifier.stopSpeaking(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            audioState.currentVerse ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.replay_10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  // Replay last 10 seconds would be implemented here
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 36,
                ),
                onPressed: () => audioNotifier.stopSpeaking(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.forward_10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  // Forward 10 seconds would be implemented here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
