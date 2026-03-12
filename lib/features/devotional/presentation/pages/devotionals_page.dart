import 'package:flutter/material.dart';
import '../../presentation/widgets/devotional_widget.dart';

/// Devotionals page
class DevotionalsPage extends StatelessWidget {
  const DevotionalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Devotionals'),
      ),
      body: ListView(
        children: const [
          DailyDevotionalWidget(compact: false),
          RecentDevotionalsWidget(),
        ],
      ),
    );
  }
}
