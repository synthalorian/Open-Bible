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
    id: 'joseph_brothers',
    title: 'Joseph Reveals Himself',
    description: 'Joseph reveals his identity to his brothers who had sold him into slavery, showing forgiveness and God\'s providence.',
    bibleReference: 'Genesis 45:1-15',
    color: const Color(0xFFD4AF37),
    icon: Icons.people,
    assetPath: 'assets/illustrations/joseph_brothers.jpg',
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
    id: 'saul_death',
    title: 'The Death of King Saul',
    description: 'King Saul falls in battle against the Philistines, ending his troubled reign over Israel.',
    bibleReference: '1 Samuel 31:1-13',
    color: const Color(0xFF5D4037),
    icon: Icons.shield,
    assetPath: 'assets/illustrations/saul_death.jpg',
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
    id: 'apocalyptic_vision',
    title: 'The Chariots of God',
    description: 'Angelic chariots and horses appear in a dramatic vision, revealing God\'s divine power and heavenly host.',
    bibleReference: 'Zechariah 6:1-8',
    color: const Color(0xFF4A148C),
    icon: Icons.thunderstorm,
    assetPath: 'assets/illustrations/apocalyptic_vision.jpg',
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
  // Gustave Doré Masterpieces - Batch 1
  BibleIllustration(
    id: 'dore_ezekiel_prophesying',
    title: 'Ezekiel Prophesying',
    description: 'The prophet Ezekiel delivers God\'s message to the exiled Israelites in Babylon, calling them to repentance and hope.',
    bibleReference: 'Ezekiel 37',
    color: const Color(0xFF5D4037),
    icon: Icons.record_voice_over,
    assetPath: 'assets/illustrations/dore_ezekiel_prophesying.jpg',
  ),
  BibleIllustration(
    id: 'dore_world_destroyed',
    title: 'The World Destroyed by Water',
    description: 'The great flood covers the earth as divine judgment, with only Noah and his family spared in the ark.',
    bibleReference: 'Genesis 7-8',
    color: const Color(0xFF1565C0),
    icon: Icons.water,
    assetPath: 'assets/illustrations/dore_world_destroyed.jpg',
  ),
  BibleIllustration(
    id: 'dore_jesus_carrying_cross',
    title: 'Jesus Carrying the Cross',
    description: 'Christ bears His cross to Calvary, fulfilling the Father\'s will for the salvation of humanity.',
    bibleReference: 'John 19:17',
    color: const Color(0xFF7B1FA2),
    icon: Icons.church,
    assetPath: 'assets/illustrations/dore_jesus_carrying_cross.jpg',
  ),
  BibleIllustration(
    id: 'dore_sermon_mount',
    title: 'The Sermon on the Mount',
    description: 'Jesus teaches the multitudes the Beatitudes, revealing the heart of God\'s kingdom.',
    bibleReference: 'Matthew 5-7',
    color: const Color(0xFF2E7D32),
    icon: Icons.menu_book,
    assetPath: 'assets/illustrations/dore_sermon_mount.jpg',
  ),
  BibleIllustration(
    id: 'dore_garden_eden',
    title: 'The Garden of Eden',
    description: 'Adam and Eve dwell in paradise before the fall, in perfect harmony with God and creation.',
    bibleReference: 'Genesis 2:8-25',
    color: const Color(0xFF1B5E20),
    icon: Icons.park,
    assetPath: 'assets/illustrations/dore_garden_eden.png',
  ),
  BibleIllustration(
    id: 'dore_noah_ark',
    title: 'Noah\'s Ark on the Waters',
    description: 'The ark rides upon the floodwaters, preserving life through God\'s judgment.',
    bibleReference: 'Genesis 7:17-24',
    color: const Color(0xFF0D47A1),
    icon: Icons.directions_boat,
    assetPath: 'assets/illustrations/dore_noah_ark.jpg',
  ),
  BibleIllustration(
    id: 'dore_israelites_exodus',
    title: 'The Israelites in the Wilderness',
    description: 'God\'s chosen people journey through the desert, guided by pillar of cloud and fire.',
    bibleReference: 'Exodus 13:21-22',
    color: const Color(0xFFBF360C),
    icon: Icons.explore,
    assetPath: 'assets/illustrations/dore_israelites_exodus.jpg',
  ),
  BibleIllustration(
    id: 'dore_abraham_covenant',
    title: 'God\'s Covenant with Abraham',
    description: 'The Lord establishes His eternal covenant with Abraham, promising descendants as numerous as the stars.',
    bibleReference: 'Genesis 15',
    color: const Color(0xFF4A148C),
    icon: Icons.nights_stay,
    assetPath: 'assets/illustrations/dore_abraham_covenant.jpg',
  ),
  BibleIllustration(
    id: 'dore_angel_appearing',
    title: 'The Angel of the Lord',
    description: 'Divine messengers appear to God\'s servants, bringing news of great joy and divine purpose.',
    bibleReference: 'Various',
    color: const Color(0xFFFFD54F),
    icon: Icons.star,
    assetPath: 'assets/illustrations/dore_angel_appearing.jpg',
  ),
  BibleIllustration(
    id: 'dore_jonah_prophet',
    title: 'Jonah the Prophet',
    description: 'Jonah receives God\'s call to preach repentance to Nineveh, beginning his reluctant journey.',
    bibleReference: 'Jonah 1',
    color: const Color(0xFF006064),
    icon: Icons.sailing,
    assetPath: 'assets/illustrations/dore_jonah_prophet.jpg',
  ),
  // Gustave Doré Masterpieces - Batch 2
  BibleIllustration(
    id: 'dore_deluge',
    title: 'The Great Deluge',
    description: 'The floodwaters rise to cleanse the earth of wickedness, as Noah\'s ark carries the remnant of life.',
    bibleReference: 'Genesis 7',
    color: const Color(0xFF01579B),
    icon: Icons.flood,
    assetPath: 'assets/illustrations/dore_deluge.jpg',
  ),
  BibleIllustration(
    id: 'dore_judas_kiss',
    title: 'The Betrayal of Christ',
    description: 'Judas identifies Jesus with a kiss in Gethsemane, leading to the Lord\'s arrest.',
    bibleReference: 'Matthew 26:47-50',
    color: const Color(0xFF4A148C),
    icon: Icons.nightlight,
    assetPath: 'assets/illustrations/dore_judas_kiss.jpg',
  ),
  BibleIllustration(
    id: 'dore_crucifixion',
    title: 'The Crucifixion of Christ',
    description: 'Jesus is lifted up on the cross, the Lamb of God taking away the sins of the world.',
    bibleReference: 'Matthew 27:32-56',
    color: const Color(0xFFB71C1C),
    icon: Icons.favorite,
    assetPath: 'assets/illustrations/dore_crucifixion.jpg',
  ),
  BibleIllustration(
    id: 'dore_creation_light',
    title: 'Let There Be Light',
    description: 'God speaks light into existence, separating it from darkness on the first day of creation.',
    bibleReference: 'Genesis 1:3-5',
    color: const Color(0xFFFFD600),
    icon: Icons.wb_sunny,
    assetPath: 'assets/illustrations/dore_creation_light.jpg',
  ),
  BibleIllustration(
    id: 'dore_tower_babel',
    title: 'The Tower of Babel',
    description: 'Humanity\'s pride leads to the confusion of languages as they attempt to build a tower to heaven.',
    bibleReference: 'Genesis 11:1-9',
    color: const Color(0xFF5D4037),
    icon: Icons.account_balance,
    assetPath: 'assets/illustrations/dore_tower_babel.jpg',
  ),
  BibleIllustration(
    id: 'dore_sermon_mount_alt',
    title: 'Christ Teaching the Multitudes',
    description: 'Jesus preaches the gospel of the kingdom, healing the sick and feeding the souls of thousands.',
    bibleReference: 'Matthew 5-7',
    color: const Color(0xFF2E7D32),
    icon: Icons.menu_book,
    assetPath: 'assets/illustrations/dore_sermon_mount_alt.jpg',
  ),
  BibleIllustration(
    id: 'dore_jonah_preaching',
    title: 'Jonah Preaching to Nineveh',
    description: 'The prophet finally obeys God and calls the great city to repentance, and they believe.',
    bibleReference: 'Jonah 3',
    color: const Color(0xFF006064),
    icon: Icons.record_voice_over,
    assetPath: 'assets/illustrations/dore_jonah_preaching.jpg',
  ),
  BibleIllustration(
    id: 'dore_ezekiel_valley',
    title: 'The Valley of Dry Bones',
    description: 'Ezekiel prophesies to the dry bones, and they come to life—a vision of Israel\'s restoration.',
    bibleReference: 'Ezekiel 37:1-14',
    color: const Color(0xFF795548),
    icon: Icons.auto_fix_high,
    assetPath: 'assets/illustrations/dore_ezekiel_valley.jpg',
  ),
  BibleIllustration(
    id: 'dore_ruth_gleaning',
    title: 'Ruth Gleaning in the Fields',
    description: 'Ruth shows loyal devotion as she gathers grain in Boaz\'s field, a story of redemption and grace.',
    bibleReference: 'Ruth 2',
    color: const Color(0xFF8D6E63),
    icon: Icons.agriculture,
    assetPath: 'assets/illustrations/dore_ruth_gleaning.jpg',
  ),

  // Additional classic plates (Play Store content completion)
  BibleIllustration(
    id: 'dore_ezekiel_prophesying_plate',
    title: 'Ezekiel Prophesying (Plate)',
    description: 'A classic engraving plate of Ezekiel proclaiming God\'s word to the people in exile.',
    bibleReference: 'Ezekiel 37',
    color: const Color(0xFF6D4C41),
    icon: Icons.record_voice_over,
    assetPath: 'assets/illustrations/dore_ezekiel_prophesying_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_world_destroyed_water_plate',
    title: 'The World Destroyed by Water (Plate)',
    description: 'A dramatic flood scene depicting judgment and the devastation of the Deluge.',
    bibleReference: 'Genesis 7-8',
    color: const Color(0xFF1565C0),
    icon: Icons.water,
    assetPath: 'assets/illustrations/dore_world_destroyed_water_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_jesus_healing_sick_plate',
    title: 'Jesus Healing the Sick (Plate)',
    description: 'Christ ministers to the suffering, healing the sick before witnesses.',
    bibleReference: 'Matthew 8-9',
    color: const Color(0xFF00695C),
    icon: Icons.healing,
    assetPath: 'assets/illustrations/dore_jesus_healing_sick_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_death_on_pale_horse_plate',
    title: 'Death on the Pale Horse (Plate)',
    description: 'An apocalyptic vision of judgment from Revelation, rendered in a dark engraved style.',
    bibleReference: 'Revelation 6:8',
    color: const Color(0xFF212121),
    icon: Icons.warning,
    assetPath: 'assets/illustrations/dore_death_on_pale_horse_plate.png',
  ),
  BibleIllustration(
    id: 'dore_jairus_daughter_plate',
    title: 'Raising Jairus\' Daughter (Plate)',
    description: 'Jesus stands beside Jairus\' daughter, revealing His authority over death.',
    bibleReference: 'Mark 5:21-43',
    color: const Color(0xFFAD1457),
    icon: Icons.favorite,
    assetPath: 'assets/illustrations/dore_jairus_daughter_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_walls_jericho_falling_plate',
    title: 'The Walls of Jericho Falling Down (Plate)',
    description: 'The fortifications of Jericho collapse as Israel advances in obedience to God.',
    bibleReference: 'Joshua 6:20',
    color: const Color(0xFFD84315),
    icon: Icons.domain,
    assetPath: 'assets/illustrations/dore_walls_jericho_falling_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_judas_kiss_arrest_plate',
    title: 'The Betrayal and Arrest of Christ (Plate)',
    description: 'Judas identifies Jesus in Gethsemane as soldiers move in to seize Him.',
    bibleReference: 'Matthew 26:47-50',
    color: const Color(0xFF4A148C),
    icon: Icons.nightlight,
    assetPath: 'assets/illustrations/dore_judas_kiss_arrest_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_render_unto_caesar_plate',
    title: 'Render Unto Caesar (Plate)',
    description: 'Jesus answers the question of tribute, teaching wisdom in the midst of opposition.',
    bibleReference: 'Matthew 22:15-22',
    color: const Color(0xFF546E7A),
    icon: Icons.account_balance,
    assetPath: 'assets/illustrations/dore_render_unto_caesar_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_sermon_on_mount_plate',
    title: 'Sermon on the Mount (Plate)',
    description: 'A classic engraving of Jesus teaching the crowds in the hills of Galilee.',
    bibleReference: 'Matthew 5-7',
    color: const Color(0xFF2E7D32),
    icon: Icons.menu_book,
    assetPath: 'assets/illustrations/dore_sermon_on_mount_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_death_of_saul_plate',
    title: 'The Death of Saul (Plate)',
    description: 'A battlefield scene illustrating the fall of Saul amid the conflict with the Philistines.',
    bibleReference: '1 Samuel 31',
    color: const Color(0xFF5D4037),
    icon: Icons.shield,
    assetPath: 'assets/illustrations/dore_death_of_saul_plate.png',
  ),

  // Additional classic plates (batch 2)
  BibleIllustration(
    id: 'dore_divine_light_clouds_plate',
    title: 'Divine Light in the Clouds (Plate)',
    description: 'A prophet raises his hand toward the radiant glory of God revealed in the clouds.',
    bibleReference: 'Exodus 33:18-23',
    color: const Color(0xFF455A64),
    icon: Icons.wb_sunny,
    assetPath: 'assets/illustrations/dore_divine_light_clouds_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_moses_tablets_thunder_plate',
    title: 'Moses with the Tablets (Plate)',
    description: 'Moses descends with the tablets of the Law amid thunder and awe.',
    bibleReference: 'Exodus 32:15-20',
    color: const Color(0xFF37474F),
    icon: Icons.tablet,
    assetPath: 'assets/illustrations/dore_moses_tablets_thunder_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_crossing_jordan_plate',
    title: 'Crossing the Jordan (Plate)',
    description: 'Israel stands at the Jordan as God makes a way for the people to pass through.',
    bibleReference: 'Joshua 3',
    color: const Color(0xFF78909C),
    icon: Icons.water,
    assetPath: 'assets/illustrations/dore_crossing_jordan_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_nativity_manger_plate',
    title: 'The Nativity at the Manger (Plate)',
    description: 'The Christ child is adored in the manger by Mary, Joseph, and worshipers.',
    bibleReference: 'Luke 2:7-20',
    color: const Color(0xFF8D6E63),
    icon: Icons.star,
    assetPath: 'assets/illustrations/dore_nativity_manger_plate.png',
  ),
  BibleIllustration(
    id: 'dore_triumphal_entry_plate',
    title: 'The Triumphal Entry (Plate)',
    description: 'Jesus enters Jerusalem as crowds honor Him with praise.',
    bibleReference: 'Matthew 21:1-11',
    color: const Color(0xFF607D8B),
    icon: Icons.celebration,
    assetPath: 'assets/illustrations/dore_triumphal_entry_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_deluge_children_rock_plate',
    title: 'The Deluge (Children on the Rock) (Plate)',
    description: 'A haunting flood scene portraying desperate survivors as waters rise.',
    bibleReference: 'Genesis 7',
    color: const Color(0xFF263238),
    icon: Icons.flood,
    assetPath: 'assets/illustrations/dore_deluge_children_rock_plate.jpg',
  ),
  BibleIllustration(
    id: 'dore_empty_tomb_angel_plate',
    title: 'The Empty Tomb and Angel (Plate)',
    description: 'An angel announces the resurrection near the tomb.',
    bibleReference: 'Matthew 28:1-6',
    color: const Color(0xFF5D4037),
    icon: Icons.auto_awesome,
    assetPath: 'assets/illustrations/dore_empty_tomb_angel_plate.png',
  ),
  BibleIllustration(
    id: 'dore_gleaners_plate',
    title: 'The Gleaners (Plate)',
    description: 'A classic depiction of gleaning in the fields, echoing the story of Ruth.',
    bibleReference: 'Ruth 2',
    color: const Color(0xFF8D6E63),
    icon: Icons.agriculture,
    assetPath: 'assets/illustrations/dore_gleaners_plate.jpg',
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
