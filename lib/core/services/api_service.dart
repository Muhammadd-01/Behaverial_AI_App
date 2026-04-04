import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Service for communicating with the FastAPI AI backend
class ApiService {
  // Change this to your deployed FastAPI URL
  static const String _baseUrl = 'http://localhost:8000';
  
  /// Analyze text input and return sentiment analysis results
  static Future<AnalysisResult> analyzeText({
    required String text,
    required String userId,
    required String inputType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'user_id': userId,
          'input_type': inputType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalysisResult.fromMap(data);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: simulate analysis locally for demo/offline mode
      return _simulateAnalysis(text, userId, inputType);
    }
  }

  /// Get smart feedback based on analysis
  static Future<List<FeedbackItem>> getFeedback({
    required String sentiment,
    required String tone,
    required int score,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sentiment': sentiment,
          'tone': tone,
          'score': score,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => FeedbackItem(
          type: item['type'],
          title: item['title'],
          description: item['description'],
          quranVerse: item['quran_verse'],
          hadith: item['hadith'],
          icon: item['icon'] ?? '💡',
        )).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _simulateFeedback(sentiment, score);
    }
  }

  /// AI chatbot coach endpoint
  static Future<String> chatWithCoach(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _simulateChatResponse(message);
    }
  }

  // ── Local Simulation (Offline / Demo Mode) ──

  /// Simulate NLP analysis locally using simple heuristics
  static AnalysisResult _simulateAnalysis(
    String text,
    String userId,
    String inputType,
  ) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword-based sentiment
    final positiveWords = [
      'happy', 'great', 'good', 'love', 'wonderful', 'amazing', 'blessed',
      'grateful', 'excited', 'joy', 'peace', 'thank', 'beautiful', 'hope',
      'positive', 'awesome', 'fantastic', 'excellent', 'smile', 'kind',
      'alhamdulillah', 'mashallah', 'inshallah', 'succeed', 'strong',
    ];
    final negativeWords = [
      'sad', 'bad', 'angry', 'hate', 'terrible', 'awful', 'stressed',
      'anxious', 'depressed', 'worried', 'fear', 'pain', 'sick', 'tired',
      'frustrated', 'upset', 'annoyed', 'lonely', 'worst', 'cry',
    ];

    int positiveCount = 0;
    int negativeCount = 0;
    List<String> keywords = [];

    for (final word in positiveWords) {
      if (lowerText.contains(word)) {
        positiveCount++;
        keywords.add(word);
      }
    }
    for (final word in negativeWords) {
      if (lowerText.contains(word)) {
        negativeCount++;
        keywords.add(word);
      }
    }

    // Calculate score (0-100)
    int score;
    String sentiment;
    String tone;

    if (positiveCount > negativeCount) {
      score = 60 + (positiveCount * 8).clamp(0, 40);
      sentiment = 'positive';
      tone = positiveCount > 3 ? 'joy' : 'calm';
    } else if (negativeCount > positiveCount) {
      score = 40 - (negativeCount * 8).clamp(0, 35);
      sentiment = 'negative';
      tone = negativeCount > 3 ? 'stress' : 'sadness';
    } else {
      score = 50;
      sentiment = 'neutral';
      tone = 'calm';
    }

    score = score.clamp(5, 98);

    return AnalysisResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      inputText: text,
      inputType: inputType,
      positivityScore: score,
      sentiment: sentiment,
      tone: tone,
      keywords: keywords.take(5).toList(),
      analyzedAt: DateTime.now(),
    );
  }

  /// Simulate feedback locally
  static List<FeedbackItem> _simulateFeedback(String sentiment, int score) {
    if (sentiment == 'negative' || score < 40) {
      return const [
        FeedbackItem(
          type: 'breathing',
          title: 'Deep Breathing Exercise',
          description: 'Take 5 deep breaths. Inhale for 4 seconds, hold for 7, exhale for 8.',
          icon: '🧘',
        ),
        FeedbackItem(
          type: 'reflection',
          title: 'Gratitude Reflection',
          description: 'Write down 3 things you are grateful for today.',
          icon: '📝',
        ),
        FeedbackItem(
          type: 'islamic',
          title: 'Quranic Comfort',
          description: 'Remember Allah\'s words of comfort and hope.',
          quranVerse: '"Verily, with hardship, there is relief." — Quran 94:6',
          hadith: '"No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that." — Bukhari',
          icon: '🕌',
        ),
      ];
    } else {
      return const [
        FeedbackItem(
          type: 'habit',
          title: 'Keep It Up!',
          description: 'Your positivity is shining! Share your positive energy with someone today.',
          icon: '⭐',
        ),
        FeedbackItem(
          type: 'habit',
          title: 'Gratitude Boost',
          description: 'You\'re doing great! Consider journaling what made today special.',
          icon: '🌟',
        ),
        FeedbackItem(
          type: 'islamic',
          title: 'Islamic Wisdom',
          description: 'Continue in gratitude and remembrance.',
          quranVerse: '"If you are grateful, I will surely increase your favor." — Quran 14:7',
          icon: '🕌',
        ),
      ];
    }
  }

  /// Simulate AI chatbot response
  static String _simulateChatResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('stressed') || lower.contains('anxious')) {
      return "I understand you're feeling stressed. Remember, it's okay to take a step back. "
          "Try this: Close your eyes, take 5 deep breaths, and focus only on the present moment. "
          "You've overcome challenges before, and you'll overcome this too. 💪";
    } else if (lower.contains('sad') || lower.contains('down')) {
      return "I'm sorry you're feeling this way. Your feelings are valid. "
          "Sometimes writing down what's bothering you can help process emotions. "
          "Remember: 'After hardship comes ease.' You're stronger than you think. 🌱";
    } else if (lower.contains('happy') || lower.contains('good')) {
      return "That's wonderful to hear! 🌟 Positive moments deserve to be celebrated. "
          "Consider sharing your joy with someone close to you — positivity is contagious! "
          "Keep building on these good feelings.";
    } else {
      return "Thank you for sharing! Every conversation is a step toward self-awareness. "
          "I'm here to help you build a more positive mindset. "
          "Would you like to try a quick reflection exercise or talk about your day? 😊";
    }
  }

  // ── Supabase Image Upload (via FastAPI) ──

  /// Upload an image to Supabase Storage via FastAPI and get back the public URL.
  /// The URL is then stored in Firestore (e.g., user.photoUrl or analysis.imageUrl).
  ///
  /// [imageBytes] - raw bytes of the image file
  /// [fileName] - original filename (e.g., 'photo.jpg')
  /// [userId] - Firebase Auth UID (used as folder name in Supabase)
  /// [bucket] - 'profile-images' or 'journal-attachments'
  static Future<String?> uploadImage({
    required List<int> imageBytes,
    required String fileName,
    required String userId,
    String bucket = 'journal-attachments',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-image'),
      );

      request.fields['user_id'] = userId;
      request.fields['bucket'] = bucket;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String; // Public Supabase URL
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return null on failure — caller should handle gracefully
      return null;
    }
  }

  /// Delete an image from Supabase Storage via FastAPI.
  static Future<bool> deleteImage({
    required String bucket,
    required String path,
    required String userId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'DELETE',
        Uri.parse('$_baseUrl/delete-image'),
      );

      request.fields['bucket'] = bucket;
      request.fields['path'] = path;
      request.fields['user_id'] = userId;

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

