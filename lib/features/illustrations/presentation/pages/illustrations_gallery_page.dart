import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bible Illustrations Gallery - Gustave Doré and other classic biblical artwork
class IllustrationsGalleryPage extends StatelessWidget {
  const IllustrationsGalleryPage({super.key});

  final List<BibleIllustration> illustrations = const [
    BibleIllustration(
      title: 'Joseph Makes Himself Known',
      description: 'Genesis 45 - Joseph reveals his identity to his brothers in Egypt',
      imagePath: 'assets/images/bible_illustrations/joseph_brethren.jpg',
      book: 'Genesis',
      chapter: 45,
    ),
    BibleIllustration(
      title: 'The Ascension',
      description: 'Acts 1 - Jesus ascends into heaven before the disciples',
      imagePath: 'assets/images/bible_illustrations/ascension.jpg',
      book: 'Acts',
      chapter: 1,
    ),
    BibleIllustration(
      title: 'Tower of Babel',
      description: 'Genesis 11 - The confusion of languages',
      imagePath: 'assets/images/bible_illustrations/tower_babel.jpg',
      book: 'Genesis',
      chapter: 11,
    ),
    BibleIllustration(
      title: 'The Baptism of Jesus',
      description: 'Matthew 3 - John baptizes Jesus in the Jordan',
      imagePath: 'assets/images/bible_illustrations/baptism.jpg',
      book: 'Matthew',
      chapter: 3,
    ),
    BibleIllustration(
      title: 'Vision of Ezekiel',
      description: 'Ezekiel 1 - The chariot of God with living creatures',
      imagePath: 'assets/images/bible_illustrations/vision_ezekiel.jpg',
      book: 'Ezekiel',
      chapter: 1,
    ),
    BibleIllustration(
      title: 'Nailed to the Cross',
      description: 'Matthew 27 - The crucifixion of Christ',
      imagePath: 'assets/images/bible_illustrations/nailing_cross.jpg',
      book: 'Matthew',
      chapter: 27,
    ),
    BibleIllustration(
      title: 'Jonah Preaches to Nineveh',
      description: 'Jonah 3 - The prophet calls the city to repentance',
      imagePath: 'assets/images/bible_illustrations/jonah_nineveh.jpg',
      book: 'Jonah',
      chapter: 3,
    ),
    BibleIllustration(
      title: 'The Death of Saul',
      description: '1 Samuel 31 - Israel\'s first king falls in battle',
      imagePath: 'assets/images/bible_illustrations/death_saul.jpg',
      book: '1 Samuel',
      chapter: 31,
    ),
    BibleIllustration(
      title: 'The Dead Christ',
      description: 'Mark 15 - Jesus taken down from the cross',
      imagePath: 'assets/images/bible_illustrations/dead_christ.jpg',
      book: 'Mark',
      chapter: 15,
    ),
    BibleIllustration(
      title: 'The Angelic Chariot',
      description: '2 Kings 6 - Elisha surrounded by heavenly hosts',
      imagePath: 'assets/images/bible_illustrations/angelic_chariot.jpg',
      book: '2 Kings',
      chapter: 6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bible Illustrations'),
            Text(
              'Gustave Doré Gallery',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: illustrations.length,
        itemBuilder: (context, index) {
          final illustration = illustrations[index];
          return _buildIllustrationCard(context, illustration);
        },
      ),
    );
  }

  Widget _buildIllustrationCard(BuildContext context, BibleIllustration illustration) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showIllustrationDetail(context, illustration),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: illustration.imagePath,
                child: Image.asset(
                  illustration.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    illustration.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${illustration.book} ${illustration.chapter}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIllustrationDetail(BuildContext context, BibleIllustration illustration) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IllustrationDetailPage(illustration: illustration),
      ),
    );
  }
}

class IllustrationDetailPage extends StatelessWidget {
  final BibleIllustration illustration;

  const IllustrationDetailPage({super.key, required this.illustration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        title: Text(illustration.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: illustration.imagePath,
                  child: Image.asset(
                    illustration.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  illustration.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  illustration.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${illustration.book} ${illustration.chapter}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Artwork by Gustave Doré',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BibleIllustration {
  final String title;
  final String description;
  final String imagePath;
  final String book;
  final int chapter;

  const BibleIllustration({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.book,
    required this.chapter,
  });
}
