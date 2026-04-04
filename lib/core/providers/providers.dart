import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/dummy_data_service.dart';

// ── Auth State ──

/// Tracks if the user is logged in (simplified, no real Firebase for now)
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final UserModel? user;
  final bool isLoading;

  const AuthState({
    this.isLoggedIn = false,
    this.user,
    this.isLoading = false,
  });

  AuthState copyWith({bool? isLoggedIn, UserModel? user, bool? isLoading}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Simulate login with email/password
  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      streak: 7,
      level: 3,
      totalPoints: 1250,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActiveAt: DateTime.now(),
    );

    state = AuthState(isLoggedIn: true, user: user, isLoading: false);
  }

  /// Simulate Google Sign In
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      displayName: 'Positive User',
      streak: 12,
      level: 4,
      totalPoints: 2100,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastActiveAt: DateTime.now(),
    );

    state = AuthState(isLoggedIn: true, user: user, isLoading: false);
  }

  /// Sign up
  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    state = AuthState(isLoggedIn: true, user: user, isLoading: false);
  }

  void logout() {
    state = const AuthState();
  }

  /// Update user profile (simulated)
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (state.user == null) return;
    
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedUser = state.user!.copyWith(
      displayName: name ?? state.user!.displayName,
      photoUrl: photoUrl ?? state.user!.photoUrl,
    );
    
    state = state.copyWith(user: updatedUser, isLoading: false);
  }
}

// ── Dashboard State ──

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final DailyReport? todayReport;
  final List<InsightData> weeklyInsights;
  final List<AnalysisResult> recentAnalyses;
  final Map<String, dynamic> streakInfo;
  final bool isLoading;

  const DashboardState({
    this.todayReport,
    this.weeklyInsights = const [],
    this.recentAnalyses = const [],
    this.streakInfo = const {},
    this.isLoading = true,
  });
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  /// Load all dashboard data
  Future<void> loadDashboard(String userId) async {
    state = const DashboardState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));

    state = DashboardState(
      todayReport: DummyDataService.getTodayReport(userId),
      weeklyInsights: DummyDataService.getWeeklyInsights(),
      recentAnalyses: DummyDataService.getRecentAnalyses(userId),
      streakInfo: DummyDataService.getStreakInfo(),
      isLoading: false,
    );
  }

  /// Refresh data
  Future<void> refresh(String userId) async => loadDashboard(userId);
}

// ── Analysis State ──

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier();
});

class AnalysisState {
  final AnalysisResult? currentResult;
  final List<FeedbackItem> feedback;
  final bool isAnalyzing;
  final String? error;

  const AnalysisState({
    this.currentResult,
    this.feedback = const [],
    this.isAnalyzing = false,
    this.error,
  });
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier() : super(const AnalysisState());

  /// Analyze user text input
  Future<void> analyze({
    required String text,
    required String userId,
    required String inputType,
  }) async {
    state = const AnalysisState(isAnalyzing: true);

    try {
      final result = await ApiService.analyzeText(
        text: text,
        userId: userId,
        inputType: inputType,
      );

      final feedback = await ApiService.getFeedback(
        sentiment: result.sentiment,
        tone: result.tone,
        score: result.positivityScore,
      );

      state = AnalysisState(
        currentResult: result,
        feedback: feedback,
        isAnalyzing: false,
      );
    } catch (e) {
      state = AnalysisState(isAnalyzing: false, error: e.toString());
    }
  }

  void clear() => state = const AnalysisState();
}

// ── Settings State ──

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool trackingEnabled;
  final bool notificationsEnabled;
  final bool islamicContentEnabled;
  final bool isPremium;

  const SettingsState({
    this.trackingEnabled = true,
    this.notificationsEnabled = true,
    this.islamicContentEnabled = true,
    this.isPremium = false,
  });

  SettingsState copyWith({
    bool? trackingEnabled,
    bool? notificationsEnabled,
    bool? islamicContentEnabled,
    bool? isPremium,
  }) => SettingsState(
    trackingEnabled: trackingEnabled ?? this.trackingEnabled,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    islamicContentEnabled: islamicContentEnabled ?? this.islamicContentEnabled,
    isPremium: isPremium ?? this.isPremium,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleTracking() => state = state.copyWith(trackingEnabled: !state.trackingEnabled);
  void toggleNotifications() => state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  void toggleIslamicContent() => state = state.copyWith(islamicContentEnabled: !state.islamicContentEnabled);
  void upgradeToPremium() => state = state.copyWith(isPremium: true);
}

// ── Onboarding State ──

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _loadOnboardingStatus();
  }

  static const String _key = 'onboarding_complete';

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }

  /// Reset for testing if needed
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = false;
  }
}

// ── Navigation State ──
final currentTabProvider = StateProvider<int>((ref) => 0);

// ── Chat State ──
final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([
    ChatMessage(
      text: "Hello! I'm your AI Positivity Coach. 🌟\n\nHow are you feeling today? Share your thoughts and I'll help you cultivate a more positive mindset.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [...state, ChatMessage(text: text, isUser: true, timestamp: DateTime.now())];

    // Get AI response
    final response = await ApiService.chatWithCoach(text);
    state = [...state, ChatMessage(text: response, isUser: false, timestamp: DateTime.now())];
  }
}
