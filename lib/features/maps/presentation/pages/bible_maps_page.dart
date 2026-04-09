import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/bible_map_service.dart';

/// Enhanced Bible Maps Page
class BibleMapsPage extends StatefulWidget {
  const BibleMapsPage({super.key});

  @override
  State<BibleMapsPage> createState() => _BibleMapsPageState();
}

class _BibleMapsPageState extends State<BibleMapsPage> {
  final BibleMapService _service = BibleMapService();
  bool _isLoading = true;
  BibleMapData? _selectedMap;
  MapLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.load();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Maps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: _selectedMap != null
          ? _buildMapDetail()
          : _buildMapList(),
    );
  }

  Widget _buildMapList() {
    final maps = _service.getAllMaps();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: maps.length,
      itemBuilder: (context, index) {
        final map = maps[index];
        return _buildMapCard(map);
      },
    );
  }

  Widget _buildMapCard(BibleMapData map) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => setState(() => _selectedMap = map),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.brown.shade100,
                    Colors.brown.shade200,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 64,
                      color: Colors.brown.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${map.locations.length} Locations',
                      style: TextStyle(
                        color: Colors.brown.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          map.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (map.period.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            map.period,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    map.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Location chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: map.locations.take(5).map((location) => 
                      ActionChip(
                        avatar: const Icon(Icons.location_on, size: 16),
                        label: Text(location.name),
                        onPressed: () {
                          setState(() {
                            _selectedMap = map;
                            _selectedLocation = location;
                          });
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapDetail() {
    final map = _selectedMap!;

    return Scaffold(
      appBar: AppBar(
        title: Text(map.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _selectedMap = null;
            _selectedLocation = null;
          }),
        ),
      ),
      body: Column(
        children: [
          // OpenStreetMap (free + open-source) with real coordinates
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _initialCenterFor(map),
                  initialZoom: 6,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, __) => setState(() => _selectedLocation = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.openbible.app',
                  ),
                  if (map.routes.isNotEmpty)
                    PolylineLayer(
                      polylines: _buildRoutePolylines(map),
                    ),
                  MarkerLayer(
                    markers: map.locations.map((location) {
                      final isSelected = _selectedLocation?.name == location.name;
                      return Marker(
                        width: isSelected ? 46 : 40,
                        height: isSelected ? 46 : 40,
                        point: LatLng(location.lat, location.lng),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLocation = location),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.red.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: isSelected ? 24 : 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Locations list
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Locations',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (map.routes.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showRoutesSheet(),
                          icon: const Icon(Icons.route),
                          label: Text('${map.routes.length} Routes'),
                        ),
                    ],
                  ),
                ),

                // Locations list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: map.locations.length,
                    itemBuilder: (context, index) {
                      final location = map.locations[index];
                      final isSelected = _selectedLocation?.name == location.name;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 4 : 0,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.brown.shade300,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            location.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            location.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.menu_book, size: 20),
                            onPressed: () => _showVerseDialog(location),
                          ),
                          onTap: () => setState(() => _selectedLocation = location),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LatLng _initialCenterFor(BibleMapData map) {
    if (map.locations.isEmpty) return const LatLng(31.7683, 35.2137); // Jerusalem

    final avgLat = map.locations.fold<double>(0, (sum, l) => sum + l.lat) / map.locations.length;
    final avgLng = map.locations.fold<double>(0, (sum, l) => sum + l.lng) / map.locations.length;
    return LatLng(avgLat, avgLng);
  }

  List<Polyline> _buildRoutePolylines(BibleMapData map) {
    final byName = {for (final l in map.locations) l.name: l};

    return map.routes.map((route) {
      final from = byName[route.from];
      final to = byName[route.to];
      if (from == null || to == null) {
        return Polyline(points: const [], strokeWidth: 0);
      }

      return Polyline(
        points: [LatLng(from.lat, from.lng), LatLng(to.lat, to.lng)],
        color: Colors.blue.shade700,
        strokeWidth: 3,
      );
    }).where((p) => p.points.isNotEmpty).toList();
  }

  void _showRoutesSheet() {
    final map = _selectedMap!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Routes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: map.routes.length,
                itemBuilder: (context, index) {
                  final route = map.routes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text('${index + 1}'),
                      ),
                      title: Text('${route.from} → ${route.to}'),
                      subtitle: Text(route.description),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerseDialog(MapLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location.verse,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Maps'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter location or map name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            final results = _service.search(query);
            _showSearchResults(results, query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(List<BibleMapData> results, String query) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Search Results for "$query"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) => 
                        _buildMapCard(results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

