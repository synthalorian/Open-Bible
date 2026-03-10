import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bible location model
class BibleLocation {
  final String id;
  final String name;
  final String description;
  final String region;
  final double latitude;
  final double longitude;
  final String? scriptureRef;
  final List<String> events;
  
  const BibleLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.scriptureRef,
    this.events = const [],
  });
}

/// Biblical locations database - 50+ locations
final List<BibleLocation> biblicalLocations = [
  // Creation / Eden
  const BibleLocation(
    id: 'eden', name: 'Garden of Eden',
    description: 'The original paradise where God placed Adam and Eve.',
    region: 'Ancient Near East', latitude: 30.0, longitude: 45.0,
    scriptureRef: 'Genesis 2:8-15',
    events: ['Creation of Adam and Eve', 'The Fall'],
  ),
  // Patriarchs
  const BibleLocation(
    id: 'ur', name: 'Ur of the Chaldeans',
    description: 'Birthplace of Abraham, the father of faith.',
    region: 'Mesopotamia', latitude: 30.9625, longitude: 46.1044,
    scriptureRef: 'Genesis 11:31',
    events: ['Abraham\'s birthplace', 'Call to Canaan'],
  ),
  const BibleLocation(
    id: 'haran', name: 'Haran',
    description: 'Where Abraham\'s family settled before entering Canaan.',
    region: 'Mesopotamia', latitude: 36.8684, longitude: 39.0311,
    scriptureRef: 'Genesis 11:31-32',
    events: ['Terah died here', 'Abraham\'s sojourn'],
  ),
  const BibleLocation(
    id: 'bethel', name: 'Bethel',
    description: 'Where Jacob had his vision of the ladder to heaven.',
    region: 'Canaan', latitude: 31.9306, longitude: 35.2219,
    scriptureRef: 'Genesis 28:10-22',
    events: ['Jacob\'s ladder', 'Covenant with God'],
  ),
  const BibleLocation(
    id: 'hebron', name: 'Hebron',
    description: 'Where Abraham buried Sarah. City of refuge.',
    region: 'Canaan', latitude: 31.5326, longitude: 35.0988,
    scriptureRef: 'Genesis 23',
    events: ['Sarah buried', 'David\'s first capital'],
  ),
  const BibleLocation(
    id: 'shechem', name: 'Shechem',
    description: 'Where Joshua renewed the covenant.',
    region: 'Canaan', latitude: 32.2136, longitude: 35.2816,
    scriptureRef: 'Joshua 24',
    events: ['Covenant renewed', 'Jacob\'s well'],
  ),
  const BibleLocation(
    id: 'beersheba', name: 'Beersheba',
    description: 'Southernmost city of Israel.',
    region: 'Canaan', latitude: 31.2458, longitude: 34.7917,
    scriptureRef: 'Genesis 21:31',
    events: ['Abraham\'s well', 'Southern boundary'],
  ),
  // Egypt
  const BibleLocation(
    id: 'egypt', name: 'Egypt',
    description: 'Where Joseph became ruler and Israelites settled.',
    region: 'Egypt', latitude: 26.8206, longitude: 30.8025,
    scriptureRef: 'Genesis 37-50',
    events: ['Joseph\'s rise to power', 'Israelites in bondage'],
  ),
  const BibleLocation(
    id: 'goshen', name: 'Land of Goshen',
    description: 'Region in Egypt where the Israelites lived.',
    region: 'Egypt', latitude: 30.8, longitude: 31.8,
    scriptureRef: 'Genesis 45:10',
    events: ['Israelites settled here'],
  ),
  // Exodus
  const BibleLocation(
    id: 'red_sea', name: 'Red Sea',
    description: 'Parted by God for Israel to escape from Egypt.',
    region: 'Egypt', latitude: 20.2802, longitude: 38.5126,
    scriptureRef: 'Exodus 14',
    events: ['Parting of the Red Sea'],
  ),
  const BibleLocation(
    id: 'sinai', name: 'Mount Sinai',
    description: 'Where Moses received the Ten Commandments.',
    region: 'Sinai Peninsula', latitude: 28.5392, longitude: 33.9749,
    scriptureRef: 'Exodus 19-20',
    events: ['Ten Commandments given', 'Covenant established'],
  ),
  // Promised Land
  const BibleLocation(
    id: 'jericho', name: 'Jericho',
    description: 'First city conquered in Canaan. Walls fell at Joshua\'s command.',
    region: 'Canaan', latitude: 31.8556, longitude: 35.4622,
    scriptureRef: 'Joshua 6',
    events: ['Walls fell', 'Rahab saved'],
  ),
  const BibleLocation(
    id: 'ai', name: 'Ai',
    description: 'City defeated by Joshua after initial failure.',
    region: 'Canaan', latitude: 31.9167, longitude: 35.2583,
    scriptureRef: 'Joshua 7-8',
    events: ['Achan\'s sin', 'Victory over Ai'],
  ),
  const BibleLocation(
    id: 'gibeon', name: 'Gibeon',
    description: 'Where Joshua commanded the sun to stand still.',
    region: 'Canaan', latitude: 31.8500, longitude: 35.1833,
    scriptureRef: 'Joshua 10',
    events: ['Sun stood still'],
  ),
  const BibleLocation(
    id: 'shiloh', name: 'Shiloh',
    description: 'Home of the Tabernacle before Jerusalem.',
    region: 'Canaan', latitude: 32.0564, longitude: 35.2897,
    scriptureRef: 'Joshua 18:1',
    events: ['Tabernacle located here'],
  ),
  // Jerusalem area
  const BibleLocation(
    id: 'jerusalem', name: 'Jerusalem',
    description: 'Holy city. Site of the Temple and Jesus\' crucifixion.',
    region: 'Canaan', latitude: 31.7683, longitude: 35.2137,
    scriptureRef: 'Throughout Bible',
    events: ['Solomon\'s Temple', 'Jesus\' crucifixion', 'Resurrection'],
  ),
  const BibleLocation(
    id: 'bethlehem', name: 'Bethlehem',
    description: 'Birthplace of Jesus Christ.',
    region: 'Canaan', latitude: 31.7054, longitude: 35.2024,
    scriptureRef: 'Micah 5:2, Matthew 2',
    events: ['Jesus\' birth', 'David\'s birthplace'],
  ),
  const BibleLocation(
    id: 'bethany', name: 'Bethany',
    description: 'Where Jesus raised Lazarus from the dead.',
    region: 'Judea', latitude: 31.7726, longitude: 35.2583,
    scriptureRef: 'John 11',
    events: ['Lazarus raised', 'Mary and Martha'],
  ),
  // Wilderness
  const BibleLocation(
    id: 'wilderness', name: 'Wilderness of Judea',
    description: 'Where Jesus was tempted for 40 days.',
    region: 'Judea', latitude: 31.6833, longitude: 35.3167,
    scriptureRef: 'Matthew 4:1-11',
    events: ['Jesus\' temptation', 'John the Baptist\' ministry'],
  ),
  const BibleLocation(
    id: 'dead_sea', name: 'Dead Sea',
    description: 'Site of Sodom and Gomorrah destruction.',
    region: 'Judea', latitude: 31.5590, longitude: 35.4732,
    scriptureRef: 'Genesis 19',
    events: ['Sodom and Gomorrah destroyed'],
  ),
  const BibleLocation(
    id: 'engedi', name: 'En Gedi',
    description: 'Where David hid from Saul.',
    region: 'Judea', latitude: 31.4667, longitude: 35.3833,
    scriptureRef: '1 Samuel 24',
    events: ['David spared Saul'],
  ),
  // Galilee
  const BibleLocation(
    id: 'nazareth', name: 'Nazareth',
    description: 'Where Jesus grew up.',
    region: 'Galilee', latitude: 32.7021, longitude: 35.2978,
    scriptureRef: 'Matthew 2:23',
    events: ['Jesus\' childhood', 'Rejection by hometown'],
  ),
  const BibleLocation(
    id: 'galilee', name: 'Sea of Galilee',
    description: 'Center of Jesus\' ministry.',
    region: 'Galilee', latitude: 32.8245, longitude: 35.5879,
    scriptureRef: 'Matthew 4:18-22',
    events: ['Calming the storm', 'Walking on water', 'Miraculous catch'],
  ),
  const BibleLocation(
    id: 'capernaum', name: 'Capernaum',
    description: 'Jesus\' base of operations in Galilee.',
    region: 'Galilee', latitude: 32.8803, longitude: 35.5733,
    scriptureRef: 'Matthew 4:13',
    events: ['Healing of paralytic', 'Many miracles'],
  ),
  const BibleLocation(
    id: 'tabor', name: 'Mount Tabor',
    description: 'Site of Deborah and Barak\'s victory.',
    region: 'Galilee', latitude: 32.6861, longitude: 35.3894,
    scriptureRef: 'Judges 4',
    events: ['Victory over Canaanites'],
  ),
  const BibleLocation(
    id: 'megiddo', name: 'Megiddo',
    description: 'Strategic fortress. Future site of Armageddon.',
    region: 'Galilee', latitude: 32.5850, longitude: 35.1847,
    scriptureRef: 'Revelation 16:16',
    events: ['Solomon\'s chariot city', 'Armageddon prophecy'],
  ),
  const BibleLocation(
    id: 'carmel', name: 'Mount Carmel',
    description: 'Where Elijah defeated the prophets of Baal.',
    region: 'Canaan', latitude: 32.7333, longitude: 35.0500,
    scriptureRef: '1 Kings 18',
    events: ['Elijah\'s contest with Baal'],
  ),
  const BibleLocation(
    id: 'hazor', name: 'Hazor',
    description: 'Major Canaanite city conquered by Joshua.',
    region: 'Galilee', latitude: 33.0167, longitude: 35.5667,
    scriptureRef: 'Joshua 11',
    events: ['Joshua\'s conquest'],
  ),
  const BibleLocation(
    id: 'dan', name: 'Dan',
    description: 'Northernmost city of Israel. Site of golden calf idolatry.',
    region: 'Galilee', latitude: 33.2483, longitude: 35.6508,
    scriptureRef: '1 Kings 12:29',
    events: ['Golden calf', 'Northern boundary'],
  ),
  // Jordan River area
  const BibleLocation(
    id: 'jordan_river', name: 'Jordan River',
    description: 'Where John baptized Jesus. Israelites crossed into Canaan.',
    region: 'Jordan', latitude: 31.7697, longitude: 35.5879,
    scriptureRef: 'Matthew 3:13-17',
    events: ['Jesus\' baptism', 'Naaman healed'],
  ),
  const BibleLocation(
    id: 'jerash', name: 'Gerasa (Jerash)',
    description: 'Where Jesus healed the demoniac.',
    region: 'Jordan', latitude: 32.2806, longitude: 35.8950,
    scriptureRef: 'Mark 5:1-20',
    events: ['Demoniac healed', 'Legion cast out'],
  ),
  // Samaria
  const BibleLocation(
    id: 'samaria', name: 'Samaria',
    description: 'Region between Galilee and Judea.',
    region: 'Samaria', latitude: 32.2761, longitude: 35.1979,
    scriptureRef: 'John 4',
    events: ['Woman at the well', 'Good Samaritan parable'],
  ),
  const BibleLocation(
    id: 'sychar', name: 'Sychar',
    description: 'Where Jesus met the Samaritan woman at Jacob\'s well.',
    region: 'Samaria', latitude: 32.2133, longitude: 35.2814,
    scriptureRef: 'John 4:5-42',
    events: ['Woman at the well'],
  ),
  // Valley of Elah
  const BibleLocation(
    id: 'elah', name: 'Valley of Elah',
    description: 'Where David defeated Goliath.',
    region: 'Canaan', latitude: 31.7000, longitude: 35.0000,
    scriptureRef: '1 Samuel 17',
    events: ['David vs Goliath'],
  ),
  // Coastal/Philistia
  const BibleLocation(
    id: 'caesarea', name: 'Caesarea',
    description: 'Where Peter preached to Cornelius.',
    region: 'Mediterranean', latitude: 32.5000, longitude: 34.8917,
    scriptureRef: 'Acts 10',
    events: ['Gentiles received Gospel'],
  ),
  const BibleLocation(
    id: 'joppa', name: 'Joppa',
    description: 'Where Peter raised Tabitha and saw the vision.',
    region: 'Mediterranean', latitude: 32.0500, longitude: 34.7500,
    scriptureRef: 'Acts 9-10',
    events: ['Tabitha raised', 'Peter\'s vision'],
  ),
  const BibleLocation(
    id: 'gaza', name: 'Gaza',
    description: 'Where Philip met the Ethiopian eunuch.',
    region: 'Mediterranean', latitude: 31.5000, longitude: 34.4667,
    scriptureRef: 'Acts 8:26-40',
    events: ['Ethiopian eunuch baptized'],
  ),
  // Syria
  const BibleLocation(
    id: 'damascus', name: 'Damascus',
    description: 'Where Paul was converted on the road.',
    region: 'Syria', latitude: 33.5138, longitude: 36.2765,
    scriptureRef: 'Acts 9:1-19',
    events: ['Paul\'s conversion', 'Ananias healed Paul'],
  ),
  const BibleLocation(
    id: 'antioch', name: 'Antioch',
    description: 'Where disciples were first called Christians.',
    region: 'Syria', latitude: 36.2021, longitude: 36.1588,
    scriptureRef: 'Acts 11:26',
    events: ['First called Christians', 'Missionary base'],
  ),
  // Mesopotamia
  const BibleLocation(
    id: 'babylon', name: 'Babylon',
    description: 'Where Judah was exiled.',
    region: 'Mesopotamia', latitude: 32.5355, longitude: 44.4275,
    scriptureRef: '2 Kings 24-25',
    events: ['Exile of Judah', 'Daniel\'s ministry'],
  ),
  const BibleLocation(
    id: 'nineveh', name: 'Nineveh',
    description: 'Capital of Assyria. Jonah preached here.',
    region: 'Assyria', latitude: 36.3594, longitude: 43.1528,
    scriptureRef: 'Jonah 3',
    events: ['Jonah\'s preaching', 'Nineveh repented'],
  ),
  const BibleLocation(
    id: 'persia', name: 'Persia',
    description: 'Empire that allowed Jews to return to Jerusalem.',
    region: 'Persia', latitude: 32.0, longitude: 53.0,
    scriptureRef: 'Ezra 1',
    events: ['Decree to rebuild Temple', 'Esther\'s story'],
  ),
  // Asia Minor - Seven Churches
  const BibleLocation(
    id: 'ephesus', name: 'Ephesus',
    description: 'Center of Diana worship. Major church established.',
    region: 'Asia Minor', latitude: 37.9497, longitude: 27.3644,
    scriptureRef: 'Acts 19',
    events: ['Riot of silversmiths', 'Letter to Ephesians'],
  ),
  const BibleLocation(
    id: 'smyrna', name: 'Smyrna',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 38.4189, longitude: 27.1286,
    scriptureRef: 'Revelation 2:8-11',
    events: ['Persecuted church'],
  ),
  const BibleLocation(
    id: 'pergamos', name: 'Pergamos',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 39.1333, longitude: 27.1833,
    scriptureRef: 'Revelation 2:12-17',
    events: ['Compromising church'],
  ),
  const BibleLocation(
    id: 'thyatira', name: 'Thyatira',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 38.9167, longitude: 27.8333,
    scriptureRef: 'Revelation 2:18-29',
    events: ['Tolerant church', 'Lydia\'s hometown'],
  ),
  const BibleLocation(
    id: 'sardis', name: 'Sardis',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 38.4886, longitude: 28.0400,
    scriptureRef: 'Revelation 3:1-6',
    events: ['Dead church'],
  ),
  const BibleLocation(
    id: 'philadelphia', name: 'Philadelphia',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 38.3500, longitude: 28.5167,
    scriptureRef: 'Revelation 3:7-13',
    events: ['Faithful church'],
  ),
  const BibleLocation(
    id: 'laodicea', name: 'Laodicea',
    description: 'One of the seven churches of Revelation.',
    region: 'Asia Minor', latitude: 37.8339, longitude: 29.1086,
    scriptureRef: 'Revelation 3:14-22',
    events: ['Lukewarm church'],
  ),
  // Europe
  const BibleLocation(
    id: 'philippi', name: 'Philippi',
    description: 'Where Paul established first European church.',
    region: 'Macedonia', latitude: 41.0167, longitude: 24.2833,
    scriptureRef: 'Acts 16',
    events: ['Lydia converted', 'Paul and Silas imprisoned'],
  ),
  const BibleLocation(
    id: 'thessalonica', name: 'Thessalonica',
    description: 'Major church Paul wrote two letters to.',
    region: 'Macedonia', latitude: 40.6401, longitude: 22.9444,
    scriptureRef: 'Acts 17',
    events: ['Paul\'s preaching', 'Two epistles'],
  ),
  const BibleLocation(
    id: 'bereas', name: 'Berea',
    description: 'Where Jews searched Scriptures daily.',
    region: 'Macedonia', latitude: 40.5167, longitude: 22.2000,
    scriptureRef: 'Acts 17:10-15',
    events: ['Noble Bereans'],
  ),
  const BibleLocation(
    id: 'athens', name: 'Athens',
    description: 'Where Paul preached on Mars Hill.',
    region: 'Greece', latitude: 37.9838, longitude: 23.7275,
    scriptureRef: 'Acts 17:16-34',
    events: ['Mars Hill sermon', 'Unknown God'],
  ),
  const BibleLocation(
    id: 'corinth', name: 'Corinth',
    description: 'Major city of Paul\'s ministry.',
    region: 'Greece', latitude: 37.9050, longitude: 22.8794,
    scriptureRef: 'Acts 18',
    events: ['Paul\'s long ministry', 'Two letters written'],
  ),
  const BibleLocation(
    id: 'rome', name: 'Rome',
    description: 'Capital of the Empire. Paul\'s destination.',
    region: 'Italy', latitude: 41.9028, longitude: 12.4964,
    scriptureRef: 'Acts 28',
    events: ['Paul imprisoned', 'Letter to Romans'],
  ),
  // Islands
  const BibleLocation(
    id: 'patmos', name: 'Patmos',
    description: 'Where John received Revelation.',
    region: 'Aegean Sea', latitude: 37.3167, longitude: 26.5500,
    scriptureRef: 'Revelation 1:9',
    events: ['Revelation written'],
  ),
  const BibleLocation(
    id: 'malta', name: 'Malta',
    description: 'Where Paul was shipwrecked.',
    region: 'Mediterranean', latitude: 35.9375, longitude: 14.3754,
    scriptureRef: 'Acts 28',
    events: ['Shipwreck', 'Paul bitten by viper'],
  ),
  const BibleLocation(
    id: 'crete', name: 'Crete',
    description: 'Island where Titus ministered.',
    region: 'Mediterranean', latitude: 35.2401, longitude: 24.8093,
    scriptureRef: 'Titus 1:5',
    events: ['Titus\' ministry', 'Letter to Titus'],
  ),
  const BibleLocation(
    id: 'cyprus', name: 'Cyprus',
    description: 'Island where Paul and Barnabas preached.',
    region: 'Mediterranean', latitude: 35.1264, longitude: 33.4299,
    scriptureRef: 'Acts 13',
    events: ['Saul\'s first missionary journey'],
  ),
];

