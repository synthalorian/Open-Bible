import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';

/// Reading plan provider
final readingPlanProvider = StateNotifierProvider<ReadingPlanNotifier, ReadingPlanState>((ref) {
  return ReadingPlanNotifier();
});

/// Reading plan types
enum PlanType {
  chronological,
  thematic,
  newTestament,
  oldTestament,
  gospels,
  psalmsAndProverbs,
  wholeBible,
  custom,
}

String planTypeLabel(PlanType type) {
  switch (type) {
    case PlanType.chronological:
      return 'Chronological';
    case PlanType.thematic:
      return 'Thematic';
    case PlanType.newTestament:
      return 'New Testament';
    case PlanType.oldTestament:
      return 'Old Testament';
    case PlanType.gospels:
      return 'Gospels';
    case PlanType.psalmsAndProverbs:
      return 'Psalms & Proverbs';
    case PlanType.wholeBible:
      return 'Whole Bible (365 Days)';
    case PlanType.custom:
      return 'Custom Plan';
  }
}

IconData planTypeIcon(PlanType type) {
  switch (type) {
    case PlanType.chronological:
      return Icons.schedule;
    case PlanType.thematic:
      return Icons.category;
    case PlanType.newTestament:
      return Icons.auto_stories;
    case PlanType.oldTestament:
      return Icons.menu_book;
    case PlanType.gospels:
      return Icons.favorite;
    case PlanType.psalmsAndProverbs:
      return Icons.format_quote;
    case PlanType.wholeBible:
      return Icons.public;
    case PlanType.custom:
      return Icons.edit;
  }
}

/// Reading plan day model
class ReadingDay {
  final int dayNumber;
  final List<ReadingSegment> segments;
  final bool isCompleted;
  final DateTime? completedDate;

  ReadingDay({
    required this.dayNumber,
    required this.segments,
    this.isCompleted = false,
    this.completedDate,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'segments': segments.map((s) => s.toJson()).toList(),
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
  };

  factory ReadingDay.fromJson(Map<String, dynamic> json) => ReadingDay(
    dayNumber: json['dayNumber'] ?? 0,
    segments: (json['segments'] as List?)
            ?.map((s) => ReadingSegment.fromJson(s))
            .toList() ??
        [],
    isCompleted: json['isCompleted'] ?? false,
    completedDate: json['completedDate'] != null
        ? DateTime.tryParse(json['completedDate'])
        : null,
  );

  ReadingDay copyWith({
    int? dayNumber,
    List<ReadingSegment>? segments,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return ReadingDay(
      dayNumber: dayNumber ?? this.dayNumber,
      segments: segments ?? this.segments,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

/// Reading segment (single reading)
class ReadingSegment {
  final String bookId;
  final String bookName;
  final int startChapter;
  final int? startVerse;
  final int? endChapter;
  final int? endVerse;

  ReadingSegment({
    required this.bookId,
    required this.bookName,
    required this.startChapter,
    this.startVerse,
    this.endChapter,
    this.endVerse,
  });

  String get displayText {
    if (endChapter != null && endChapter != startChapter) {
      return '$bookName $startChapter-$endChapter';
    } else if (startVerse != null) {
      if (endVerse != null && endVerse != startVerse) {
        return '$bookName $startChapter:$startVerse-$endVerse';
      }
      return '$bookName $startChapter:$startVerse';
    }
    return '$bookName $startChapter';
  }

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'startChapter': startChapter,
    'startVerse': startVerse,
    'endChapter': endChapter,
    'endVerse': endVerse,
  };

  factory ReadingSegment.fromJson(Map<String, dynamic> json) => ReadingSegment(
    bookId: json['bookId'] ?? '',
    bookName: json['bookName'] ?? '',
    startChapter: json['startChapter'] ?? 1,
    startVerse: json['startVerse'],
    endChapter: json['endChapter'],
    endVerse: json['endVerse'],
  );
}

/// Reading plan model
class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final PlanType type;
  final int totalDays;
  final List<ReadingDay> days;
  final DateTime? startDate;
  final int currentDay;
  final DateTime createdAt;

  ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.totalDays,
    required this.days,
    this.startDate,
    this.currentDay = 1,
    required this.createdAt,
  });

  int get completedDays => days.where((d) => d.isCompleted).length;
  double get progressPercentage => totalDays > 0 ? (completedDays / totalDays) * 100 : 0;
  bool get isCompleted => completedDays >= totalDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'totalDays': totalDays,
    'days': days.map((d) => d.toJson()).toList(),
    'startDate': startDate?.toIso8601String(),
    'currentDay': currentDay,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReadingPlan.fromJson(Map<String, dynamic> json) => ReadingPlan(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    type: PlanType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => PlanType.custom,
    ),
    totalDays: json['totalDays'] ?? 0,
    days: (json['days'] as List?)
            ?.map((d) => ReadingDay.fromJson(d))
            .toList() ??
        [],
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate'])
        : null,
    currentDay: json['currentDay'] ?? 1,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );

