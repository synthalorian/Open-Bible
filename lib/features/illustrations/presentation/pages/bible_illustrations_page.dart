import 'package:flutter/material.dart';

/// Bible illustration model
class BibleIllustration {
  final String id;
  final String title;
  final String description;
  final String bibleReference;
  final Color color;
  final IconData icon;
  final String assetPath;
  
  const BibleIllustration({
    required this.id,
    required this.title,
    required this.description,
    required this.bibleReference,
    required this.color,
    required this.icon,
    required this.assetPath,
  });
}

/// Classic Bible illustrations
final List<BibleIllustration> bibleIllustrations = [
  BibleIllustration(
    id: 'creation',
    title: 'The Creation',
    description: 'In the beginning, God created the heavens and the earth. Light separates from darkness.',
    bibleReference: 'Genesis 1:1-5',
    color: const Color(0xFF1A237E),
    icon: Icons.wb_sunny,
    assetPath: 'assets/illustrations/creation.jpg',
  ),
  BibleIllustration(
    id: 'adam_eve',
    title: 'Adam and Eve',
    description: 'God creates man in His own image and places him in the Garden of Eden.',
    bibleReference: 'Genesis 2:7-25',
    color: const Color(0xFF2E7D32),
    icon: Icons.park,
    assetPath: 'assets/illustrations/adam_eve.jpg',
  ),
  BibleIllustration(
    id: 'noah',
    title: "Noah's Ark",
    description: 'Noah builds the ark and gathers the animals before the great flood.',
    bibleReference: 'Genesis 6-9',
    color: const Color(0xFF0277BD),
    icon: Icons.directions_boat,
    assetPath: 'assets/illustrations/noah.jpg',
  ),
  BibleIllustration(
    id: 'babel',
    title: 'The Tower of Babel',
    description: 'Humans build a tower to heaven, but God confuses their languages.',
    bibleReference: 'Genesis 11:1-9',
    color: const Color(0xFF5D4037),
    icon: Icons.account_balance,
    assetPath: 'assets/illustrations/babel.jpg',
  ),
  BibleIllustration(
    id: 'moses',
    title: 'Moses and the Ten Commandments',
    description: 'Moses receives the law from God on Mount Sinai.',
    bibleReference: 'Exodus 19-20',
    color: const Color(0xFFBF360C),
    icon: Icons.tablet,
    assetPath: 'assets/illustrations/moses.jpg',
  ),
  BibleIllustration(
    id: 'jericho',
    title: 'The Walls of Jericho',
    description: 'The walls of Jericho fall down after the Israelites march around them.',
    bibleReference: 'Joshua 6:1-20',
    color: const Color(0xFFD84315),
    icon: Icons.domain,
    assetPath: 'assets/illustrations/jericho.jpg',
  ),
  BibleIllustration(
    id: 'moses_water',
    title: 'Water from the Rock',
    description: 'Moses strikes the rock and water flows for the Israelites in the desert.',
    bibleReference: 'Exodus 17:1-7',
    color: const Color(0xFF0288D1),
    icon: Icons.water_drop,
    assetPath: 'assets/illustrations/moses_water.jpg',
  ),
  BibleIllustration(
    id: 'elijah_chariot',
    title: 'Elijah\'s Ascension',
    description: 'Elijah is taken up to heaven in a chariot of fire with horses of fire.',
    bibleReference: '2 Kings 2:11',
    color: const Color(0xFFFF6F00),
    icon: Icons.local_fire_department,
    assetPath: 'assets/illustrations/elijah_chariot.jpg',
  ),
  BibleIllustration(
    id: 'david',
    title: 'David and Goliath',
    description: 'The young shepherd David defeats the giant Goliath with faith in God.',
    bibleReference: '1 Samuel 17',
    color: const Color(0xFF004D40),
    icon: Icons.shield,
    assetPath: 'assets/illustrations/david.jpg',
  ),
  BibleIllustration(
    id: 'ruth',
    title: 'Ruth and Boaz',
    description: 'Ruth gleans in the fields of Boaz, showing loyalty and faithfulness.',
    bibleReference: 'Ruth 2-4',
    color: const Color(0xFF8D6E63),
    icon: Icons.agriculture,
    assetPath: 'assets/illustrations/ruth.jpg',
  ),
  BibleIllustration(
    id: 'ezekiel',
    title: 'Ezekiel\'s Prophecy',
    description: 'The prophet Ezekiel delivers God\'s message to the exiles in Babylon.',
    bibleReference: 'Ezekiel 37',
    color: const Color(0xFF5D4037),
    icon: Icons.record_voice_over,
    assetPath: 'assets/illustrations/ezekiel.jpg',
  ),
  BibleIllustration(
    id: 'daniel',
    title: 'Daniel in the Lions\' Den',
    description: 'Daniel\'s faith protects him from the lions, demonstrating God\'s power.',
    bibleReference: 'Daniel 6',
    color: const Color(0xFFE65100),
    icon: Icons.pets,
    assetPath: 'assets/illustrations/daniel.jpg',
  ),
  BibleIllustration(
    id: 'nativity',
    title: 'The Nativity',
    description: 'Jesus is born in Bethlehem, wrapped in swaddling cloths and laid in a manger.',
    bibleReference: 'Luke 2:1-20',
    color: const Color(0xFF880E4F),
    icon: Icons.star,
    assetPath: 'assets/illustrations/nativity.png',
  ),
  BibleIllustration(
    id: 'baptism',
    title: 'The Baptism of Jesus',
    description: 'Jesus is baptized by John the Baptist and the Holy Spirit descends like a dove.',
    bibleReference: 'Matthew 3:13-17',
    color: const Color(0xFF0277BD),
    icon: Icons.water,
    assetPath: 'assets/illustrations/baptism.jpg',
  ),
  BibleIllustration(
    id: 'jesus',
    title: 'The Sermon on the Mount',
    description: 'Jesus teaches the multitudes the Beatitudes and the Lord\'s Prayer.',
    bibleReference: 'Matthew 5-7',
    color: const Color(0xFF1565C0),
    icon: Icons.menu_book,
    assetPath: 'assets/illustrations/jesus_teaching.jpg',
  ),
  BibleIllustration(
    id: 'judas_kiss',
    title: 'The Betrayal of Jesus',
    description: 'Judas betrays Jesus with a kiss in the Garden of Gethsemane.',
    bibleReference: 'Matthew 26:47-50',
    color: const Color(0xFF6A1B9A),
    icon: Icons.nightlight,
    assetPath: 'assets/illustrations/judas_kiss.jpg',
  ),
  BibleIllustration(
    id: 'miracles',
    title: 'Jesus Heals the Sick',
    description: 'Jesus performs miracles of healing, demonstrating God\'s power and compassion.',
    bibleReference: 'Matthew 8-9',
    color: const Color(0xFF00695C),
    icon: Icons.healing,
    assetPath: 'assets/illustrations/healing.jpg',
  ),
  BibleIllustration(
    id: 'jairus',
    title: 'Raising Jairus\' Daughter',
    description: 'Jesus raises the daughter of Jairus from the dead, showing his power over death.',
    bibleReference: 'Mark 5:21-43',
    color: const Color(0xFFAD1457),
    icon: Icons.favorite,
    assetPath: 'assets/illustrations/jairus_daughter.jpg',
  ),
  BibleIllustration(
    id: 'crucifixion',
    title: 'The Crucifixion',
    description: 'Jesus is nailed to the cross and dies for the sins of the world.',
    bibleReference: 'Matthew 27:32-56',
    color: const Color(0xFFB71C1C),
    icon: Icons.favorite,
    assetPath: 'assets/illustrations/crucifixion.jpg',
  ),
  BibleIllustration(
    id: 'dead_christ',
    title: 'The Burial of Jesus',
    description: 'Jesus is taken down from the cross and laid in the tomb.',
    bibleReference: 'Matthew 27:57-61',
    color: const Color(0xFF424242),
    icon: Icons.nights_stay,
    assetPath: 'assets/illustrations/dead_christ.jpg',
  ),
  BibleIllustration(
    id: 'resurrection',
    title: 'The Resurrection',
    description: 'On the third day, Jesus rises from the dead, conquering death forever.',
    bibleReference: 'Matthew 28:1-10',
    color: const Color(0xFFF57F17),
    icon: Icons.wb_twilight,
    assetPath: 'assets/illustrations/resurrection.png',
  ),
  BibleIllustration(
    id: 'ascension',
    title: 'The Ascension',
    description: 'Jesus ascends to heaven while the disciples watch, promising to return.',
    bibleReference: 'Acts 1:9-11',
    color: const Color(0xFF4A148C),
    icon: Icons.cloud,
    assetPath: 'assets/illustrations/ascension.jpg',
  ),
  BibleIllustration(
    id: 'john_baptist',
    title: 'John the Baptist',
    description: 'The beheading of John the Baptist by Herod.',
    bibleReference: 'Matthew 14:1-12',
    color: const Color(0xFF6D4C41),
    icon: Icons.content_cut,
    assetPath: 'assets/illustrations/john_baptist.png',
  ),
  BibleIllustration(
    id: 'horsemen',
    title: 'The Four Horsemen',
    description: 'The Four Horsemen of the Apocalypse bring judgment upon the earth.',
    bibleReference: 'Revelation 6:1-8',
    color: const Color(0xFF1A1A1A),
    icon: Icons.warning,
    assetPath: 'assets/illustrations/horsemen.png',
  ),
  BibleIllustration(
    id: 'new_jerusalem',
    title: 'The New Jerusalem',
    description: 'John sees the holy city coming down from heaven.',
    bibleReference: 'Revelation 21',
    color: const Color(0xFF212121),
    icon: Icons.location_city,
    assetPath: 'assets/illustrations/new_jerusalem.jpg',
  ),
];

/// Bible illustrations page
class BibleIllustrationsPage extends StatelessWidget {
  const BibleIllustrationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bible Illustrations'),
            Text(
              'Classic Bible Scenes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bibleIllustrations.length,
              itemBuilder: (context, index) {
                final illustration = bibleIllustrations[index];
                return _buildIllustrationCard(context, illustration);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard(BuildContext context, BibleIllustration illustration) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => _showDetails(context, illustration),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              child: Image.asset(
                illustration.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to colored icon if image fails
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          illustration.color,
                          illustration.color.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        illustration.icon,
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Title and reference
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    illustration.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    illustration.bibleReference,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  void _showDetails(BuildContext context, BibleIllustration illustration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Image area
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.asset(
                          illustration.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    illustration.color,
                                    illustration.color.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  illustration.icon,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Info
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              illustration.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: illustration.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                illustration.bibleReference,
                                style: TextStyle(
                                  color: illustration.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              illustration.description,
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 32),
                            
                            // Read more button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.menu_book),
                                label: const Text('Read This Passage'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Navigate to the passage
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
