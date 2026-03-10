import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maps and charts provider
final mapsChartsProvider = Provider<MapsChartsData>((ref) => MapsChartsData());

/// Map data model
class BibleMap {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final List<MapRegion> regions;
  final MapCategory category;

  BibleMap({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.regions = const [],
    required this.category,
  });
}

/// Map region/hotspot
class MapRegion {
  final String name;
  final String description;
  final double x; // 0-1 percentage
  final double y; // 0-1 percentage
  final double width;
  final double height;

  MapRegion({
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    this.width = 0.1,
    this.height = 0.1,
  });
}

enum MapCategory {
  patriarchs,
  exodus,
  kingdoms,
  prophets,
  jesus,
  paul,
  general,
}

String mapCategoryLabel(MapCategory category) {
  switch (category) {
    case MapCategory.patriarchs:
      return 'Patriarchs';
    case MapCategory.exodus:
      return 'Exodus & Conquest';
    case MapCategory.kingdoms:
      return 'United & Divided Kingdoms';
    case MapCategory.prophets:
      return 'Prophets & Exile';
    case MapCategory.jesus:
      return 'Life of Jesus';
    case MapCategory.paul:
      return 'Paul\'s Journeys';
    case MapCategory.general:
      return 'General Maps';
  }
}

/// Genealogy chart model
class GenealogyChart {
  final String id;
  final String title;
  final String description;
  final List<GenealogyPerson> people;
  final String rootPerson;

  GenealogyChart({
    required this.id,
    required this.title,
    required this.description,
    required this.people,
    required this.rootPerson,
  });
}

/// Person in genealogy
class GenealogyPerson {
  final String id;
  final String name;
  final String? description;
  final String? scripture;
  final int? birthYear; // Approximate BC/AD
  final int? deathYear;
  final List<String> children;
  final String? father;
  final String? mother;
  final String? spouse;
  final PersonType type;

  GenealogyPerson({
    required this.id,
    required this.name,
    this.description,
    this.scripture,
    this.birthYear,
    this.deathYear,
    this.children = const [],
    this.father,
    this.mother,
    this.spouse,
    this.type = PersonType.person,
  });
}

enum PersonType {
  person,
  patriarch,
  king,
  prophet,
  jesus,
}

/// Timeline event
class TimelineEvent {
  final String title;
  final String description;
  final int year; // Negative for BC, positive for AD
  final String? scripture;
  final TimelineCategory category;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.year,
    this.scripture,
    required this.category,
  });
}

enum TimelineCategory {
  creation,
  patriarchs,
  exodus,
  conquest,
  judges,
  kingdom,
  exile,
  restoration, // Was 'return' but that's a reserved keyword
  silent,
  jesus,
  church,
}

