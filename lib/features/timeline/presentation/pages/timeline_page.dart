import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timeline page - biblical history timeline
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  String _selectedPeriod = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblical Timeline'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Periods')),
              const PopupMenuItem(value: 'ot', child: Text('Old Testament')),
              const PopupMenuItem(value: 'nt', child: Text('New Testament')),
              const PopupMenuItem(value: 'intertestamental', child: Text('Intertestamental')),
            ],
          ),
        ],
      ),
      body: _buildTimeline(),
    );
  }

  Widget _buildTimeline() {
    final events = _getEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '📚',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biblical History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~4000 BC - ~100 AD',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline events
          ...events.map((event) => _TimelineEvent(event: event)),
        ],
      ),
    );
  }

  List<TimelineEvent> _getEvents() {
    final allEvents = [
      TimelineEvent(
        title: 'Creation',
        date: 'c. 4000 BC',
        description: 'God creates the heavens and the earth',
        reference: 'Genesis 1-2',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'The Flood',
        date: 'c. 2350 BC',
        description: 'God sends a flood; Noah builds the ark',
        reference: 'Genesis 6-9',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Abraham\'s Call',
        date: 'c. 2091 BC',
        description: 'God calls Abram to leave his homeland',
        reference: 'Genesis 12',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Exodus from Egypt',
        date: 'c. 1446 BC',
        description: 'Moses leads Israel out of slavery',
        reference: 'Exodus 12-14',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Giving of the Law',
        date: 'c. 1446 BC',
        description: 'God gives the Ten Commandments at Sinai',
        reference: 'Exodus 19-20',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Conquest of Canaan',
        date: 'c. 1406 BC',
        description: 'Joshua leads Israel into the Promised Land',
        reference: 'Joshua 1-24',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Kingdom of Israel',
        date: 'c. 1050 BC',
        description: 'Saul becomes first king of Israel',
        reference: '1 Samuel 10',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'David\'s Reign',
        date: 'c. 1010 BC',
        description: 'David becomes king and unifies Israel',
        reference: '2 Samuel 5',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Solomon\'s Temple',
        date: 'c. 966 BC',
        description: 'First temple built in Jerusalem',
        reference: '1 Kings 6',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Babylonian Exile',
        date: 'c. 586 BC',
        description: 'Jerusalem falls; temple destroyed',
        reference: '2 Kings 25',
        period: 'ot',
      ),
      TimelineEvent(
        title: 'Return & Restoration',
        date: 'c. 538 BC',
        description: 'Jews return; second temple built',
        reference: 'Ezra 1',
        period: 'intertestamental',
      ),
      TimelineEvent(
        title: 'Birth of Jesus',
        date: 'c. 5-4 BC',
        description: 'Jesus born in Bethlehem',
        reference: 'Matthew 1-2, Luke 2',
        period: 'nt',
      ),
      TimelineEvent(
        title: 'Crucifixion',
        date: 'c. 30-33 AD',
        description: 'Jesus dies and rises again',
        reference: 'Matthew 27-28',
        period: 'nt',
      ),
      TimelineEvent(
        title: 'Pentecost',
        date: 'c. 30-33 AD',
        description: 'Holy Spirit poured out; church begins',
        reference: 'Acts 2',
        period: 'nt',
      ),
      TimelineEvent(
        title: 'Paul\'s Ministry',
        date: 'c. 46-62 AD',
        description: 'Paul\'s missionary journeys',
        reference: 'Acts 13-28',
        period: 'nt',
      ),
    ];

    // Filter by selected period
    if (_selectedPeriod == 'all') {
      return allEvents;
    }
    return allEvents.where((e) => e.period == _selectedPeriod).toList();
  }
}

class TimelineEvent {
  final String title;
  final String date;
  final String description;
  final String reference;
  final String period;

  const TimelineEvent({
    required this.title,
    required this.date,
    required this.description,
    required this.reference,
    required this.period,
  });
}

class _TimelineEvent extends StatelessWidget {
  final TimelineEvent event;

  const _TimelineEvent({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getEventColor(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 100,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Event content
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _showEventDetails(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventColor(context).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.date,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getEventColor(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.reference,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEventColor(BuildContext context) {
    switch (event.period) {
      case 'ot':
        return Theme.of(context).colorScheme.primary;
      case 'nt':
        return Theme.of(context).colorScheme.tertiary;
      case 'intertestamental':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              event.date,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.menu_book),
                    label: Text('Read ${event.reference}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
