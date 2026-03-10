import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/genealogy/presentation/pages/genealogy_page.dart';
import '../features/bible/presentation/pages/bible_home_page.dart';
import '../features/bible/presentation/pages/book_chapters_page.dart';
import '../features/bible/presentation/pages/chapter_reader_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/bookmarks/presentation/pages/bookmarks_page.dart';
import '../features/notes/presentation/pages/notes_page.dart';
import '../features/highlights/presentation/pages/highlights_page.dart';
import '../features/reading_plans/presentation/pages/reading_plans_page.dart';
import '../features/daily_verse/presentation/pages/daily_verse_page.dart';
import '../features/prayer_journal/presentation/pages/prayer_journal_page.dart';
import '../features/concordance/presentation/pages/concordance_page.dart';
import '../features/commentary/presentation/pages/commentary_page.dart';
import '../features/maps/presentation/pages/biblical_maps_page.dart';
import '../features/timeline/presentation/pages/timeline_page.dart';
import '../features/streaks/presentation/pages/streaks_page.dart';
import '../features/devotional/presentation/pages/devotionals_page.dart';
import '../features/dictionary/presentation/pages/dictionary_page.dart';
import '../features/trivia/presentation/pages/trivia_page.dart';
import '../features/illustrations/presentation/pages/bible_illustrations_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/bible_downloads_page.dart';
import '../features/settings/presentation/pages/privacy_policy_page.dart';
import '../features/sharing/presentation/pages/share_verse_page.dart';

/// App navigation shell with bottom nav
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Bible',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

