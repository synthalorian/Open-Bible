import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/strongs_concordance_widget.dart';
import '../../presentation/widgets/strongs_concordance_widget.dart' as widgets;

/// Strong's Concordance page
class ConcordancePage extends StatelessWidget {
  const ConcordancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strong\'s Concordance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const StrongsFavoritesList(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const widgets.StrongsRecentSearches(),
          const Expanded(child: StrongsConcordanceWidget()),
        ],
      ),
    );
  }
}
