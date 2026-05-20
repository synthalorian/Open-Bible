import 'package:flutter/material.dart';

import '../../data/models/christian_history_models.dart';
import '../widgets/history_detail_body.dart';

/// Legacy single-entry detail view.
/// For multi-entry browsing, use [HistoryGalleryPage] instead.
class HistoryDetailPage extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HistoryDetailBody(entry: entry),
      ),
    );
  }
}
