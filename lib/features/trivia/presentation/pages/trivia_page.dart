import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/utils/logger.dart';

class TriviaQuestion {
  final String id;
  final String category;
  final String question;
  final String answer;
  final String difficulty;

  TriviaQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.difficulty,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      id: json['id'],
      category: json['category'],
      question: json['question'],
      answer: json['answer'],
      difficulty: json['difficulty'],
    );
  }
}

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  List<TriviaQuestion> allQuestions = [];
  List<TriviaQuestion> currentQuestions = [];
  bool isLoading = true;
  
  // Quiz state
  int currentIndex = 0;
  int score = 0;
  bool showAnswer = false;
  bool quizStarted = false;
  int? selectedAnswer;
  
  // Categories
  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  int questionCount = 10;
  
  List<String> get categories {
    final cats = allQuestions.map((q) => q.category).toSet().toList().cast<String>()..sort();
    return ['All', ...cats];
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/bible_facts.json');
      final jsonData = json.decode(jsonString);
      final List<dynamic> categoriesData = jsonData['categories'];
      
      List<TriviaQuestion> questions = [];
      for (var cat in categoriesData) {
        final catName = cat['category'];
        final List<dynamic> facts = cat['facts'];
        for (var fact in facts) {
          questions.add(TriviaQuestion.fromJson({
            ...fact,
            'category': catName,
          }));
        }
      }
      
      setState(() {
        allQuestions = questions;
        isLoading = false;
      });
    } catch (e) {
      logDebug('Failed to load trivia questions: $e');
      setState(() => isLoading = false);
    }
  }

  void _startQuiz() {
    // Filter questions
    var filtered = allQuestions.where((q) {
      final catMatch = selectedCategory == 'All' || q.category == selectedCategory;
      final diffMatch = selectedDifficulty == 'All' || q.difficulty == selectedDifficulty;
      return catMatch && diffMatch;
    }).toList();
    
    // Shuffle and take questionCount
    filtered.shuffle(Random());
    currentQuestions = filtered.take(questionCount).toList();
    
    setState(() {
      quizStarted = true;
      currentIndex = 0;
      score = 0;
      showAnswer = false;
    });
  }

  void _checkAnswer(bool gotItRight) {
    if (gotItRight) score++;
    
    setState(() {
      showAnswer = true;
    });
  }

  void _nextQuestion() {
    if (currentIndex < currentQuestions.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
        selectedAnswer = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              '$score / ${currentQuestions.length}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${(score / currentQuestions.length * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 24, color: _getScoreColor()),
            ),
            const SizedBox(height: 16),
            Text(_getScoreMessage()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                quizStarted = false;
                currentQuestions = [];
              });
            },
            child: const Text('Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (currentQuestions.isEmpty) return Colors.grey;
    final pct = score / currentQuestions.length;
    if (pct >= 0.8) return Colors.green;
    if (pct >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage() {
    if (currentQuestions.isEmpty) return '';
    final pct = score / currentQuestions.length;
    if (pct >= 0.9) return '🏆 Bible Scholar!';
    if (pct >= 0.7) return '👍 Great Job!';
    if (pct >= 0.5) return '📚 Keep Studying!';
    return '🙏 Read Your Bible!';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bible Trivia')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!quizStarted) {
      return _buildMenuScreen();
    }

    if (currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bible Trivia')),
        body: const Center(child: Text('No questions match your criteria')),
      );
    }

    final question = currentQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Trivia'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${currentIndex + 1} / ${currentQuestions.length}'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / currentQuestions.length,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),
            
            // Category tag
            Chip(
              label: Text(question.category),
              backgroundColor: _getDifficultyColor(question.difficulty).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            
            // Question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Answer section
            if (showAnswer) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Answer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.answer,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: Text(currentIndex < currentQuestions.length - 1 ? 'Next Question' : 'See Results'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              // Answer buttons
              ElevatedButton(
                onPressed: () => _checkAnswer(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('I Know This!', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _checkAnswer(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Show Answer', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Trivia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats card
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.quiz, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      '${allQuestions.length} Questions',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Test your Bible knowledge!',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings
            Text('Quiz Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              initialValue: selectedCategory,
              items: categories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            
            // Difficulty
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              initialValue: selectedDifficulty,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Levels')),
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (v) => setState(() => selectedDifficulty = v!),
            ),
            const SizedBox(height: 16),
            
            // Question count
            Text('Number of Questions: $questionCount'),
            Slider(
              value: questionCount.toDouble(),
              min: 5,
              max: allQuestions.length.toDouble().clamp(5, 40),
              divisions: 7,
              label: questionCount.toString(),
              onChanged: (v) => setState(() => questionCount = v.round()),
            ),
            const SizedBox(height: 24),
            
            // Start button
            ElevatedButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.play_arrow),
              label: const Text('START QUIZ', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 16),
            
            // Browse all questions
            OutlinedButton.icon(
              onPressed: () => _showAllQuestions(context),
              icon: const Icon(Icons.list),
              label: const Text('Browse All Questions'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllQuestions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('All Questions', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${allQuestions.length} questions available', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: allQuestions.length,
                  itemBuilder: (context, index) {
                    final q = allQuestions[index];
                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getDifficultyColor(q.difficulty),
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                      title: Text(q.question, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${q.category} • ${q.difficulty}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(q.answer, style: const TextStyle(fontSize: 15)),
                        ),
                      ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.blue;
    }
  }
}
