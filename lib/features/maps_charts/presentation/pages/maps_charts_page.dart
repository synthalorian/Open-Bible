import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/maps_charts_provider.dart';

/// Maps and Charts page - Bible maps, genealogy, and timeline
class MapsChartsPage extends ConsumerStatefulWidget {
  const MapsChartsPage({super.key});

  @override
  ConsumerState<MapsChartsPage> createState() => _MapsChartsPageState();
}

class _MapsChartsPageState extends ConsumerState<MapsChartsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps & Charts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Maps'),
            Tab(icon: Icon(Icons.account_tree), text: 'Genealogy'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MapsTab(),
          _GenealogyTab(),
          _TimelineTab(),
        ],
      ),
    );
  }
}

/// Maps tab
class _MapsTab extends ConsumerWidget {
  const _MapsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(mapsChartsProvider);
    final maps = data.maps;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MapCategory.values.length,
      itemBuilder: (context, index) {
        final category = MapCategory.values[index];
        final categoryMaps = maps.where((m) => m.category == category).toList();
        
        if (categoryMaps.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, mapCategoryLabel(category)),
            const SizedBox(height: 12),
            ...categoryMaps.map((map) => _buildMapCard(context, map)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(BuildContext context, BibleMap map) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMapDetail(context, map),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for map image
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.brown.shade100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: Colors.brown.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map View',
                      style: TextStyle(
                        color: Colors.brown.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    map.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    map.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (map.regions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: map.regions.take(3).map((region) => Chip(
                        label: Text(
                          region.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      )).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapDetail(BuildContext context, BibleMap map) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  map.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Map placeholder with interactive regions
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown.shade200),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 100,
                                color: Colors.brown.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Interactive Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap regions to learn more',
                                style: TextStyle(
                                  color: Colors.brown.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Region hotspots
                        ...map.regions.map((region) => Positioned(
                          left: region.x * MediaQuery.of(context).size.width * 0.8,
                          top: region.y * 300,
                          child: GestureDetector(
                            onTap: () => _showRegionDetail(context, region),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  region.name.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Regions list
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: map.regions.map((region) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          region.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(region.name),
                      subtitle: Text(region.description),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRegionDetail(BuildContext context, MapRegion region) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(region.name),
        content: Text(region.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Genealogy tab
class _GenealogyTab extends ConsumerWidget {
  const _GenealogyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(mapsChartsProvider);
    final charts = data.genealogyCharts;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: charts.length,
      itemBuilder: (context, index) {
        final chart = charts[index];
        return _buildGenealogyCard(context, ref, chart);
      },
    );
  }

  Widget _buildGenealogyCard(BuildContext context, WidgetRef ref, GenealogyChart chart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showGenealogyDetail(context, chart),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_tree,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chart.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chart.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(context, '${chart.people.length}', 'People'),
                  _buildStat(context, '${_countPatriarchs(chart)}', 'Patriarchs'),
                  _buildStat(context, '${_countKings(chart)}', 'Kings'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Preview of key people
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: chart.people
                      .where((p) => p.type != PersonType.person)
                      .take(5)
                      .map((person) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          avatar: Icon(
                            _getPersonIcon(person.type),
                            size: 16,
                            color: _getPersonColor(person.type),
                          ),
                          label: Text(person.name),
                          backgroundColor: _getPersonColor(person.type).withValues(alpha: 0.1),
                        ),
                      ))
                      .toList(),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Center(
                child: TextButton.icon(
                  onPressed: () => _showGenealogyDetail(context, chart),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Full Tree'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  int _countPatriarchs(GenealogyChart chart) {
    return chart.people.where((p) => p.type == PersonType.patriarch).length;
  }

  int _countKings(GenealogyChart chart) {
    return chart.people.where((p) => p.type == PersonType.king).length;
  }

  IconData _getPersonIcon(PersonType type) {
    switch (type) {
      case PersonType.patriarch:
        return Icons.star;
      case PersonType.king:
        return Icons.military_tech;
      case PersonType.prophet:
        return Icons.volume_up;
      case PersonType.jesus:
        return Icons.favorite;
      default:
        return Icons.person;
    }
  }

  Color _getPersonColor(PersonType type) {
    switch (type) {
      case PersonType.patriarch:
        return Colors.amber;
      case PersonType.king:
        return Colors.blue;
      case PersonType.prophet:
        return Colors.purple;
      case PersonType.jesus:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showGenealogyDetail(BuildContext context, GenealogyChart chart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenealogyDetailPage(chart: chart),
      ),
    );
  }
}

/// Timeline tab
class _TimelineTab extends ConsumerWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(mapsChartsProvider);
    final events = data.timelineEvents;

    // Group events by category
    final groupedEvents = <TimelineCategory, List<TimelineEvent>>{};
    for (final event in events) {
      groupedEvents.putIfAbsent(event.category, () => []).add(event);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: TimelineCategory.values.length,
      itemBuilder: (context, index) {
        final category = TimelineCategory.values[index];
        final categoryEvents = groupedEvents[category] ?? [];
        
        if (categoryEvents.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: timelineCategoryColor(category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timelineCategoryLabel(category),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: timelineCategoryColor(category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...categoryEvents.map((event) => _buildTimelineEventCard(context, event)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildTimelineEventCard(BuildContext context, TimelineEvent event) {
    final yearText = event.year < 0 
        ? '${event.year.abs()} BC' 
        : '${event.year} AD';

    return Card(
      margin: const EdgeInsets.only(bottom: 8, left: 20),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: timelineCategoryColor(event.category).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            yearText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: timelineCategoryColor(event.category),
            ),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(event.description),
        trailing: event.scripture != null
            ? Tooltip(
                message: event.scripture!,
                child: const Icon(Icons.menu_book, size: 18),
              )
            : null,
      ),
    );
  }
}

/// Genealogy detail page
class GenealogyDetailPage extends StatelessWidget {
  final GenealogyChart chart;

  const GenealogyDetailPage({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chart.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chart.people.length,
        itemBuilder: (context, index) {
          final person = chart.people[index];
          final isKeyFigure = person.type != PersonType.person;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isKeyFigure ? 2 : 0,
            color: isKeyFigure 
                ? _getPersonColor(person.type).withValues(alpha: 0.1)
                : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getPersonColor(person.type),
                child: Icon(
                  _getPersonIcon(person.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                person.name,
                style: TextStyle(
                  fontWeight: isKeyFigure ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (person.description != null)
                    Text(person.description!),
                  if (person.birthYear != null)
                    Text(
                      _formatYear(person.birthYear!) +
                          (person.deathYear != null 
                              ? ' - ${_formatYear(person.deathYear!)}' 
                              : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              isThreeLine: person.description != null && person.birthYear != null,
            ),
          );
        },
      ),
    );
  }

  String _formatYear(int year) {
    return year < 0 ? '${year.abs()} BC' : '$year AD';
  }

  Color _getPersonColor(PersonType type) {
    switch (type) {
      case PersonType.patriarch:
        return Colors.amber.shade700;
      case PersonType.king:
        return Colors.blue.shade700;
      case PersonType.prophet:
        return Colors.purple.shade700;
      case PersonType.jesus:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPersonIcon(PersonType type) {
    switch (type) {
      case PersonType.patriarch:
        return Icons.star;
      case PersonType.king:
        return Icons.military_tech;
      case PersonType.prophet:
        return Icons.volume_up;
      case PersonType.jesus:
        return Icons.favorite;
      default:
        return Icons.person;
    }
  }
}
