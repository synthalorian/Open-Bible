import 'package:flutter/material.dart';

import '../../data/models/christian_history_models.dart';
import '../widgets/history_detail_body.dart';

/// Swipeable gallery page for Christian History entries.
/// Opens from the category list and lets the user swipe left/right
/// between all entries in the current filtered list.
class HistoryGalleryPage extends StatefulWidget {
  final List<HistoryEntry> entries;
  final int initialIndex;
  final String categoryTitle;

  const HistoryGalleryPage({
    super.key,
    required this.entries,
    required this.categoryTitle,
    this.initialIndex = 0,
  });

  @override
  State<HistoryGalleryPage> createState() => _HistoryGalleryPageState();
}

class _HistoryGalleryPageState extends State<HistoryGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entries[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${entry.title} (${_currentIndex + 1}/${widget.entries.length})',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // Left arrow
          if (_currentIndex > 0)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          // Right arrow
          if (_currentIndex < widget.entries.length - 1)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.entries.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: HistoryDetailBody(entry: widget.entries[index]),
          );
        },
      ),
    );
  }
}
