import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/reading_plan_provider.dart';
import '../../../bible/presentation/pages/chapter_reader_page.dart';

/// Reading plans page - main entry for reading plans
class ReadingPlansPage extends ConsumerWidget {
  const ReadingPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingPlanState = ref.watch(readingPlanProvider);
    final plans = readingPlanState.plans;
    final activePlan = readingPlanState.activePlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlanDialog(context, ref),
          ),
        ],
      ),
      body: readingPlanState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? _buildEmptyState(context, ref)
              : _buildPlansList(context, ref, plans, activePlan),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reading Plans',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a reading plan to track your progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreatePlanDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Start a Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(
    BuildContext context,
    WidgetRef ref,
    List<ReadingPlan> plans,
    ReadingPlan? activePlan,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active plan section
        if (activePlan != null) ...[
          _buildSectionHeader(context, 'Active Plan'),
          const SizedBox(height: 12),
          _buildActivePlanCard(context, ref, activePlan),
          const SizedBox(height: 32),
        ],

        // All plans section
        _buildSectionHeader(context, 'All Plans'),
        const SizedBox(height: 12),
        ...plans.map((plan) => _buildPlanCard(context, ref, plan, isActive: plan.id == activePlan?.id)),
      ],
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

  Widget _buildActivePlanCard(BuildContext context, WidgetRef ref, ReadingPlan plan) {
    final progress = plan.progressPercentage;
    final isCompleted = plan.isCompleted;

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showPlanDetails(context, ref, plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    planTypeIcon(plan.type),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Chip(
                      label: const Text('Completed!'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 12,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.completedDays} of ${plan.totalDays} days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Continue button
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showPlanDetails(context, ref, plan),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(plan.currentDay > 1 
                        ? 'Continue Day ${plan.currentDay}' 
                        : 'Start Reading'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    ReadingPlan plan, {
    required bool isActive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 0 : 0,
      color: isActive 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(
          planTypeIcon(plan.type),
          color: isActive 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(plan.name),
        subtitle: Text('${plan.completedDays}/${plan.totalDays} days • ${planTypeLabel(plan.type)}'),
        trailing: isActive
            ? Chip(
                label: const Text('Active'),
                visualDensity: VisualDensity.compact,
                backgroundColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'set_active') {
                    ref.read(readingPlanProvider.notifier).setActivePlan(plan.id);
                  } else if (value == 'reset') {
                    _showResetDialog(context, ref, plan);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, ref, plan);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'set_active',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text('Set as Active'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Reset Progress'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: () => _showPlanDetails(context, ref, plan),
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose a Reading Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.gospels,
                        'The Gospels in 30 Days',
                        'Matthew, Mark, Luke, John',
                        Icons.favorite,
                        Colors.red,
                      ),
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.psalmsAndProverbs,
                        'Psalms & Proverbs',
                        '31 days of wisdom and praise',
                        Icons.format_quote,
                        Colors.blue,
                      ),
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.newTestament,
                        'New Testament in 90 Days',
                        'Complete New Testament journey',
                        Icons.auto_stories,
                        Colors.green,
                      ),
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.oldTestament,
                        'Old Testament Overview',
                        'Key passages from the Old Testament',
                        Icons.menu_book,
                        Colors.orange,
                      ),
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.wholeBible,
                        'Bible in a Year',
                        'Complete Bible in 365 days',
                        Icons.public,
                        Colors.purple,
                      ),
                      _buildPlanTypeTile(
                        context,
                        ref,
                        PlanType.chronological,
                        'Chronological Bible',
                        'Read in historical order',
                        Icons.schedule,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanTypeTile(
    BuildContext context,
    WidgetRef ref,
    PlanType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          ref.read(readingPlanProvider.notifier).createPlan(type);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title plan created!')),
          );
        },
      ),
    );
  }

  void _showPlanDetails(BuildContext context, WidgetRef ref, ReadingPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailsPage(plan: plan),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, ReadingPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Plan?'),
        content: Text('This will reset all progress in "${plan.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(readingPlanProvider.notifier).resetPlan(plan.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan reset')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ReadingPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(readingPlanProvider.notifier).deletePlan(plan.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Plan details page - shows individual days
class PlanDetailsPage extends ConsumerWidget {
  final ReadingPlan plan;

  const PlanDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingPlanProvider);
    final livePlan = state.plans.where((p) => p.id == plan.id).isNotEmpty
        ? state.plans.firstWhere((p) => p.id == plan.id)
        : plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(livePlan.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: livePlan.days.length,
        itemBuilder: (context, index) {
          final day = livePlan.days[index];
          return _buildDayCard(context, ref, day);
        },
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, WidgetRef ref, ReadingDay day) {
    final isCompleted = day.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 0 : 1,
      color: isCompleted
          ? Colors.green.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _showDayReadings(context, ref, day),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${day.dayNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${day.dayNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.segments.map((s) => s.displayText).join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                FilledButton(
                  onPressed: () {
                    _showDayReadings(context, ref, day);
                  },
                  child: const Text('Read'),
                )
              else
                const Chip(
                  label: Text('Done'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayReadings(BuildContext context, WidgetRef ref, ReadingDay day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Day ${day.dayNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ...day.segments.map((segment) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.menu_book),
                          title: Text(segment.bookName),
                          subtitle: Text(
                            segment.endChapter != null && segment.endChapter != segment.startChapter
                                ? 'Chapters ${segment.startChapter}-${segment.endChapter}'
                                : segment.startVerse != null
                                    ? 'Chapter ${segment.startChapter}:${segment.startVerse}'
                                    : 'Chapter ${segment.startChapter}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterReaderPage(
                                  bookId: segment.bookName.toLowerCase(),
                                  chapter: segment.startChapter,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await ref.read(readingPlanProvider.notifier).completeDay(
                        day.dayNumber,
                        planId: plan.id,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Day ${day.dayNumber} marked as complete!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark as Complete'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