/// Maps and charts data
class MapsChartsData {
  List<BibleMap> get maps => [
    // General Maps
    BibleMap(
      id: 'holy_land',
      title: 'The Holy Land',
      description: 'Geography of Israel and surrounding regions',
      imagePath: 'assets/maps/holy_land.png',
      category: MapCategory.general,
      regions: [
        MapRegion(name: 'Jerusalem', description: 'Capital city, site of the Temple', x: 0.5, y: 0.6, width: 0.08, height: 0.08),
        MapRegion(name: 'Galilee', description: 'Northern region where Jesus ministered', x: 0.5, y: 0.2, width: 0.15, height: 0.15),
        MapRegion(name: 'Dead Sea', description: 'Lowest point on Earth', x: 0.55, y: 0.7, width: 0.1, height: 0.1),
        MapRegion(name: 'Jordan River', description: 'Where Jesus was baptized', x: 0.55, y: 0.45, width: 0.05, height: 0.3),
        MapRegion(name: 'Samaria', description: 'Central region', x: 0.45, y: 0.4, width: 0.12, height: 0.12),
      ],
    ),
    
    // Patriarchs
    BibleMap(
      id: 'abraham_journey',
      title: 'Abraham\'s Journey',
      description: 'From Ur to Canaan to Egypt and back',
      imagePath: 'assets/maps/abraham_journey.png',
      category: MapCategory.patriarchs,
      regions: [
        MapRegion(name: 'Ur of the Chaldeans', description: 'Abraham\'s birthplace', x: 0.8, y: 0.7, width: 0.1, height: 0.1),
        MapRegion(name: 'Haran', description: 'Where Abraham stopped with his father', x: 0.6, y: 0.3, width: 0.08, height: 0.08),
        MapRegion(name: 'Shechem', description: 'First stop in Canaan', x: 0.45, y: 0.5, width: 0.08, height: 0.08),
        MapRegion(name: 'Bethel', description: 'Where Abraham built an altar', x: 0.42, y: 0.52, width: 0.08, height: 0.08),
        MapRegion(name: 'Hebron', description: 'Abraham\'s home in Canaan', x: 0.48, y: 0.65, width: 0.08, height: 0.08),
      ],
    ),
    
    BibleMap(
      id: 'exodus_route',
      title: 'The Exodus Route',
      description: 'From Egypt to the Promised Land',
      imagePath: 'assets/maps/exodus_route.png',
      category: MapCategory.exodus,
      regions: [
        MapRegion(name: 'Goshen', description: 'Where Israelites lived in Egypt', x: 0.3, y: 0.7, width: 0.1, height: 0.1),
        MapRegion(name: 'Red Sea', description: 'Miraculous crossing', x: 0.4, y: 0.8, width: 0.15, height: 0.1),
        MapRegion(name: 'Mount Sinai', description: 'Where Moses received the Law', x: 0.5, y: 0.85, width: 0.08, height: 0.08),
        MapRegion(name: 'Kadesh Barnea', description: '40 years of wandering', x: 0.55, y: 0.6, width: 0.1, height: 0.1),
        MapRegion(name: 'Jericho', description: 'First city conquered in Canaan', x: 0.52, y: 0.45, width: 0.08, height: 0.08),
      ],
    ),
    
    // Jesus
    BibleMap(
      id: 'jesus_ministry',
      title: 'Ministry of Jesus',
      description: 'Key locations in Jesus\' life and ministry',
      imagePath: 'assets/maps/jesus_ministry.png',
      category: MapCategory.jesus,
      regions: [
        MapRegion(name: 'Nazareth', description: 'Jesus\' hometown', x: 0.45, y: 0.35, width: 0.08, height: 0.08),
        MapRegion(name: 'Capernaum', description: 'Center of Jesus\' ministry', x: 0.5, y: 0.25, width: 0.08, height: 0.08),
        MapRegion(name: 'Sea of Galilee', description: 'Where Jesus calmed the storm', x: 0.52, y: 0.28, width: 0.12, height: 0.08),
        MapRegion(name: 'Bethlehem', description: 'Jesus\' birthplace', x: 0.48, y: 0.6, width: 0.08, height: 0.08),
        MapRegion(name: 'Jerusalem', description: 'Crucifixion and Resurrection', x: 0.5, y: 0.62, width: 0.08, height: 0.08),
      ],
    ),
    
    BibleMap(
      id: 'paul_journeys',
      title: 'Paul\'s Missionary Journeys',
      description: 'Three missionary journeys and trip to Rome',
      imagePath: 'assets/maps/paul_journeys.png',
      category: MapCategory.paul,
      regions: [
        MapRegion(name: 'Antioch', description: 'Home base for missions', x: 0.65, y: 0.4, width: 0.08, height: 0.08),
        MapRegion(name: 'Ephesus', description: 'Third journey, 2+ years', x: 0.6, y: 0.35, width: 0.08, height: 0.08),
        MapRegion(name: 'Corinth', description: 'Major church planted', x: 0.45, y: 0.45, width: 0.08, height: 0.08),
        MapRegion(name: 'Philippi', description: 'First European church', x: 0.52, y: 0.32, width: 0.08, height: 0.08),
        MapRegion(name: 'Rome', description: 'Final destination', x: 0.35, y: 0.38, width: 0.08, height: 0.08),
      ],
    ),
  ];

