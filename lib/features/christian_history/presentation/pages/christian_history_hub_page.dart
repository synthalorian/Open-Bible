import 'package:flutter/material.dart';

import '../../data/models/christian_history_models.dart';
import '../pages/history_category_page.dart';
import '../widgets/history_category_card.dart';

/// Main hub page for Christian History feature.
/// Displays a grid of categories that users can tap to explore.
class ChristianHistoryHubPage extends StatefulWidget {
  const ChristianHistoryHubPage({super.key});

  @override
  State<ChristianHistoryHubPage> createState() =>
      _ChristianHistoryHubPageState();
}

class _ChristianHistoryHubPageState extends State<ChristianHistoryHubPage> {
  ChristianHistoryData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ChristianHistoryData.load();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Christian History')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final categories = _data!.categories;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return HistoryCategoryCard(
          category: category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryCategoryPage(category: category),
            ),
          ),
        );
      },
    );
  }
}
