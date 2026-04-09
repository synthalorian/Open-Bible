import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'core/services/verse_storage_service.dart';

class DebugStoragePage extends StatefulWidget {
  const DebugStoragePage({super.key});

  @override
  State<DebugStoragePage> createState() => _DebugStoragePageState();
}

class _DebugStoragePageState extends State<DebugStoragePage> {
  Map<String, dynamic> _snapshot = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _snapshot = VerseStorageService.debugStorageSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Panel'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Persistence Diagnostics'),
          ElevatedButton(
            onPressed: () async {
              final result = await VerseStorageService.testNativeBridge();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('TEST CUSTOM NATIVE BRIDGE'),
          ),
          const SizedBox(height: 12),
          _buildInfo('Initialized', _snapshot['initialized'].toString()),
          _buildInfo('Has Prefs', _snapshot['hasPrefs'].toString()),
          _buildInfo('Backup Path', _snapshot['backupPath'] ?? 'N/A'),
          _buildInfo('Backup Exists', _snapshot['backupExists'].toString()),
          _buildInfo('Backup Bytes', _snapshot['backupBytes'].toString()),
          _buildInfo('Last Error', _snapshot['lastError'] ?? 'None', color: Colors.red),
          const Divider(),
          _buildInfo('Bookmarks Count', _snapshot['bookmarksCount'].toString()),
          _buildInfo('Highlights Count', _snapshot['highlightsCount'].toString()),
          _buildInfo('Notes Count', _snapshot['notesCount'].toString()),
          
          const SizedBox(height: 24),
          _buildSection('Audio Diagnostics'),
          ElevatedButton.icon(
            onPressed: () async {
              final tts = FlutterTts();
              await tts.setLanguage('en-US');
              await tts.speak('TTS engine test. Genesis 1 audio debugging active.');
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Test TTS (Hello World)'),
          ),

          const SizedBox(height: 24),
          _buildSection('System Actions'),
          ElevatedButton(
            onPressed: () async {
              await VerseStorageService.initialize(force: true);
              _refresh();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage Re-initialized')));
            },
            child: const Text('RETRY PLUGINS (RE-INIT)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await VerseStorageService.forceSave();
              _refresh();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual Save Triggered')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('FORCE SAVE TO DISK'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final raw = await VerseStorageService.getRawBackupJson();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Raw JSON'),
                  content: SingleChildScrollView(child: Text(raw, style: const TextStyle(fontSize: 10, fontFamily: 'monospace'))),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            },
            child: const Text('View Raw Backup File'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              await VerseStorageService.clearAll();
              _refresh();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Data Wiped')));
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Wipe All Saved Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildInfo(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: color))),
        ],
      ),
    );
  }
}