  List<GenealogyChart> get genealogyCharts => [
    GenealogyChart(
      id: 'adam_to_abraham',
      title: 'From Adam to Abraham',
      description: 'The patriarchal line before Israel',
      rootPerson: 'adam',
      people: [
        GenealogyPerson(id: 'adam', name: 'Adam', description: 'First man', birthYear: -4004, deathYear: -3074, children: ['seth'], type: PersonType.patriarch),
        GenealogyPerson(id: 'seth', name: 'Seth', birthYear: -3874, deathYear: -2962, father: 'adam', children: ['enos']),
        GenealogyPerson(id: 'enos', name: 'Enos', birthYear: -3769, deathYear: -2864, father: 'seth', children: ['cainan']),
        GenealogyPerson(id: 'cainan', name: 'Cainan', birthYear: -3679, deathYear: -2769, father: 'enos', children: ['mahalaleel']),
        GenealogyPerson(id: 'mahalaleel', name: 'Mahalaleel', birthYear: -3609, deathYear: -2714, father: 'cainan', children: ['jared']),
        GenealogyPerson(id: 'jared', name: 'Jared', birthYear: -3544, deathYear: -2582, father: 'mahalaleel', children: ['enoch']),
        GenealogyPerson(id: 'enoch', name: 'Enoch', description: 'Walked with God, taken to heaven', birthYear: -3382, father: 'jared', children: ['methuselah'], type: PersonType.patriarch),
        GenealogyPerson(id: 'methuselah', name: 'Methuselah', description: 'Lived 969 years', birthYear: -3317, deathYear: -2348, father: 'enoch', children: ['lamech']),
        GenealogyPerson(id: 'lamech', name: 'Lamech', birthYear: -3130, deathYear: -2353, father: 'methuselah', children: ['noah']),
        GenealogyPerson(id: 'noah', name: 'Noah', description: 'Built the Ark', birthYear: -2948, deathYear: -1998, father: 'lamech', children: ['shem', 'ham', 'japheth'], type: PersonType.patriarch),
        GenealogyPerson(id: 'shem', name: 'Shem', birthYear: -2448, deathYear: -1848, father: 'noah', children: ['arphaxad']),
        GenealogyPerson(id: 'arphaxad', name: 'Arphaxad', birthYear: -2348, deathYear: -1908, father: 'shem', children: ['salah']),
        GenealogyPerson(id: 'salah', name: 'Salah', birthYear: -2313, deathYear: -1878, father: 'arphaxad', children: ['eber']),
        GenealogyPerson(id: 'eber', name: 'Eber', birthYear: -2283, deathYear: -1813, father: 'salah', children: ['peleg']),
        GenealogyPerson(id: 'peleg', name: 'Peleg', description: 'In his days the earth was divided', birthYear: -2249, deathYear: -2008, father: 'eber', children: ['reu']),
        GenealogyPerson(id: 'reu', name: 'Reu', birthYear: -2217, deathYear: -1978, father: 'peleg', children: ['serug']),
        GenealogyPerson(id: 'serug', name: 'Serug', birthYear: -2185, deathYear: -1945, father: 'reu', children: ['nahor']),
        GenealogyPerson(id: 'nahor', name: 'Nahor', birthYear: -2155, deathYear: -2007, father: 'serug', children: ['terah']),
        GenealogyPerson(id: 'terah', name: 'Terah', birthYear: -2126, deathYear: -1921, father: 'nahor', children: ['abraham', 'nahor2', 'haram']),
        GenealogyPerson(id: 'abraham', name: 'Abraham', description: 'Father of many nations', birthYear: -1996, deathYear: -1821, father: 'terah', children: ['isaac', 'ishmael'], type: PersonType.patriarch),
      ],
    ),
    
    GenealogyChart(
      id: 'abraham_to_jesus',
      title: 'From Abraham to Jesus',
      description: 'The lineage of the Messiah through David',
      rootPerson: 'abraham2',
      people: [
        GenealogyPerson(id: 'abraham2', name: 'Abraham', birthYear: -1996, deathYear: -1821, children: ['isaac2'], type: PersonType.patriarch),
        GenealogyPerson(id: 'isaac2', name: 'Isaac', birthYear: -1896, deathYear: -1716, father: 'abraham2', children: ['jacob'], type: PersonType.patriarch),
        GenealogyPerson(id: 'jacob', name: 'Jacob (Israel)', birthYear: -1836, deathYear: -1689, father: 'isaac2', children: ['judah', 'joseph', 'levi', 'reuben', 'simeon', 'dan', 'naphtali', 'gad', 'asher', 'issachar', 'zebulun', 'benjamin'], type: PersonType.patriarch),
        GenealogyPerson(id: 'judah', name: 'Judah', father: 'jacob', children: ['perez'], type: PersonType.patriarch),
        GenealogyPerson(id: 'perez', name: 'Perez', father: 'judah', children: ['hezron']),
        GenealogyPerson(id: 'hezron', name: 'Hezron', father: 'perez', children: ['ram']),
        GenealogyPerson(id: 'ram', name: 'Ram', father: 'hezron', children: ['amminadab']),
        GenealogyPerson(id: 'amminadab', name: 'Amminadab', father: 'ram', children: ['nahshon']),
        GenealogyPerson(id: 'nahshon', name: 'Nahshon', father: 'amminadab', children: ['salmon']),
        GenealogyPerson(id: 'salmon', name: 'Salmon', father: 'nahshon', children: ['boaz']),
        GenealogyPerson(id: 'boaz', name: 'Boaz', father: 'salmon', children: ['obed']),
        GenealogyPerson(id: 'obed', name: 'Obed', father: 'boaz', children: ['jesse']),
        GenealogyPerson(id: 'jesse', name: 'Jesse', father: 'obed', children: ['david']),
        GenealogyPerson(id: 'david', name: 'David', description: 'King of Israel, man after God\'s heart', birthYear: -1040, deathYear: -970, father: 'jesse', children: ['solomon'], type: PersonType.king),
        GenealogyPerson(id: 'solomon', name: 'Solomon', description: 'Built the Temple', birthYear: -990, deathYear: -931, father: 'david', children: ['rehoboam'], type: PersonType.king),
        GenealogyPerson(id: 'rehoboam', name: 'Rehoboam', birthYear: -971, deathYear: -913, father: 'solomon', children: ['abijah']),
        GenealogyPerson(id: 'abijah', name: 'Abijah', father: 'rehoboam', children: ['asa']),
        GenealogyPerson(id: 'asa', name: 'Asa', deathYear: -870, father: 'abijah', children: ['jehoshaphat']),
        GenealogyPerson(id: 'jehoshaphat', name: 'Jehoshaphat', birthYear: -905, deathYear: -849, father: 'asa', children: ['jehoram']),
        GenealogyPerson(id: 'jehoram', name: 'Jehoram', father: 'jehoshaphat', children: ['uzziah']),
        GenealogyPerson(id: 'uzziah', name: 'Uzziah (Azariah)', birthYear: -807, deathYear: -740, father: 'jehoram', children: ['jotham']),
        GenealogyPerson(id: 'jotham', name: 'Jotham', birthYear: -783, deathYear: -742, father: 'uzziah', children: ['ahaz']),
        GenealogyPerson(id: 'ahaz', name: 'Ahaz', birthYear: -757, deathYear: -716, father: 'jotham', children: ['hezekiah']),
        GenealogyPerson(id: 'hezekiah', name: 'Hezekiah', birthYear: -726, deathYear: -697, father: 'ahaz', children: ['manasseh']),
        GenealogyPerson(id: 'manasseh', name: 'Manasseh', birthYear: -697, deathYear: -642, father: 'hezekiah', children: ['amon']),
        GenealogyPerson(id: 'amon', name: 'Amon', birthYear: -664, deathYear: -640, father: 'manasseh', children: ['josiah']),
        GenealogyPerson(id: 'josiah', name: 'Josiah', birthYear: -640, deathYear: -609, father: 'amon', children: ['jeconiah']),
        GenealogyPerson(id: 'jeconiah', name: 'Jeconiah', birthYear: -615, father: 'josiah', children: ['shealtiel']),
        GenealogyPerson(id: 'shealtiel', name: 'Shealtiel', father: 'jeconiah', children: ['zerubbabel']),
        GenealogyPerson(id: 'zerubbabel', name: 'Zerubbabel', father: 'shealtiel', children: ['abiud']),
        GenealogyPerson(id: 'abiud', name: 'Abiud', father: 'zerubbabel', children: ['eliakim']),
        GenealogyPerson(id: 'eliakim', name: 'Eliakim', father: 'abiud', children: ['azor']),
        GenealogyPerson(id: 'azor', name: 'Azor', father: 'eliakim', children: ['zadok']),
        GenealogyPerson(id: 'zadok', name: 'Zadok', father: 'azor', children: ['achim']),
        GenealogyPerson(id: 'achim', name: 'Achim', father: 'zadok', children: ['eliud']),
        GenealogyPerson(id: 'eliud', name: 'Eliud', father: 'achim', children: ['eleazar']),
        GenealogyPerson(id: 'eleazar', name: 'Eleazar', father: 'eliud', children: ['matthan']),
        GenealogyPerson(id: 'matthan', name: 'Matthan', father: 'eleazar', children: ['jacob3']),
        GenealogyPerson(id: 'jacob3', name: 'Jacob', father: 'matthan', children: ['joseph2']),
        GenealogyPerson(id: 'joseph2', name: 'Joseph', description: 'Husband of Mary', father: 'jacob3', children: ['jesus']),
        GenealogyPerson(id: 'jesus', name: 'Jesus Christ', description: 'The Messiah, Son of God', birthYear: 4, deathYear: 30, father: 'joseph2', type: PersonType.jesus),
      ],
    ),
  ];

