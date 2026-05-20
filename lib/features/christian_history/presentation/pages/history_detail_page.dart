import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../data/models/christian_history_models.dart';

/// Detail view for any history entry.
/// Displays full information including image, metadata, key figures, events,
/// and the complete description text.
class HistoryDetailPage extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            if (entry.imageUrl != null)
              SizedBox(
                width: double.infinity,
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _HistoryImage(imagePath: entry.imageUrl!),
                ),
              ),

            if (entry.imageUrl != null) const SizedBox(height: 16),

            // Title
            Text(
              entry.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              entry.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Period & Location badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (entry.period != null)
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(entry.period!),
                  ),
                if (entry.location != null)
                  Chip(
                    avatar: const Icon(Icons.place, size: 16),
                    label: Text(entry.location!),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Denomination details
            if (entry.foundedBy != null ||
                entry.yearFounded != null ||
                entry.headquarters != null ||
                entry.adherents != null) ...[
              const _SectionHeader(title: 'Denomination Details'),
              _InfoRow(label: 'Founded By', value: entry.foundedBy),
              _InfoRow(label: 'Year Founded', value: entry.yearFounded),
              _InfoRow(label: 'Headquarters', value: entry.headquarters),
              _InfoRow(label: 'Adherents', value: entry.adherents),
              const SizedBox(height: 8),
            ],

            // Cross details
            if (entry.crossType != null || entry.origin != null) ...[
              const _SectionHeader(title: 'Cross Details'),
              _InfoRow(label: 'Cross type', value: entry.crossType),
              _InfoRow(label: 'Origin', value: entry.origin),
              const SizedBox(height: 8),
            ],

            // Key Figures
            if (entry.keyFigures.isNotEmpty) ...[
              const _SectionHeader(title: 'Key Figures'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.keyFigures.map((figure) {
                  return Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(figure),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Key Events
            if (entry.keyEvents.isNotEmpty) ...[
              const _SectionHeader(title: 'Key Events'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entry.keyEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(event)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Description
            const _SectionHeader(title: 'Description'),
            const SizedBox(height: 8),
            Text(
              entry.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'CrimsonText',
                height: 1.8,
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags.map((tag) {
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    label: Text(tag, style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Image loader that tries [Image.asset] and falls back to [rootBundle]+[Image.memory].
class _HistoryImage extends StatefulWidget {
  final String imagePath;
  const _HistoryImage({required this.imagePath});

  @override
  State<_HistoryImage> createState() => _HistoryImageState();
}

class _HistoryImageState extends State<_HistoryImage> {
  ImageProvider? _image;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Try direct bundle load + memory decode
      final data = await rootBundle.load(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _image = MemoryImage(data.buffer.asUint8List());
        _error = null;
      });
      debugPrint('Image loaded: ${widget.imagePath} (${data.lengthInBytes} bytes)');
    } catch (e) {
      debugPrint('Image FAILED: ${widget.imagePath}: $e');
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return Image(
        image: _image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      );
    }

    // Show loading or error
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _error != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Image unavailable',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }
}

/// Section header label
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Key-value info row
class _InfoRow extends StatelessWidget {
  final String? label;
  final String? value;

  const _InfoRow({this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