/// OpenStreetMap-based Biblical Maps - Completely FREE
class BiblicalMapsPage extends ConsumerStatefulWidget {
  const BiblicalMapsPage({super.key});

  @override
  ConsumerState<BiblicalMapsPage> createState() => _BiblicalMapsPageState();
}

class _BiblicalMapsPageState extends ConsumerState<BiblicalMapsPage> {
  final MapController _mapController = MapController();
  String _searchQuery = '';
  String _selectedRegion = 'All';
  bool _showList = true;

  final List<String> _regions = [
    'All', 'Canaan', 'Galilee', 'Judea', 'Samaria', 'Egypt',
    'Mesopotamia', 'Macedonia', 'Greece', 'Asia Minor', 'Italy', 'Syria',
    'Assyria', 'Persia', 'Jordan', 'Mediterranean', 'Aegean Sea',
  ];

  List<BibleLocation> get _filteredLocations {
    return biblicalLocations.where((loc) {
      final matchesSearch = _searchQuery.isEmpty ||
          loc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRegion = _selectedRegion == 'All' || loc.region == _selectedRegion;
      return matchesSearch && matchesRegion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblical Maps'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
          ),
        ],
      ),
      body: _showList ? _buildListView() : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(31.7683, 35.2137),
            initialZoom: 7,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'app.openbible',
            ),
            MarkerLayer(
              markers: _filteredLocations.map((loc) => Marker(
                point: LatLng(loc.latitude, loc.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showLocationDetails(loc),
                  child: Icon(Icons.location_on, 
                    color: _getRegionColor(loc.region), 
                    size: 40),
                ),
              )).toList(),
            ),
          ],
        ),
        Positioned(
          top: 16, left: 16, right: 16,
          child: Card(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search biblical locations...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        Positioned(
          top: 80, left: 16,
          child: Card(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRegion,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: _regions.map((r) => 
                  DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedRegion = v!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search locations...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _regions.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_regions[index]),
                selected: _regions[index] == _selectedRegion,
                onSelected: (_) => setState(() => _selectedRegion = _regions[index]),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${_filteredLocations.length} of ${biblicalLocations.length} locations'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLocations.length,
            itemBuilder: (context, index) {
              final loc = _filteredLocations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRegionColor(loc.region),
                  child: const Icon(Icons.place, color: Colors.white),
                ),
                title: Text(loc.name),
                subtitle: Text('${loc.region} • ${loc.scriptureRef ?? ''}'),
                onTap: () => _showLocationDetails(loc),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRegionColor(String region) {
    final colors = {
      'Canaan': Colors.brown, 'Galilee': Colors.green,
      'Judea': Colors.orange, 'Egypt': Colors.yellow.shade800,
      'Mesopotamia': Colors.teal, 'Greece': Colors.blue,
      'Macedonia': Colors.purple, 'Asia Minor': Colors.pink,
      'Syria': Colors.indigo, 'Italy': Colors.red,
    };
    return colors[region] ?? Colors.grey;
  }

  void _showLocationDetails(BibleLocation loc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(loc.region, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(loc.description),
            if (loc.scriptureRef != null)
              Text('📖 ${loc.scriptureRef}', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (loc.events.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: loc.events.map((e) => Chip(
                  label: Text(e, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.shade100,
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _showList = false);
                    _mapController.move(LatLng(loc.latitude, loc.longitude), 12);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('View on Map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
