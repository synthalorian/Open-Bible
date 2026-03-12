import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biblical_maps_page.dart';

/// OpenStreetMap-based Biblical Maps - Completely FREE
class BiblicalMapsOSMPage extends ConsumerStatefulWidget {
  const BiblicalMapsOSMPage({super.key});

  @override
  ConsumerState<BiblicalMapsOSMPage> createState() => _BiblicalMapsOSMPageState();
}

class _BiblicalMapsOSMPageState extends ConsumerState<BiblicalMapsOSMPage> {
  final MapController _mapController = MapController();
  String _searchQuery = '';
  String _selectedRegion = 'All';
  bool _showList = true;

  final List<String> _regions = [
    'All', 'Canaan', 'Galilee', 'Judea', 'Samaria', 'Egypt',
    'Mesopotamia', 'Mediterranean', 'Macedonia', 'Greece',
    'Asia Minor', 'Italy', 'Sinai Peninsula', 'Jordan', 'Syria',
    'Persia', 'Assyria', 'Aegean Sea',
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biblical Maps'),
            Text(
              'OpenStreetMap - Free Forever',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
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
            initialCenter: LatLng(31.7683, 35.2137), // Jerusalem
            initialZoom: 7,
          ),
          children: [
            // FREE OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'app.openbible',
            ),
            // Alternative: Satellite imagery from ESRI (also free)
            // urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            
            MarkerLayer(
              markers: _filteredLocations.map((loc) => Marker(
                point: LatLng(loc.latitude, loc.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showLocationDetails(loc),
                  child: Icon(
                    Icons.location_on,
                    color: _getRegionColor(loc.region),
                    size: 40,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        // Search overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
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
        // Region filter
        Positioned(
          top: 80,
          left: 16,
          child: Card(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRegion,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: _regions.map((r) => 
                  DropdownMenuItem(value: r, child: Text(r))
                ).toList(),
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
            itemBuilder: (context, index) {
              final region = _regions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(region),
                  selected: region == _selectedRegion,
                  onSelected: (_) => setState(() => _selectedRegion = region),
                ),
              );
            },
          ),
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
                subtitle: Text(loc.region),
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
      'Judea': Colors.orange, 'Samaria': Colors.purple,
      'Egypt': Colors.yellow.shade800, 'Mesopotamia': Colors.teal,
    };
    return colors[region] ?? Colors.blue;
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
            if (loc.scriptureRef != null) ...[
              const SizedBox(height: 8),
              Text('📖 ${loc.scriptureRef}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _showList = false);
                    _mapController.move(
                      LatLng(loc.latitude, loc.longitude),
                      12,
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('View on Map'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // Open external maps
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Google Maps'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
