import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/services/verse_storage_service.dart';
import '../../../../debug_storage_page.dart';
import '../../../../core/services/notification_service.dart';

/// Settings page - app preferences
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Reading Settings
          _buildSectionHeader('Reading'),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Text('${settings.fontSize}'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: settings.fontSize.toDouble(),
                min: 12,
                max: 32,
                divisions: 10,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setFontSize(value.round());
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Reading Mode'),
            subtitle: Text(_getReadingModeName(settings.readingMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReadingModeSelector(),
          ),
          
          const Divider(),
          
          // Notifications
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Daily Verse Notifications'),
            subtitle: const Text('Receive a verse each day'),
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              final notifier = ref.read(settingsProvider.notifier);
              final service = ref.read(notificationServiceProvider);
              await service.init();

              if (value) {
                final granted = await service.requestPermissions();
                if (!granted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification permission denied. Enable it in system settings.')),
                    );
                  }
                  return;
                }

                if (!settings.notificationsEnabled) {
                  await notifier.toggleNotifications();
                }
                await service.scheduleDailyVerse(
                  hour: settings.dailyVerseTime.hour,
                  minute: settings.dailyVerseTime.minute,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daily verse notifications enabled.')),
                  );
                }
              } else {
                if (settings.notificationsEnabled) {
                  await notifier.toggleNotifications();
                }
                await service.cancelDailyVerse();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Notification Time'),
            subtitle: Text(_formatTime(settings.dailyVerseTime)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickNotificationTime(settings),
          ),
          
          const Divider(),
          
          // Data & Storage
          _buildSectionHeader('Data & Storage'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Cache', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Clear all cached Bible data'),
            onTap: () => _clearCache(),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_remove, color: Colors.red),
            title: const Text('Clear All Saved Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Remove all bookmarks, highlights, and notes'),
            onTap: () => _clearAllSavedData(),
          ),
          
          const Divider(),
          
          // Debug
          _buildSectionHeader('Debug'),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Storage Debug'),
            subtitle: const Text('Check saved data'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugStoragePage(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // About
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('Open Bible v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: const Text('Made with ❤️'),
            subtitle: const Text('100% Offline • Open Source • Free Forever'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getReadingModeName(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.day:
        return 'Day Mode';
      case ReadingMode.night:
        return 'Night Mode';
      case ReadingMode.sepia:
        return 'Sepia Mode';
      case ReadingMode.amoled:
        return 'AMOLED Mode';
    }
  }

  void _showReadingModeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReadingModeOption(ReadingMode.day, 'Day Mode', Icons.light_mode),
            _buildReadingModeOption(ReadingMode.night, 'Night Mode', Icons.dark_mode),
            _buildReadingModeOption(ReadingMode.sepia, 'Sepia Mode', Icons.auto_stories),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingModeOption(ReadingMode mode, String name, IconData icon) {
    final settings = ref.watch(settingsProvider);
    final isSelected = settings.readingMode == mode;

    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setReadingMode(mode);
        Navigator.pop(context);
      },
    );
  }

  String _formatTime(DailyVerseTime time) {
    final dt = DateTime(2000, 1, 1, time.hour, time.minute);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _pickNotificationTime(AppSettings settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dailyVerseTime.hour,
        minute: settings.dailyVerseTime.minute,
      ),
    );

    if (picked == null) return;

    await ref.read(settingsProvider.notifier).setDailyVerseTime(
      DailyVerseTime(hour: picked.hour, minute: picked.minute),
    );

    if (settings.notificationsEnabled) {
      final service = ref.read(notificationServiceProvider);
      await service.init();
      await service.scheduleDailyVerse(hour: picked.hour, minute: picked.minute);
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached Bible data. Your bookmarks, highlights, and notes will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAllSavedData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Saved Data'),
        content: const Text('This will permanently delete all your bookmarks, highlights, and notes. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Clear all saved data
              await VerseStorageService.clearAll();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All saved data cleared!')),
              );
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
