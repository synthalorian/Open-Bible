import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../streaks/presentation/pages/streaks_page.dart';
import '../../../prayer_journal/presentation/pages/prayer_journal_page.dart';
import '../../../concordance/presentation/pages/concordance_page.dart';
import '../../../maps/presentation/pages/bible_maps_page.dart';
import '../../../genealogy/presentation/pages/enhanced_genealogy_page.dart';
import '../../../illustrations/presentation/pages/illustrations_gallery_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../debug_storage_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('Reading Streaks'),
            subtitle: const Text('Track your daily reading'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StreaksPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Prayer Journal'),
            subtitle: const Text('Record and track your prayers'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrayerJournalPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Strong\'s Concordance'),
            subtitle: const Text('Greek & Hebrew word lookup'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConcordancePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Bible Maps'),
            subtitle: const Text('Interactive biblical maps with locations'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibleMapsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Genealogy'),
            subtitle: const Text('Family trees from Adam to Jesus'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenealogyPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Illustrations Gallery'),
            subtitle: const Text('Classic biblical artwork'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IllustrationsGalleryPage()),
            ),
          ),
          const Divider(),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Storage Debug'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugStoragePage()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