  List<TimelineEvent> get timelineEvents => [
    // Creation
    TimelineEvent(title: 'Creation', description: 'God creates the heavens and the earth', year: -4004, scripture: 'Genesis 1:1', category: TimelineCategory.creation),
    TimelineEvent(title: 'Adam and Eve', description: 'First humans created', year: -4004, scripture: 'Genesis 2:7', category: TimelineCategory.creation),
    TimelineEvent(title: 'The Fall', description: 'Sin enters the world', year: -4004, scripture: 'Genesis 3', category: TimelineCategory.creation),
    
    // Patriarchs
    TimelineEvent(title: 'Noah\'s Flood', description: 'Global flood, only 8 saved', year: -2348, scripture: 'Genesis 7', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Tower of Babel', description: 'Languages confused', year: -2247, scripture: 'Genesis 11', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Abraham born', description: 'Father of many nations', year: -1996, scripture: 'Genesis 11:26', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Abraham enters Canaan', description: 'God\'s promise of land', year: -1921, scripture: 'Genesis 12:4', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Isaac born', description: 'Child of promise', year: -1896, scripture: 'Genesis 21:5', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Jacob born', description: 'Later named Israel', year: -1836, scripture: 'Genesis 25:26', category: TimelineCategory.patriarchs),
    TimelineEvent(title: 'Joseph sold to Egypt', description: 'Beginning of Israel in Egypt', year: -1728, scripture: 'Genesis 37:2', category: TimelineCategory.patriarchs),
    
    // Exodus
    TimelineEvent(title: 'Moses born', description: 'Led Israel out of Egypt', year: -1571, scripture: 'Exodus 2:2', category: TimelineCategory.exodus),
    TimelineEvent(title: 'The Exodus', description: 'Israel leaves Egypt', year: -1491, scripture: 'Exodus 12:40', category: TimelineCategory.exodus),
    TimelineEvent(title: 'Crossing Red Sea', description: 'Miraculous deliverance', year: -1491, scripture: 'Exodus 14', category: TimelineCategory.exodus),
    TimelineEvent(title: 'Sinai and Law', description: '10 Commandments given', year: -1491, scripture: 'Exodus 20', category: TimelineCategory.exodus),
    TimelineEvent(title: 'Tabernacle completed', description: 'God dwells with Israel', year: -1490, scripture: 'Exodus 40', category: TimelineCategory.exodus),
    
    // Conquest
    TimelineEvent(title: 'Joshua leads conquest', description: 'Entering the Promised Land', year: -1451, scripture: 'Joshua 1', category: TimelineCategory.conquest),
    TimelineEvent(title: 'Walls of Jericho fall', description: 'First victory in Canaan', year: -1451, scripture: 'Joshua 6', category: TimelineCategory.conquest),
    
    // Judges
    TimelineEvent(title: 'Period of Judges', description: 'Cycles of sin and deliverance', year: -1425, scripture: 'Judges 2:16', category: TimelineCategory.judges),
    
    // Kingdom
    TimelineEvent(title: 'Saul anointed king', description: 'First king of Israel', year: -1095, scripture: '1 Samuel 10', category: TimelineCategory.kingdom),
    TimelineEvent(title: 'David anointed king', description: 'Man after God\'s own heart', year: -1055, scripture: '2 Samuel 2:4', category: TimelineCategory.kingdom),
    TimelineEvent(title: 'Solomon becomes king', description: 'Built the Temple', year: -1015, scripture: '1 Kings 2:12', category: TimelineCategory.kingdom),
    TimelineEvent(title: 'Temple dedicated', description: 'Ark placed in the Holy of Holies', year: -1004, scripture: '1 Kings 8', category: TimelineCategory.kingdom),
    TimelineEvent(title: 'Kingdom divided', description: 'Israel and Judah', year: -975, scripture: '1 Kings 12', category: TimelineCategory.kingdom),
    
    // Exile
    TimelineEvent(title: 'Israel falls to Assyria', description: 'Northern kingdom destroyed', year: -722, scripture: '2 Kings 17', category: TimelineCategory.exile),
    TimelineEvent(title: 'Judah falls to Babylon', description: 'Jerusalem destroyed, Temple burned', year: -586, scripture: '2 Kings 25', category: TimelineCategory.exile),
    
    // Return
    TimelineEvent(title: 'Return from exile', description: 'Cyrus allows Jews to return', year: -536, scripture: 'Ezra 1', category: TimelineCategory.restoration),
    TimelineEvent(title: 'Temple rebuilt', description: 'Second Temple completed', year: -515, scripture: 'Ezra 6', category: TimelineCategory.restoration),
    TimelineEvent(title: 'Ezra returns', description: 'Spiritual revival', year: -458, scripture: 'Ezra 7', category: TimelineCategory.restoration),
    TimelineEvent(title: 'Nehemiah rebuilds walls', description: 'Jerusalem restored', year: -445, scripture: 'Nehemiah 6', category: TimelineCategory.restoration),
    
    // Silent period
    TimelineEvent(title: 'End of OT period', description: 'Malachi, last prophet', year: -400, scripture: 'Malachi 4', category: TimelineCategory.silent),
    
    // Jesus
    TimelineEvent(title: 'Birth of Jesus', description: 'The Messiah is born', year: -4, scripture: 'Matthew 1:18', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Jesus\' ministry begins', description: 'Baptism by John', year: 26, scripture: 'Matthew 3:13', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Sermon on the Mount', description: 'Beatitudes and Lord\'s Prayer', year: 28, scripture: 'Matthew 5-7', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Feeding 5000', description: 'Miracle of multiplication', year: 29, scripture: 'Matthew 14:13', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Transfiguration', description: 'Glory revealed', year: 29, scripture: 'Matthew 17', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Triumphal Entry', description: 'Hosanna to the King', year: 30, scripture: 'Matthew 21', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Last Supper', description: 'New covenant instituted', year: 30, scripture: 'Matthew 26', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Crucifixion', description: 'Jesus dies for our sins', year: 30, scripture: 'Matthew 27', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Resurrection', description: 'Jesus rises from the dead', year: 30, scripture: 'Matthew 28', category: TimelineCategory.jesus),
    TimelineEvent(title: 'Ascension', description: 'Jesus returns to heaven', year: 30, scripture: 'Acts 1', category: TimelineCategory.jesus),
    
    // Church
    TimelineEvent(title: 'Day of Pentecost', description: 'Holy Spirit given, Church born', year: 30, scripture: 'Acts 2', category: TimelineCategory.church),
    TimelineEvent(title: 'Paul\'s conversion', description: 'Persecutor becomes apostle', year: 34, scripture: 'Acts 9', category: TimelineCategory.church),
    TimelineEvent(title: 'First missionary journey', description: 'Paul and Barnabas', year: 47, scripture: 'Acts 13', category: TimelineCategory.church),
    TimelineEvent(title: 'Jerusalem Council', description: 'Gentiles welcomed', year: 49, scripture: 'Acts 15', category: TimelineCategory.church),
    TimelineEvent(title: 'Paul reaches Rome', description: 'Gospel to the ends of earth', year: 60, scripture: 'Acts 28', category: TimelineCategory.church),
  ];
}

