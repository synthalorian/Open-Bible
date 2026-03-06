import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DailyDevotional {
  final int id;
  final String title;
  final String verse;
  final String text;
  final String devotional;
  final String prayer;

  DailyDevotional({
    required this.id,
    required this.title,
    required this.verse,
    required this.text,
    required this.devotional,
    required this.prayer,
  });

  factory DailyDevotional.fromJson(Map<String, dynamic> json) {
    return DailyDevotional(
      id: json['id'],
      title: json['title'],
      verse: json['verse'],
      text: json['text'],
      devotional: json['devotional'],
      prayer: json['prayer'],
    );
  }
}

class DevotionalsPage extends StatefulWidget {
  const DevotionalsPage({super.key});

  @override
  State<DevotionalsPage> createState() => _DevotionalsPageState();
}

class _DevotionalsPageState extends State<DevotionalsPage> {
  List<DailyDevotional> devotionals = [];
  DailyDevotional? todayDevotional;
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDevotionals();
  }

  Future<void> _loadDevotionals() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/daily_devotionals.json');
      final jsonData = json.decode(jsonString);
      final List<dynamic> devotionalList = jsonData['devotionals'];
      
      setState(() {
        devotionals = devotionalList.map((d) => DailyDevotional.fromJson(d)).toList();
        // Pick today's devotional based on day of month
        final dayOfMonth = DateTime.now().day - 1;
        currentIndex = dayOfMonth % devotionals.length;
        todayDevotional = devotionals[currentIndex];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _goToDevotional(int index) {
    if (index >= 0 && index < devotionals.length) {
      setState(() {
        currentIndex = index;
        todayDevotional = devotionals[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Devotionals')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (todayDevotional == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Devotionals')),
        body: const Center(child: Text('No devotionals available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Devotionals'),
        actions: [
          TextButton.icon(
            onPressed: () => _showAllDevotionals(context),
            icon: const Icon(Icons.list, color: Colors.white),
            label: const Text('All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Day ${currentIndex + 1} of ${devotionals.length}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todayDevotional!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Scripture section
            _buildSectionCard(
              'Scripture',
              Icons.menu_book,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todayDevotional!.verse,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todayDevotional!.text,
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Devotional section
            _buildSectionCard(
              'Devotional',
              Icons.lightbulb_outline,
              Text(
                todayDevotional!.devotional,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
            
            // Prayer section
            _buildSectionCard(
              'Prayer',
              Icons.favorite,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  todayDevotional!.prayer,
                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.blue.shade900),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: currentIndex > 0 ? () => _goToDevotional(currentIndex - 1) : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  onPressed: currentIndex < devotionals.length - 1 ? () => _goToDevotional(currentIndex + 1) : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  void _showAllDevotionals(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Devotionals',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${devotionals.length} daily readings', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: devotionals.length,
                  itemBuilder: (context, index) {
                    final d = devotionals[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(d.title),
                      subtitle: Text(d.verse),
                      selected: index == currentIndex,
                      selectedTileColor: Colors.blue.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        _goToDevotional(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
