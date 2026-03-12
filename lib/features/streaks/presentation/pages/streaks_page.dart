import 'package:flutter/material.dart';
import '../../presentation/widgets/streaks_widget.dart';

/// Reading streaks page
class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Streaks'),
      ),
      body: ListView(
        children: const [
          ReadingStreaksWidget(showDetails: true),
          WeeklyStreakCalendar(),
        ],
      ),
    );
  }
}
