import 'package:flutter/material.dart';

import '../../data/models/christian_history_models.dart';
import 'history_detail_page.dart';

/// Generic list page for any history category.
/// Shows a searchable list of entries that belong to the given category.
class HistoryCategoryPage extends StatefulWidget {
  final HistoryCategory category;

  const HistoryCategoryPage({super.key, required this.category});

  @override
  State<HistoryCategoryPage> createState() => _HistoryCategoryPageState();
}

class _HistoryCategoryPageState extends State<HistoryCategoryPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<HistoryEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _filteredEntries = widget.category.entries;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _searchQuery = query;
      _filteredEntries = _filterEntries(query);
    });
  }

  List<HistoryEntry> _filterEntries(String query) {
    if (query.isEmpty) return widget.category.entries;

    return widget.category.entries.where((entry) {
      final titleMatch = entry.title.toLowerCase().contains(query);
      final subtitleMatch = entry.subtitle.toLowerCase().contains(query);
      final tagsMatch =
          entry.tags.any((tag) => tag.toLowerCase().contains(query));
      return titleMatch || subtitleMatch || tagsMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search ${widget.category.title.toLowerCase()}…',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
              ],
            ),
          ),
          // Entry list
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return _EntryListTile(
                        entry: entry,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoryDetailPage(entry: entry),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EntryListTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;

  const _EntryListTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.period != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.period!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
