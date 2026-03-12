import 'package:flutter/material.dart';
import '../../presentation/widgets/prayer_journal_widget.dart';

/// Prayer journal page
class PrayerJournalPage extends StatefulWidget {
  const PrayerJournalPage({super.key});

  @override
  State<PrayerJournalPage> createState() => _PrayerJournalPageState();
}

class _PrayerJournalPageState extends State<PrayerJournalPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Prayer Journal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Answered'),
          ],
        ),
      ),
      body: Column(
        children: [
          const PrayerStatsCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PrayerJournalWidget(showAnswered: false),
                PrayerJournalWidget(showAnswered: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const AddPrayerFAB(),
    );
  }
}
