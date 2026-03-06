import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Concordance page - Strong's Greek & Hebrew word lookup
class ConcordancePage extends ConsumerStatefulWidget {
  const ConcordancePage({super.key});

  @override
  ConsumerState<ConcordancePage> createState() => _ConcordancePageState();
}

class _ConcordancePageState extends ConsumerState<ConcordancePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'both'; // 'greek', 'hebrew', or 'both'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concordance'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedLanguage = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'both', child: Text('All')),
              const PopupMenuItem(value: 'greek', child: Text('Greek Only')),
              const PopupMenuItem(value: 'hebrew', child: Text('Hebrew Only')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Strong\'s numbers or words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // Mock data for demonstration
    final words = [
      {'number': 'G26', 'word': 'agape', 'meaning': 'love, goodwill, benevolence'},
      {'number': 'H157', 'word': 'ahab', 'meaning': 'to love, human or divine'},
      {'number': 'G4102', 'word': 'pistis', 'meaning': 'faith, belief, trust'},
      {'number': 'H539', 'word': 'aman', 'meaning': 'to confirm, support, believe'},
      {'number': 'G5485', 'word': 'charis', 'meaning': 'grace, favor, kindness'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isGreek = word['number']!.startsWith('G');
        
        if (_selectedLanguage == 'greek' && !isGreek) return const SizedBox.shrink();
        if (_selectedLanguage == 'hebrew' && isGreek) return const SizedBox.shrink();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isGreek
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                isGreek ? 'G' : 'H',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isGreek
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  word['word']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    word['number']!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            subtitle: Text(word['meaning']!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showWordDetails(word),
          ),
        );
      },
    );
  }

  void _showWordDetails(Map<String, String> word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    word['word']!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Merriweather',
                        ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      word['number']!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Definition',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                word['meaning']!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Usage in Scripture',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'This word appears 143 times in the New Testament.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text(
                'Example verses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ExampleVerse(
                reference: 'John 3:16',
                text: 'For God so loved the world...',
              ),
              _ExampleVerse(
                reference: '1 John 4:8',
                text: 'God is love.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleVerse extends StatelessWidget {
  final String reference;
  final String text;

  const _ExampleVerse({
    required this.reference,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          reference,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        subtitle: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