/// App router configuration
final GoRouter appRouter = GoRouter(
  initialLocation: '/bible',
  debugLogDiagnostics: true,
  routes: [
    // Main shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Bible branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bible',
              name: 'bible',
              builder: (context, state) => const BibleHomePage(),
              routes: [
                GoRoute(
                  path: 'book/:bookId',
                  name: 'book',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId']!;
                    return BookChaptersPage(bookId: bookId);
                  },
                  routes: [
                    GoRoute(
                      path: 'chapter/:chapter',
                      name: 'chapter',
                      builder: (context, state) {
                        final bookId = state.pathParameters['bookId']!;
                        final chapter = int.parse(state.pathParameters['chapter']!);
                        return ChapterReaderPage(
                          bookId: bookId,
                          chapter: chapter,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        
        // Search branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        
        // Saved branch (bookmarks, highlights, notes)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              builder: (context, state) => const BookmarksPage(),
              routes: [
                GoRoute(
                  path: 'notes',
                  name: 'notes',
                  builder: (context, state) => const NotesPage(),
                ),
                GoRoute(
                  path: 'highlights',
                  name: 'highlights',
                  builder: (context, state) => const HighlightsPage(),
                ),
              ],
            ),
          ],
        ),
        
        // Reading Plans branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plans',
              name: 'plans',
              builder: (context, state) => const ReadingPlansPage(),
            ),
          ],
        ),
        
        // More branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              name: 'more',
              builder: (context, state) => const MorePage(),
              routes: [
                GoRoute(
                  path: 'daily-verse',
                  name: 'daily-verse',
                  builder: (context, state) => const DailyVersePage(),
                ),
                GoRoute(
                  path: 'prayer-journal',
                  name: 'prayer-journal',
                  builder: (context, state) => const PrayerJournalPage(),
                ),
                GoRoute(
                  path: 'concordance',
                  name: 'concordance',
                  builder: (context, state) => const ConcordancePage(),
                ),
                GoRoute(
                  path: 'commentary',
                  name: 'commentary',
                  builder: (context, state) => const CommentaryPage(),
                ),
                GoRoute(
                  path: 'maps',
                  name: 'maps',
                  builder: (context, state) => const BiblicalMapsPage(),
                ),
                GoRoute(
                  path: 'timeline',
                  name: 'timeline',
                  builder: (context, state) => const TimelinePage(),
                ),
                GoRoute(
                  path: 'streaks',
                  name: 'streaks',
                  builder: (context, state) => const StreaksPage(),
                ),
                GoRoute(
                  path: 'history',
                  name: 'history',
                  builder: (context, state) => const HistoryPage(),
                ),
                GoRoute(
                  path: 'devotionals',
                  name: 'devotionals',
                  builder: (context, state) => const DevotionalsPage(),
                ),
                GoRoute(
                  path: 'dictionary',
                  name: 'dictionary',
                  builder: (context, state) => const BibleDictionaryPage(),
                ),
                GoRoute(
                  path: 'trivia',
                  name: 'trivia',
                  builder: (context, state) => const TriviaPage(),
                ),
                GoRoute(
                  path: 'illustrations',
                  name: 'illustrations',
                  builder: (context, state) => const BibleIllustrationsPage(),
                ),
                GoRoute(
                  path: 'genealogy',
                  name: 'genealogy',
                  builder: (context, state) => const GenealogyPage(),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  builder: (context, state) => const SettingsPage(),
                ),
                GoRoute(
                  path: 'downloads',
                  name: 'downloads',
                  builder: (context, state) => const BibleDownloadsPage(),
                ),
                GoRoute(
                  path: 'privacy',
                  name: 'privacy',
                  builder: (context, state) => const PrivacyPolicyPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    
    // Standalone routes (no bottom nav)
    GoRoute(
      path: '/share',
      name: 'share',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ShareVersePage(
          verseId: extra?['verseId'] ?? '',
          text: extra?['text'] ?? '',
          reference: extra?['reference'] ?? '',
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);

/// More page with additional features
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          _buildListTile(
            context,
            icon: Icons.wb_sunny_outlined,
            title: 'Daily Verse',
            subtitle: 'Today\'s verse of the day',
            route: '/more/daily-verse',
          ),
          _buildListTile(
            context,
            icon: Icons.edit_note_outlined,
            title: 'Prayer Journal',
            subtitle: 'Record your prayers',
            route: '/more/prayer-journal',
          ),
          _buildListTile(
            context,
            icon: Icons.translate_outlined,
            title: 'Concordance',
            subtitle: 'Strong\'s Greek & Hebrew',
            route: '/more/concordance',
          ),
          _buildListTile(
            context,
            icon: Icons.comment_outlined,
            title: 'Commentary',
            subtitle: 'Study notes & commentary',
            route: '/more/commentary',
          ),
          _buildListTile(
            context,
            icon: Icons.map_outlined,
            title: 'Biblical Maps',
            subtitle: 'Maps of Bible lands',
            route: '/more/maps',
          ),
          _buildListTile(
            context,
            icon: Icons.timeline_outlined,
            title: 'Timeline',
            subtitle: 'Biblical history timeline',
            route: '/more/timeline',
          ),
          _buildListTile(
            context,
            icon: Icons.local_fire_department_outlined,
            title: 'Reading Streaks',
            subtitle: 'Track your progress',
            route: '/more/streaks',
          ),
          _buildListTile(
            context,
            icon: Icons.history,
            title: 'Reading History',
            subtitle: 'View your reading history',
            route: '/more/history',
          ),
          _buildListTile(
            context,
            icon: Icons.account_tree_outlined,
            title: 'Genealogy',
            subtitle: 'Biblical family tree (Adam to Jesus)',
            route: '/more/genealogy',
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.favorite_outline,
            title: 'Daily Devotionals',
            subtitle: '30 days of devotionals',
            route: '/more/devotionals',
          ),
          _buildListTile(
            context,
            icon: Icons.menu_book_outlined,
            title: 'Bible Dictionary',
            subtitle: '120+ biblical terms',
            route: '/more/dictionary',
          ),
          _buildListTile(
            context,
            icon: Icons.quiz_outlined,
            title: 'Bible Trivia',
            subtitle: 'Test your knowledge',
            route: '/more/trivia',
          ),
          _buildListTile(
            context,
            icon: Icons.image_outlined,
            title: 'Bible Illustrations',
            subtitle: 'Classic artwork gallery',
            route: '/more/illustrations',
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            route: '/more/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
