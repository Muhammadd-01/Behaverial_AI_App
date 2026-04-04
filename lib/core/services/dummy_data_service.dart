import 'dart:math';
import '../models/models.dart';

/// Provides dummy/simulated data for testing and demo purposes
class DummyDataService {
  static final _random = Random();

  /// Generate a week's worth of insight data for charts
  static List<InsightData> getWeeklyInsights() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final sentiments = ['positive', 'neutral', 'negative'];
      return InsightData(
        date: date,
        score: 40 + _random.nextInt(55),
        sentiment: sentiments[_random.nextInt(3)],
      );
    });
  }

  /// Generate monthly insight data
  static List<InsightData> getMonthlyInsights() {
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final sentiments = ['positive', 'neutral', 'negative'];
      return InsightData(
        date: date,
        score: 30 + _random.nextInt(65),
        sentiment: sentiments[_random.nextInt(3)],
      );
    });
  }

  /// Generate a mock daily report
  static DailyReport getTodayReport(String userId) {
    final score = 55 + _random.nextInt(40);
    return DailyReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      date: DateTime.now(),
      averageScore: score,
      dominantSentiment: score > 65 ? 'positive' : (score > 40 ? 'neutral' : 'negative'),
      dominantTone: score > 65 ? 'calm' : (score > 40 ? 'motivation' : 'stress'),
      entriesCount: 1 + _random.nextInt(5),
      suggestions: _getSuggestions(score),
    );
  }

  /// Generate mock analysis history
  static List<AnalysisResult> getRecentAnalyses(String userId) {
    final entries = [
      {'text': 'Had a wonderful morning walk today. Feeling grateful!', 'type': 'journal'},
      {'text': 'Work was stressful but I managed to stay calm.', 'type': 'voice'},
      {'text': 'Spent time with family. Feeling blessed and happy.', 'type': 'journal'},
      {'text': 'Feeling a bit anxious about tomorrow\'s meeting.', 'type': 'voice'},
      {'text': 'Completed my goals for today. Feeling accomplished!', 'type': 'journal'},
    ];

    return List.generate(entries.length, (i) {
      final score = 30 + _random.nextInt(65);
      final sentiments = ['positive', 'neutral', 'negative'];
      final tones = ['calm', 'motivation', 'joy', 'stress', 'sadness'];
      return AnalysisResult(
        id: 'analysis_$i',
        userId: userId,
        inputText: entries[i]['text']!,
        inputType: entries[i]['type']!,
        positivityScore: score,
        sentiment: sentiments[_random.nextInt(3)],
        tone: tones[_random.nextInt(5)],
        keywords: ['grateful', 'calm', 'happy', 'blessed'].take(2 + _random.nextInt(3)).toList(),
        analyzedAt: DateTime.now().subtract(Duration(hours: i * 4)),
      );
    });
  }

  static List<String> _getSuggestions(int score) {
    if (score > 70) {
      return [
        'Your positivity is radiating! Keep journaling daily.',
        'Share your positive energy with someone today.',
        'Consider setting a new personal growth goal.',
      ];
    } else if (score > 45) {
      return [
        'You\'re doing well. Try a gratitude exercise this evening.',
        'Take 5 minutes for mindful breathing.',
        'Reflect on one thing that went well today.',
      ];
    } else {
      return [
        'Take a moment to pause and breathe deeply.',
        'Write down 3 things you\'re grateful for.',
        'Remember: every storm passes. Better days are ahead.',
      ];
    }
  }

  /// Get streak info
  static Map<String, dynamic> getStreakInfo() => {
    'currentStreak': 5 + _random.nextInt(10),
    'longestStreak': 15 + _random.nextInt(30),
    'totalEntries': 50 + _random.nextInt(200),
    'level': 3 + _random.nextInt(5),
    'points': 500 + _random.nextInt(2000),
    'nextLevelPoints': 1000,
  };
}