/// Color for timeline category
Color timelineCategoryColor(TimelineCategory category) {
  switch (category) {
    case TimelineCategory.creation:
      return const Color(0xFF4CAF50);
    case TimelineCategory.patriarchs:
      return const Color(0xFF8D6E63);
    case TimelineCategory.exodus:
      return const Color(0xFF2196F3);
    case TimelineCategory.conquest:
      return const Color(0xFF9C27B0);
    case TimelineCategory.judges:
      return const Color(0xFFFF9800);
    case TimelineCategory.kingdom:
      return const Color(0xFFD4AF37);
    case TimelineCategory.exile:
      return const Color(0xFF607D8B);
    case TimelineCategory.restoration:
      return const Color(0xFF00BCD4);
    case TimelineCategory.silent:
      return const Color(0xFF9E9E9E);
    case TimelineCategory.jesus:
      return const Color(0xFFE53935);
    case TimelineCategory.church:
      return const Color(0xFF3F51B5);
  }
}

String timelineCategoryLabel(TimelineCategory category) {
  switch (category) {
    case TimelineCategory.creation:
      return 'Creation';
    case TimelineCategory.patriarchs:
      return 'Patriarchs';
    case TimelineCategory.exodus:
      return 'Exodus';
    case TimelineCategory.conquest:
      return 'Conquest';
    case TimelineCategory.judges:
      return 'Judges';
    case TimelineCategory.kingdom:
      return 'Kingdom';
    case TimelineCategory.exile:
      return 'Exile';
    case TimelineCategory.restoration:
      return 'Return';
    case TimelineCategory.silent:
      return 'Silent Period';
    case TimelineCategory.jesus:
      return 'Jesus';
    case TimelineCategory.church:
      return 'Early Church';
  }
}
