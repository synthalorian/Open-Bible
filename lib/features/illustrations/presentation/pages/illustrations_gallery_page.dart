import 'package:flutter/material.dart';

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
    BibleIllustration(
      title: 'Ezekiel Prophesying (Plate)',
      description: 'Ezekiel 37 - The prophet proclaims restoration',
      imagePath: 'assets/illustrations/dore_ezekiel_prophesying_plate.jpg',
      book: 'Ezekiel',
      chapter: 37,
    ),
    BibleIllustration(
      title: 'The World Destroyed by Water (Plate)',
      description: 'Genesis 7-8 - The Deluge sweeps the earth',
      imagePath: 'assets/illustrations/dore_world_destroyed_water_plate.jpg',
      book: 'Genesis',
      chapter: 7,
    ),
    BibleIllustration(
      title: 'Jesus Healing the Sick (Plate)',
      description: 'Matthew 8-9 - Christ heals the afflicted',
      imagePath: 'assets/illustrations/dore_jesus_healing_sick_plate.jpg',
      book: 'Matthew',
      chapter: 8,
    ),
    BibleIllustration(
      title: 'Death on the Pale Horse (Plate)',
      description: 'Revelation 6 - Apocalyptic judgment vision',
      imagePath: 'assets/illustrations/dore_death_on_pale_horse_plate.png',
      book: 'Revelation',
      chapter: 6,
    ),
    BibleIllustration(
      title: 'Raising Jairus\' Daughter (Plate)',
      description: 'Mark 5 - Jesus raises Jairus\' daughter',
      imagePath: 'assets/illustrations/dore_jairus_daughter_plate.jpg',
      book: 'Mark',
      chapter: 5,
    ),
    BibleIllustration(
      title: 'Walls of Jericho Falling Down (Plate)',
      description: 'Joshua 6 - The city walls collapse',
      imagePath: 'assets/illustrations/dore_walls_jericho_falling_plate.jpg',
      book: 'Joshua',
      chapter: 6,
    ),
    BibleIllustration(
      title: 'The Betrayal and Arrest of Christ (Plate)',
      description: 'Matthew 26 - Judas betrays Jesus',
      imagePath: 'assets/illustrations/dore_judas_kiss_arrest_plate.jpg',
      book: 'Matthew',
      chapter: 26,
    ),
    BibleIllustration(
      title: 'Render Unto Caesar (Plate)',
      description: 'Matthew 22 - Jesus answers the tribute question',
      imagePath: 'assets/illustrations/dore_render_unto_caesar_plate.jpg',
      book: 'Matthew',
      chapter: 22,
    ),
    BibleIllustration(
      title: 'Sermon on the Mount (Plate)',
      description: 'Matthew 5-7 - Jesus teaches the Beatitudes',
      imagePath: 'assets/illustrations/dore_sermon_on_mount_plate.jpg',
      book: 'Matthew',
      chapter: 5,
    ),
    BibleIllustration(
      title: 'The Death of Saul (Plate)',
      description: '1 Samuel 31 - Saul falls in battle',
      imagePath: 'assets/illustrations/dore_death_of_saul_plate.png',
      book: '1 Samuel',
      chapter: 31,
    ),
    BibleIllustration(
      title: 'Divine Light in the Clouds (Plate)',
      description: 'Exodus 33 - A prophet beholds divine glory',
      imagePath: 'assets/illustrations/dore_divine_light_clouds_plate.jpg',
      book: 'Exodus',
      chapter: 33,
    ),
    BibleIllustration(
      title: 'Moses with the Tablets (Plate)',
      description: 'Exodus 32 - Moses with the Law amid thunder',
      imagePath: 'assets/illustrations/dore_moses_tablets_thunder_plate.jpg',
      book: 'Exodus',
      chapter: 32,
    ),
    BibleIllustration(
      title: 'Crossing the Jordan (Plate)',
      description: 'Joshua 3 - Israel at the Jordan',
      imagePath: 'assets/illustrations/dore_crossing_jordan_plate.jpg',
      book: 'Joshua',
      chapter: 3,
    ),
    BibleIllustration(
      title: 'Nativity at the Manger (Plate)',
      description: 'Luke 2 - The birth of Christ',
      imagePath: 'assets/illustrations/dore_nativity_manger_plate.png',
      book: 'Luke',
      chapter: 2,
    ),
    BibleIllustration(
      title: 'The Triumphal Entry (Plate)',
      description: 'Matthew 21 - Jesus enters Jerusalem',
      imagePath: 'assets/illustrations/dore_triumphal_entry_plate.jpg',
      book: 'Matthew',
      chapter: 21,
    ),
    BibleIllustration(
      title: 'The Deluge (Children on the Rock) (Plate)',
      description: 'Genesis 7 - Flood waters rise',
      imagePath: 'assets/illustrations/dore_deluge_children_rock_plate.jpg',
      book: 'Genesis',
      chapter: 7,
    ),
    BibleIllustration(
      title: 'The Empty Tomb and Angel (Plate)',
      description: 'Matthew 28 - The resurrection announced',
      imagePath: 'assets/illustrations/dore_empty_tomb_angel_plate.png',
      book: 'Matthew',
      chapter: 28,
    ),
    BibleIllustration(
      title: 'The Gleaners (Plate)',
      description: 'Ruth 2 - Gathering grain in the fields',
      imagePath: 'assets/illustrations/dore_gleaners_plate.jpg',
      book: 'Ruth',
      chapter: 2,
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
