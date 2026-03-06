import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/constants/app_constants.dart';

class ReadingPlansState {
  static const _activePlanKey = 'reading_plan.active_plan_id';
  static const _boxName = 'reading_plans_state';
  static Box<String>? _box;
  static String? _activePlanId;

  static Future<void> init() async {
    _box ??= await Hive.openBox<String>(_boxName);
    _activePlanId = _box?.get(_activePlanKey);
  }

  static String? get activePlanId => _activePlanId;

  static Future<void> setActivePlan(String planId) async {
    _activePlanId = planId;
    _box ??= await Hive.openBox<String>(_boxName);
    await _box?.put(_activePlanKey, planId);
  }

  static Future<void> clearActivePlan() async {
    _activePlanId = null;
    _box ??= await Hive.openBox<String>(_boxName);
    await _box?.delete(_activePlanKey);
  }
}

/// Reading plans page - working version with in-memory state
class ReadingPlansPage extends ConsumerStatefulWidget {
  const ReadingPlansPage({super.key});

  @override
  ConsumerState<ReadingPlansPage> createState() => _ReadingPlansPageState();
}

class _ReadingPlansPageState extends ConsumerState<ReadingPlansPage> {
  List<ReadingPlan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      await ReadingPlansState.init();
      final plans = await _loadPlansFromJson();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading plans: $e');
      if (mounted) {
        setState(() {
          _plans = _getDefaultPlans();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<ReadingPlan>> _loadPlansFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/reading_plans.json');
      final jsonData = json.decode(jsonString);
      final List<dynamic> plansJson = jsonData['plans'];
      
      return plansJson.map((p) {
        final map = (p as Map).cast<String, dynamic>();
        final readings = (map['readings'] as List<dynamic>? ?? [])
            .map((r) {
              final rm = (r as Map).cast<String, dynamic>();
              return PlanReading(
                day: int.tryParse('${rm['day'] ?? 1}') ?? 1,
                reference: '${rm['reference'] ?? ''}',
                title: '${rm['title'] ?? ''}',
              );
            })
            .toList();

        return ReadingPlan(
          id: '${map['id'] ?? ''}',
          name: '${map['name'] ?? 'Reading Plan'}',
          description: '${map['description'] ?? ''}',
          durationDays: int.tryParse('${map['duration_days'] ?? 0}') ?? 0,
          readings: readings,
        );
      }).where((p) => p.id.isNotEmpty).toList();
    } catch (e) {
      return _getDefaultPlans();
    }
  }

  Future<void> _startPlan(ReadingPlan plan) async {
    try {
      await ReadingPlansState.setActivePlan(plan.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start plan: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Started ${plan.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _normalizeBookRouteId(String bookName) {
    final target = bookName.toLowerCase();
    if (BibleStructure.allBooks.any((b) => b.toLowerCase() == target)) {
      return target;
    }
    final compactTarget = target.replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final b in BibleStructure.allBooks) {
      final lower = b.toLowerCase();
      final compact = lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (compact == compactTarget || compact.startsWith(compactTarget) || compactTarget.startsWith(compact)) {
        return lower;
      }
    }
    return target;
  }

  void _continuePlan(ReadingPlan plan) {
    final reading = plan.readings.isNotEmpty ? plan.readings.first : null;
    if (reading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reading steps found for this plan.')),
      );
      return;
    }

    final match = RegExp(r'^\s*([1-3]?\s?[A-Za-z ]+)\s+(\d+)').firstMatch(reading.reference);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not parse reference: ${reading.reference}')),
      );
      return;
    }

    final bookName = match.group(1)!.trim();
    final chapter = int.tryParse(match.group(2)!) ?? 1;
    final routeBookId = _normalizeBookRouteId(bookName);

    context.push('/bible/book/$routeBookId/chapter/$chapter');
  }

  List<ReadingPlan> _getDefaultPlans() {
    return [
      ReadingPlan(
        id: 'genesis_30',
        name: 'Genesis in 30 Days',
        description: 'Read through the book of Genesis',
        durationDays: 30,
        readings: const [
          PlanReading(day: 1, reference: 'Genesis 1', title: 'Start'),
        ],
      ),
      ReadingPlan(
        id: 'gospel_john',
        name: 'Gospel of John',
        description: 'Read the Gospel of John in 21 days',
        durationDays: 21,
        readings: const [
          PlanReading(day: 1, reference: 'John 1', title: 'Start'),
        ],
      ),
      ReadingPlan(
        id: 'proverbs_31',
        name: 'Proverbs in 31 Days',
        description: 'Daily wisdom from Proverbs',
        durationDays: 31,
        readings: const [
          PlanReading(day: 1, reference: 'Proverbs 1', title: 'Start'),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activePlanId = ReadingPlansState.activePlanId;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reading Plans')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Plans'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _plans.length,
          itemBuilder: (context, index) {
            final plan = _plans[index];
            final isActive = plan.id == activePlanId;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isActive ? Colors.green.shade50 : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
                  child: Text(
                    '${plan.durationDays}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                title: Text(plan.name),
                subtitle: Text(plan.description),
                trailing: isActive 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.chevron_right),
                onTap: () => _showPlanDetails(plan, isActive),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPlanDetails(ReadingPlan plan, bool isActive) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (isActive)
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.green.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plan.description),
            const SizedBox(height: 8),
            Text('${plan.durationDays} days', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            if (!isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startPlan(plan),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('START PLAN'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _continuePlan(plan);
                  },
                  icon: const Icon(Icons.book),
                  label: const Text('CONTINUE READING'),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reading plan model
class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final List<PlanReading> readings;

  const ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    this.readings = const [],
  });
}

class PlanReading {
  final int day;
  final String reference;
  final String title;

  const PlanReading({
    required this.day,
    required this.reference,
    required this.title,
  });
}