  ReadingPlan copyWith({
    String? id,
    String? name,
    String? description,
    PlanType? type,
    int? totalDays,
    List<ReadingDay>? days,
    DateTime? startDate,
    int? currentDay,
    DateTime? createdAt,
  }) {
    return ReadingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      totalDays: totalDays ?? this.totalDays,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
      currentDay: currentDay ?? this.currentDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Reading plan state
class ReadingPlanState {
  final List<ReadingPlan> plans;
  final ReadingPlan? activePlan;
  final bool isLoading;
  final String? error;

  ReadingPlanState({
    this.plans = const [],
    this.activePlan,
    this.isLoading = false,
    this.error,
  });

  ReadingPlanState copyWith({
    List<ReadingPlan>? plans,
    ReadingPlan? activePlan,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearActivePlan = false,
  }) {
    return ReadingPlanState(
      plans: plans ?? this.plans,
      activePlan: clearActivePlan ? null : (activePlan ?? this.activePlan),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Reading plan notifier
class ReadingPlanNotifier extends StateNotifier<ReadingPlanState> {
  ReadingPlanNotifier() : super(ReadingPlanState()) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    if (state.isLoading) return; // Prevent concurrent loads

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList('reading_plans') ?? [];

      final plans = plansJson
          .map((json) {
            try {
              return ReadingPlan.fromJson(jsonDecode(json));
            } catch (e) {
              debugPrint('Failed to parse reading plan JSON: $e');
              return null;
            }
          })
          .whereType<ReadingPlan>()
          .toList();

      // If persisted data is empty/corrupt, bootstrap a default plan.
      if (plans.isEmpty) {
        final bootPlan = _createDefaultPlan();
        plans.add(bootPlan);
        await _savePlans(plans);
        await prefs.setString('active_plan_id', bootPlan.id);
      }

      final activePlanId = prefs.getString('active_plan_id');
      final activePlan = plans.firstWhere(
        (p) => p.id == activePlanId,
        orElse: () => plans.first,
      );

      // Self-heal active_plan_id if missing or stale.
      if (activePlanId == null || !plans.any((p) => p.id == activePlanId)) {
        await prefs.setString('active_plan_id', activePlan.id);
      }

      state = state.copyWith(
        plans: plans,
        activePlan: activePlan,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      // Strict fallback: never leave plans empty in UI.
      final fallbackPlan = _createDefaultPlan();

      try {
        await _savePlans([fallbackPlan]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_plan_id', fallbackPlan.id);
      } catch (e) {
        // Storage may be unavailable on this build; keep fallback in memory.
        debugPrint('Failed to save fallback reading plan: $e');
      }

      state = state.copyWith(
        plans: [fallbackPlan],
        activePlan: fallbackPlan,
        isLoading: false,
        error: 'Recovered reading plans from storage issue: $e',
      );
    }
  }

  ReadingPlan _createDefaultPlan() {
    return _createGospelsPlan();
  }

  Future<void> _savePlans(List<ReadingPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = plans.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('reading_plans', plansJson);
  }

  Future<void> setActivePlan(String planId) async {
    final plan = state.plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => state.plans.first,
    );

    state = state.copyWith(activePlan: plan);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_plan_id', planId);
    } catch (e) {
      // Storage unavailable; keep in-memory update.
      debugPrint('Failed to persist active plan: $e');
    }
  }

  Future<void> completeDay(int dayNumber, {String? planId}) async {
    final targetPlan = planId != null
        ? state.plans.where((p) => p.id == planId).isNotEmpty
            ? state.plans.firstWhere((p) => p.id == planId)
            : state.activePlan
        : state.activePlan;

    if (targetPlan == null) return;

    final updatedDays = targetPlan.days.map((day) {
      if (day.dayNumber == dayNumber) {
        return day.copyWith(
          isCompleted: true,
          completedDate: DateTime.now(),
        );
      }
      return day;
    }).toList();

    final nextDay = dayNumber + 1;
    final boundedNextDay = nextDay > targetPlan.totalDays
        ? targetPlan.totalDays
        : nextDay;

    final updatedPlan = targetPlan.copyWith(
      days: updatedDays,
      currentDay: boundedNextDay,
      startDate: targetPlan.startDate ?? DateTime.now(),
    );

    final updatedPlans = state.plans.map((p) {
      if (p.id == updatedPlan.id) return updatedPlan;
      return p;
    }).toList();

    try {
      await _savePlans(updatedPlans);
    } catch (e) {
      // Storage may be unavailable on some builds; keep in-memory update.
      debugPrint('Failed to save completed day: $e');
    }

    final shouldPromoteToActive = planId != null;

    state = state.copyWith(
      plans: updatedPlans,
      activePlan: shouldPromoteToActive
          ? updatedPlan
          : (state.activePlan?.id == updatedPlan.id ? updatedPlan : state.activePlan),
    );
  }

  Future<void> createPlan(PlanType type) async {
    ReadingPlan newPlan;
    switch (type) {
      case PlanType.chronological:
        newPlan = _createChronologicalPlan();
        break;
      case PlanType.newTestament:
        newPlan = _createNewTestamentPlan();
        break;
      case PlanType.oldTestament:
        newPlan = _createOldTestamentPlan();
        break;
      case PlanType.gospels:
        newPlan = _createGospelsPlan();
        break;
      case PlanType.psalmsAndProverbs:
        newPlan = _createPsalmsPlan();
        break;
      case PlanType.wholeBible:
        newPlan = _createWholeBiblePlan();
        break;
      case PlanType.thematic:
        newPlan = _createThematicPlan();
        break;
      case PlanType.custom:
        newPlan = _createCustomPlan();
        break;
    }

    final startedPlan = newPlan.copyWith(startDate: DateTime.now());
    final alreadyExists = state.plans.any((p) => p.id == startedPlan.id);
    final updatedPlans = alreadyExists ? state.plans : [...state.plans, startedPlan];

    try {
      await _savePlans(updatedPlans);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_plan_id', startedPlan.id);
    } catch (e) {
      // Storage may be unavailable on some builds; keep in-memory update.
      debugPrint('Failed to save new reading plan: $e');
    }

    state = state.copyWith(
      plans: updatedPlans,
      activePlan: startedPlan,
      clearError: true,
    );
  }

  Future<void> deletePlan(String planId) async {
    final wasActive = state.activePlan?.id == planId;
    final updatedPlans = state.plans.where((p) => p.id != planId).toList();

    if (wasActive) {
      state = state.copyWith(
        plans: updatedPlans,
        activePlan: updatedPlans.isNotEmpty ? updatedPlans.first : null,
        clearActivePlan: updatedPlans.isEmpty,
      );
    } else {
      state = state.copyWith(plans: updatedPlans);
    }

    try {
      await _savePlans(updatedPlans);
      if (wasActive) {
        final prefs = await SharedPreferences.getInstance();
        if (updatedPlans.isNotEmpty) {
          await prefs.setString('active_plan_id', updatedPlans.first.id);
        } else {
          await prefs.remove('active_plan_id');
        }
      }
    } catch (e) {
      // Storage unavailable; keep in-memory update.
      debugPrint('Failed to save plan deletion: $e');
    }
  }

  Future<void> resetPlan(String planId) async {
    final plan = state.plans.firstWhere((p) => p.id == planId);
    final resetDays = plan.days
        .map((d) => d.copyWith(isCompleted: false, completedDate: null))
        .toList();
    final resetPlan = plan.copyWith(days: resetDays, currentDay: 1);

    final updatedPlans = state.plans.map((p) {
      if (p.id == planId) return resetPlan;
      return p;
    }).toList();

    state = state.copyWith(
      plans: updatedPlans,
      activePlan: state.activePlan?.id == planId ? resetPlan : state.activePlan,
    );

    try {
      await _savePlans(updatedPlans);
    } catch (e) {
      // Storage unavailable; keep in-memory update.
      debugPrint('Failed to save plan reset: $e');
    }
  }

  // ==================== PLAN TEMPLATES ====================

  ReadingPlan _createGospelsPlan() {
    return ReadingPlan(
      id: 'gospels_${DateTime.now().millisecondsSinceEpoch}',
      name: 'The Gospels in 30 Days',
      description: 'Read through Matthew, Mark, Luke, and John in one month',
      type: PlanType.gospels,
      totalDays: 30,
      days: _generateGospelsDays(),
      createdAt: DateTime.now(),
    );
  }

  List<ReadingDay> _generateGospelsDays() {
    final days = <ReadingDay>[];

    // Matthew (28 chapters) - Days 1-10
    for (int i = 0; i < 10; i++) {
      final startCh = i * 3 + 1;
      final endCh = (i + 1) * 3;
      days.add(ReadingDay(
        dayNumber: i + 1,
        segments: [
          ReadingSegment(
            bookId: 'MAT',
            bookName: 'Matthew',
            startChapter: startCh,
            endChapter: endCh <= 28 ? endCh : 28,
          ),
        ],
      ));
    }

    // Mark (16 chapters) - Days 11-15
    for (int i = 0; i < 5; i++) {
      final startCh = i * 3 + 1;
      final endCh = (i + 1) * 3;
      days.add(ReadingDay(
        dayNumber: i + 11,
        segments: [
          ReadingSegment(
            bookId: 'MRK',
            bookName: 'Mark',
            startChapter: startCh,
            endChapter: endCh <= 16 ? endCh : 16,
          ),
        ],
      ));
    }

    // Luke (24 chapters) - Days 16-23
    for (int i = 0; i < 8; i++) {
      final startCh = i * 3 + 1;
      final endCh = (i + 1) * 3;
      days.add(ReadingDay(
        dayNumber: i + 16,
        segments: [
          ReadingSegment(
            bookId: 'LUK',
            bookName: 'Luke',
            startChapter: startCh,
            endChapter: endCh <= 24 ? endCh : 24,
          ),
        ],
      ));
    }

    // John (21 chapters) - Days 24-30
    for (int i = 0; i < 7; i++) {
      final startCh = i * 3 + 1;
      final endCh = (i + 1) * 3;
      days.add(ReadingDay(
        dayNumber: i + 24,
        segments: [
          ReadingSegment(
            bookId: 'JHN',
            bookName: 'John',
            startChapter: startCh,
            endChapter: endCh <= 21 ? endCh : 21,
          ),
        ],
      ));
    }

    return days;
  }

  ReadingPlan _createNewTestamentPlan() {
    return ReadingPlan(
      id: 'nt_${DateTime.now().millisecondsSinceEpoch}',
      name: 'New Testament in 90 Days',
      description: 'A journey through the entire New Testament',
      type: PlanType.newTestament,
      totalDays: 90,
      days: _generateSequentialDays(
        totalDays: 90,
        bookId: 'MAT',
        bookName: 'Matthew',
        maxChapter: 28,
      ),
      createdAt: DateTime.now(),
    );
  }

  ReadingPlan _createOldTestamentPlan() {
    return ReadingPlan(
      id: 'ot_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Old Testament Overview',
      description: 'Key passages from the Old Testament',
      type: PlanType.oldTestament,
      totalDays: 60,
      days: _generateSequentialDays(
        totalDays: 60,
        bookId: 'GEN',
        bookName: 'Genesis',
        maxChapter: 50,
      ),
      createdAt: DateTime.now(),
    );
  }

  ReadingPlan _createPsalmsPlan() {
    return ReadingPlan(
      id: 'psalms_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Psalms & Proverbs',
      description: 'Daily wisdom from Psalms and Proverbs',
      type: PlanType.psalmsAndProverbs,
      totalDays: 31,
      days: _generatePsalmsDays(),
      createdAt: DateTime.now(),
    );
  }

  List<ReadingDay> _generatePsalmsDays() {
    final days = <ReadingDay>[];

    // Psalms 1-150 spread over 30 days (5 psalms per day)
    for (int i = 0; i < 30; i++) {
      final startPsalm = i * 5 + 1;
      final endPsalm = (i + 1) * 5;
      days.add(ReadingDay(
        dayNumber: i + 1,
        segments: [
          ReadingSegment(
            bookId: 'PSA',
            bookName: 'Psalms',
            startChapter: startPsalm,
            endChapter: endPsalm <= 150 ? endPsalm : 150,
          ),
          ReadingSegment(
            bookId: 'PRO',
            bookName: 'Proverbs',
            startChapter: (i % 31) + 1,
          ),
        ],
      ));
    }

    // Day 31: Psalm 150 + Review
    days.add(ReadingDay(
      dayNumber: 31,
      segments: [
        ReadingSegment(
          bookId: 'PSA',
          bookName: 'Psalms',
          startChapter: 150,
        ),
        ReadingSegment(
          bookId: 'PRO',
          bookName: 'Proverbs',
          startChapter: 31,
        ),
      ],
    ));

    return days;
  }

  ReadingPlan _createWholeBiblePlan() {
    return ReadingPlan(
      id: 'bible_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Bible in a Year',
      description: 'Complete Bible reading plan for 365 days',
      type: PlanType.wholeBible,
      totalDays: 365,
      days: _generateWholeBibleDays(),
      createdAt: DateTime.now(),
    );
  }

  List<ReadingDay> _generateWholeBibleDays() {
    final days = <ReadingDay>[];
    final allBooks = BibleStructure.allBooks;
    
    // Create a list of all chapters in the Bible
    final allChapters = <ReadingSegment>[];
    for (final bookName in allBooks) {
      final bookId = AppConstants.bookAbbreviations[bookName.toLowerCase()] ?? bookName.toUpperCase();
      final chapterCount = BibleStructure.getChapterCount(bookName);
      for (int i = 1; i <= chapterCount; i++) {
        allChapters.add(ReadingSegment(
          bookId: bookId,
          bookName: bookName,
          startChapter: i,
        ));
      }
    }

    // Total chapters in the Bible is 1189.
    // 1189 / 365 is approx 3.25 chapters per day.
    int chapterIndex = 0;
    for (int day = 1; day <= 365; day++) {
      // Calculate how many chapters to read today to stay on track
      // (Total chapters read by end of day should be approx day * (1189/365))
      final targetTotal = (day * allChapters.length / 365).floor();
      final chaptersToday = <ReadingSegment>[];
      
      while (chapterIndex < targetTotal || (day == 365 && chapterIndex < allChapters.length)) {
        chaptersToday.add(allChapters[chapterIndex]);
        chapterIndex++;
      }
      
      // Ensure at least one chapter per day if we have chapters left
      if (chaptersToday.isEmpty && chapterIndex < allChapters.length) {
        chaptersToday.add(allChapters[chapterIndex]);
        chapterIndex++;
      }

      if (chaptersToday.isNotEmpty) {
        days.add(ReadingDay(
          dayNumber: day,
          segments: chaptersToday,
        ));
      }
    }

    return days;
  }

  ReadingPlan _createChronologicalPlan() {
    return ReadingPlan(
      id: 'chron_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Chronological Bible',
      description: 'Read the Bible in chronological order',
      type: PlanType.chronological,
      totalDays: 365, // Standardize to a year
      days: _generateWholeBibleDays(), // Reusing the logic for now, but in order
      createdAt: DateTime.now(),
    );
  }

  ReadingPlan _createThematicPlan() {
    return ReadingPlan(
      id: 'theme_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Thematic Study',
      description: 'Explore themes across Scripture',
      type: PlanType.thematic,
      totalDays: 45,
      days: _generateSequentialDays(
        totalDays: 45,
        bookId: 'PSA',
        bookName: 'Psalms',
        maxChapter: 150,
      ),
      createdAt: DateTime.now(),
    );
  }

  ReadingPlan _createCustomPlan() {
    return ReadingPlan(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'My Custom Plan',
      description: 'Your personalized reading plan',
      type: PlanType.custom,
      totalDays: 30,
      days: _generateSequentialDays(
        totalDays: 30,
        bookId: 'JHN',
        bookName: 'John',
        maxChapter: 21,
      ),
      createdAt: DateTime.now(),
    );
  }

  List<ReadingDay> _generateSequentialDays({
    required int totalDays,
    required String bookId,
    required String bookName,
    required int maxChapter,
  }) {
    return List.generate(totalDays, (index) {
      final chapter = (index % maxChapter) + 1;
      return ReadingDay(
        dayNumber: index + 1,
        segments: [
          ReadingSegment(
            bookId: bookId,
            bookName: bookName,
            startChapter: chapter,
          ),
        ],
      );
    });
  }
}
