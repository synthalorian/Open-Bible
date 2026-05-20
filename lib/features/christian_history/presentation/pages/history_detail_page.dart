import 'package:flutter/material.dart';

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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _AssetImageWithError(imagePath: entry.imageUrl!),
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

            const SizedBox(height: 16),

            // Denomination-specific fields
            if (entry.foundedBy != null ||
                entry.yearFounded != null ||
                entry.headquarters != null ||
                entry.adherents != null)
              _MetadataSection(title: 'Denomination Details', children: [
                if (entry.foundedBy != null)
                  _MetadataRow('Founded by', entry.foundedBy!),
                if (entry.yearFounded != null)
                  _MetadataRow('Year founded', entry.yearFounded!),
                if (entry.headquarters != null)
                  _MetadataRow('Headquarters', entry.headquarters!),
                if (entry.adherents != null)
                  _MetadataRow('Adherents', entry.adherents!),
              ]),

            // Cross-specific fields
            if (entry.crossType != null || entry.origin != null)
              _MetadataSection(title: 'Cross Details', children: [
                if (entry.crossType != null)
                  _MetadataRow('Cross type', entry.crossType!),
                if (entry.origin != null)
                  _MetadataRow('Origin', entry.origin!),
              ]),

            // Key Figures
            if (entry.keyFigures.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Key Figures',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.keyFigures
                    .map(
                      (figure) => Chip(
                        avatar: const Icon(Icons.person, size: 16),
                        label: Text(figure),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Key Events
            if (entry.keyEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Key Events',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...entry.keyEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•  ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          event,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Full description
            const SizedBox(height: 16),
            Text(
              entry.description,
              style: theme.textTheme.bodyLarge,
            ),

            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags
                    .map(
                      (tag) => Chip(
                        labelStyle: theme.textTheme.labelSmall,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        label: Text(tag),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Bottom padding for scroll comfort
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// A section card for grouped metadata rows (e.g., denomination details).
class _MetadataSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _MetadataSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

/// A single key-value row inside a metadata section.
class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loads an asset image with graceful error handling.
class _AssetImageWithError extends StatelessWidget {
  final String imagePath;

  const _AssetImageWithError({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
