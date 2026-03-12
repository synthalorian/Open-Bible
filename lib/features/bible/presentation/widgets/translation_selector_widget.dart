import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Translation selector widget for switching Bible translations
class TranslationSelectorWidget extends ConsumerWidget {
  final bool isExpanded;
  final Color? textColor;
  
  const TranslationSelectorWidget({
    super.key,
    this.isExpanded = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTranslationId = ref.watch(selectedTranslationProvider);
    final downloadManager = ref.watch(bibleDownloadManagerProvider);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedTranslationId,
        isExpanded: isExpanded,
        icon: Icon(
          Icons.arrow_drop_down,
          color: textColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
        dropdownColor: Theme.of(context).colorScheme.primary,
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        items: availableTranslations.map((translation) {
          final isDownloaded = downloadManager.isVersionAvailable(translation.id);
          
          return DropdownMenuItem<String>(
            value: translation.id,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translation.abbreviation,
                      style: TextStyle(
                        color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isDownloaded) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.download, size: 14, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
                    ],
                  ],
                ),
                if (isExpanded)
                  Text(
                    translation.name,
                    style: TextStyle(
                      color: (textColor ?? Theme.of(context).colorScheme.onPrimary).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) async {
          if (value == null) return;
          
          // Check if downloaded
          if (!downloadManager.isVersionAvailable(value)) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Download ${value.toUpperCase()}?'),
                content: const Text('This translation needs to be downloaded for offline use.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Download'),
                  ),
                ],
              ),
            );
            
            if (confirm == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${value.toUpperCase()}...')),
              );
              
              final success = await downloadManager.downloadVersion(value);
              if (success) {
                ref.read(selectedTranslationProvider.notifier).state = value;
                ref.read(bibleDataProvider.notifier).selectTranslation(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download failed. Check your connection.')),
                );
              }
            }
          } else {
            ref.read(selectedTranslationProvider.notifier).state = value;
            ref.read(bibleDataProvider.notifier).selectTranslation(value);
          }
        },
      ),
    );
  }
}

/// Compact translation selector for app bars
class CompactTranslationSelector extends ConsumerWidget {
  const CompactTranslationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTranslationId = ref.watch(selectedTranslationProvider);
    final downloadManager = ref.watch(bibleDownloadManagerProvider);
    
    final currentTranslation = availableTranslations.firstWhere(
      (t) => t.id == selectedTranslationId,
      orElse: () => availableTranslations.first,
    );

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currentTranslation.abbreviation,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      onSelected: (value) async {
        // Check if downloaded
        if (!downloadManager.isVersionAvailable(value)) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Download ${value.toUpperCase()}?'),
              content: const Text('This translation needs to be downloaded for offline use.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Download'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading ${value.toUpperCase()}...')),
            );
            
            final success = await downloadManager.downloadVersion(value);
            if (success) {
              ref.read(selectedTranslationProvider.notifier).state = value;
              ref.read(bibleDataProvider.notifier).selectTranslation(value);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download failed. Check your connection.')),
              );
            }
          }
        } else {
          ref.read(selectedTranslationProvider.notifier).state = value;
          ref.read(bibleDataProvider.notifier).selectTranslation(value);
        }
      },
      itemBuilder: (context) => availableTranslations.map((translation) {
        final isDownloaded = downloadManager.isVersionAvailable(translation.id);
        
        return PopupMenuItem<String>(
          value: translation.id,
          child: ListTile(
            title: Text(translation.abbreviation),
            subtitle: Text(translation.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDownloaded)
                  const Icon(Icons.download, size: 16, color: Colors.grey),
                if (translation.id == selectedTranslationId)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
