import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/bible_download_manager.dart';

/// Bible downloads page - manage offline Bible versions
class BibleDownloadsPage extends ConsumerStatefulWidget {
  const BibleDownloadsPage({super.key});

  @override
  ConsumerState<BibleDownloadsPage> createState() => _BibleDownloadsPageState();
}

class _BibleDownloadsPageState extends ConsumerState<BibleDownloadsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(bibleDownloadManagerProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final downloadManager = ref.watch(bibleDownloadManagerProvider);
    final installedVersions = downloadManager.installedVersions;
    final downloadableVersions = downloadManager.downloadableVersions;
    final progress = downloadManager.downloadProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Downloads'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Total Bible storage: ${downloadManager.totalStorageUsed.toStringAsFixed(1)} MB'),
                ),
              );
            },
            icon: const Icon(Icons.storage),
            label: Text(
              '${downloadManager.totalStorageUsed.toStringAsFixed(1)} MB',
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Installed section
          if (installedVersions.isNotEmpty) ...[
            _buildSectionHeader('Installed'),
            ...installedVersions.map((version) => _buildVersionTile(
              version: version,
              isInstalled: true,
              progress: progress[version.id],
            )),
          ],
          
          // Available section
          if (downloadableVersions.isNotEmpty) ...[
            _buildSectionHeader('Available for Download'),
            ...downloadableVersions.map((version) => _buildVersionTile(
              version: version,
              isInstalled: false,
              progress: progress[version.id],
            )),
          ],
          
          // Info section
          _buildSectionHeader('About Downloads'),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Bibles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• All 20 Bible translations are included with the app\n'
                      '• Every translation works offline — no downloads needed\n'
                      '• Switch between versions anytime from the reader',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildVersionTile({
    required BibleVersionInfo version,
    required bool isInstalled,
    DownloadProgress? progress,
  }) {
    final isDownloading = progress?.status == DownloadStatus.downloading;
    final isCompleted = progress?.status == DownloadStatus.completed || 
                        (isInstalled && !version.isBundled);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: version.isPublicDomain 
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        child: Text(
          version.abbreviation,
          style: TextStyle(
            fontSize: 12,
            color: version.isPublicDomain ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(version.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(version.description),
          Text(
            '${version.sizeMB.toStringAsFixed(1)} MB • ${version.language}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                value: progress?.progress ?? 0,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
      trailing: _buildTrailingButton(
        version: version,
        isInstalled: isInstalled,
        isDownloading: isDownloading,
        isCompleted: isCompleted,
      ),
    );
  }

  Widget _buildTrailingButton({
    required BibleVersionInfo version,
    required bool isInstalled,
    required bool isDownloading,
    required bool isCompleted,
  }) {
    if (version.isBundled) {
      return const Chip(
        label: Text('Included'),
        backgroundColor: Colors.green,
        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
      );
    }

    if (isDownloading) {
      return IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: () {
          // Cancel download
        },
      );
    }

    if (isCompleted) {
      return PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'delete') {
            _showDeleteDialog(version);
          }
        },
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _downloadVersion(version),
      icon: const Icon(Icons.download),
      label: const Text('Get'),
    );
  }

  Future<void> _downloadVersion(BibleVersionInfo version) async {
    final manager = ref.read(bibleDownloadManagerProvider);
    final success = await manager.downloadVersion(version.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? '${version.name} downloaded successfully!'
                : 'Failed to download ${version.name}',
          ),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(BibleVersionInfo version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${version.name}?'),
        content: Text(
          'This will remove ${version.sizeMB.toStringAsFixed(1)} MB of offline content. '
          'You can re-download it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bibleDownloadManagerProvider).deleteVersion(version.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${version.name} deleted')),
        );
      }
    }
  }
}
