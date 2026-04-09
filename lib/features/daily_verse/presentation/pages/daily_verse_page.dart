import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/current_bible.dart';
import '../../../../core/services/verse_storage_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/notification_service.dart';

/// Daily verse page - verse of the day
class DailyVersePage extends ConsumerStatefulWidget {
  const DailyVersePage({super.key});

  @override
  ConsumerState<DailyVersePage> createState() => _DailyVersePageState();
}

class _DailyVersePageState extends ConsumerState<DailyVersePage> {
  late DailyVerse _dailyVerse;
  bool _isBookmarked = false;
  String? _note;

  @override
  void initState() {
    super.initState();
    _dailyVerse = _getDailyVerse();
    _checkBookmarkStatus();
    _checkNoteStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    // Create a verse ID for the daily verse
    final verseId = 'daily_${_dailyVerse.bookId}_${_dailyVerse.chapter}_${_dailyVerse.verse}';
    await VerseStorageService.initialize();
    final isBookmarked = VerseStorageService.isBookmarked(verseId);
    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _checkNoteStatus() async {
    final verseId = 'daily_${_dailyVerse.bookId}_${_dailyVerse.chapter}_${_dailyVerse.verse}';
    await VerseStorageService.initialize();
    final note = VerseStorageService.getNote(verseId);
    if (mounted) {
      setState(() => _note = note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Verse'),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Date header
            Text(
              _formatDate(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Verse card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Decorative quote mark
                  Text(
                    '"',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.3),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Verse text
                  Text(
                    _dailyVerse.text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'CrimsonText',
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Reference
                  Text(
                    _dailyVerse.reference,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  label: _isBookmarked ? 'Saved' : 'Bookmark',
                  isActive: _isBookmarked,
                  onTap: _bookmarkVerse,
                ),
                _ActionButton(
                  icon: _note != null ? Icons.edit_note : Icons.note_add_outlined,
                  label: _note != null ? 'Edit Note' : 'Note',
                  isActive: _note != null,
                  onTap: _addNote,
                ),
                _ActionButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  onTap: _copyVerse,
                ),

              ],
            ),
            
            const SizedBox(height: 40),
            
            // Reflection section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reflection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dailyVerse.reflection,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Questions to ponder:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._dailyVerse.questions.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(q)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Related verses
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Related Verses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            ..._dailyVerse.relatedVerses.map((verse) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: Text(verse),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to verse
                      _navigateToVerse(verse);
                    },
                  ),
                )),
            
            const SizedBox(height: 32),
            
            // Notification settings
            Card(
              child: SwitchListTile(
                title: const Text('Daily Verse Notifications'),
                subtitle: const Text('Get notified with a new verse each day'),
                value: ref.watch(settingsProvider).dailyVerseNotifications,
                onChanged: (value) async {
                  await ref.read(settingsProvider.notifier).setDailyVerseNotifications(value);
                  final service = ref.read(notificationServiceProvider);
                  await service.init();

                  if (value) {
                    await _scheduleDailyNotification();
                  } else {
                    await service.cancelDailyVerse();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVerse(String reference) {
    // Parse reference like "Romans 8:28" or "Proverbs 3:5-6"
    // For now just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $reference...')),
    );
  }

  Future<void> _bookmarkVerse() async {
    final verseId = 'daily_${_dailyVerse.bookId}_${_dailyVerse.chapter}_${_dailyVerse.verse}';
    
    if (_isBookmarked) {
      await VerseStorageService.removeBookmark(verseId);
      if (!mounted) return;
      setState(() => _isBookmarked = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      }
    } else {
      final savedVerse = SavedVerse(
        id: verseId,
        bookId: _dailyVerse.bookId,
        bookName: _dailyVerse.bookName,
        chapter: _dailyVerse.chapter,
        verse: _dailyVerse.verse,
        text: _dailyVerse.text,
        savedAt: DateTime.now(),
        bibleId: CurrentBible.id,
      );
      await VerseStorageService.addBookmark(savedVerse);
      if (!mounted) return;
      setState(() => _isBookmarked = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verse bookmarked!')),
        );
      }
    }
  }

  Future<void> _addNote() async {
    final verseId = 'daily_${_dailyVerse.bookId}_${_dailyVerse.chapter}_${_dailyVerse.verse}';
    final controller = TextEditingController(text: _note ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your thoughts on this verse...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          if (_note != null)
            TextButton(
              onPressed: () async {
                await VerseStorageService.removeNote(verseId);
                if (!context.mounted) return;
                Navigator.pop(context, '');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result.isEmpty) {
        await VerseStorageService.removeNote(verseId);
        if (!mounted) return;
        setState(() => _note = null);
      } else {
        final savedVerse = SavedVerse(
          id: verseId,
          bookId: _dailyVerse.bookId,
          bookName: _dailyVerse.bookName,
          chapter: _dailyVerse.chapter,
          verse: _dailyVerse.verse,
          text: _dailyVerse.text,
          savedAt: DateTime.now(),
          bibleId: CurrentBible.id,
        );
        await VerseStorageService.saveNote(savedVerse, result);
        if (!mounted) return;
        setState(() => _note = result);
      }
    }
  }

  Future<void> _copyVerse() async {
    final copyText = '${_dailyVerse.reference}\n\n${_dailyVerse.text}';
    await Clipboard.setData(ClipboardData(text: copyText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse copied to clipboard!')),
      );
    }
  }


  Future<void> _scheduleDailyNotification() async {
    final settings = ref.read(settingsProvider);
    final service = ref.read(notificationServiceProvider);
    await service.init();
    final granted = await service.requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission denied.')),
        );
      }
      return;
    }

    await service.scheduleDailyVerse(
      hour: settings.dailyVerseTime.hour,
      minute: settings.dailyVerseTime.minute,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily notifications enabled!')),
      );
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  DailyVerse _getDailyVerse() {
    // In a real app, this would be selected based on the date
    // For now return Jeremiah 29:11
    return DailyVerse(
      text: 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.',
      reference: 'Jeremiah 29:11',
      bookId: 'jeremiah',
      bookName: 'Jeremiah',
      chapter: 29,
      verse: 11,
      reflection: 'This verse reminds us that God is in control and has good plans for our lives. Even when we face uncertainty or difficulty, we can trust in His sovereignty and love.',
      questions: [
        'What plans do you think God has for your life?',
        'How can trusting in God\'s plans bring you peace today?',
        'What step of faith is God calling you to take?',
      ],
      relatedVerses: [
        'Romans 8:28',
        'Proverbs 3:5-6',
        'Psalm 33:11',
      ],
    );
  }
}

class DailyVerse {
  final String text;
  final String reference;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String reflection;
  final List<String> questions;
  final List<String> relatedVerses;

  const DailyVerse({
    required this.text,
    required this.reference,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.reflection,
    required this.questions,
    required this.relatedVerses,
  });
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 28,
              color: isActive ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isActive ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
