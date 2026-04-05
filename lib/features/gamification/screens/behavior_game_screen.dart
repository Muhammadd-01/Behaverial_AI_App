import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';

class BehaviorGameScreen extends ConsumerStatefulWidget {
  const BehaviorGameScreen({super.key});

  @override
  ConsumerState<BehaviorGameScreen> createState() => _BehaviorGameScreenState();
}

class _BehaviorGameScreenState extends ConsumerState<BehaviorGameScreen> {
  int _currentScenarioIndex = 0;
  bool _hasResponded = false;
  int? _selectedChoiceIndex;

  final List<Map<String, dynamic>> _scenarios = [
    {
      'title': 'The Rainy Morning',
      'description': 'You wake up feeling tired, and it\'s pouring rain outside. You have a long to-do list.',
      'choices': [
        {'text': 'Complain about the weather and stay in bed.', 'points': 5, 'feedback': 'Avoidance can feel good short-term, but it stunts growth.'},
        {'text': 'Make a warm tea and tackle the smallest task first.', 'points': 25, 'feedback': 'Excellent! Small wins build momentum.'},
        {'text': 'Tell yourself the day is already ruined.', 'points': 0, 'feedback': 'Catastrophizing makes challenges feel bigger than they are.'},
      ],
    },
    {
      'title': 'A Difficult Email',
      'description': 'You receive some critical feedback on a project you worked hard on.',
      'choices': [
        {'text': 'Delete the email and ignore it.', 'points': 5, 'feedback': 'Ignoring feedback prevents you from improving.'},
        {'text': 'Reply defensively and explain why they are wrong.', 'points': 10, 'feedback': 'Defensiveness blocks the path to mastery.'},
        {'text': 'Take a breath and look for one constructive point.', 'points': 30, 'feedback': 'Growth Mindset! Critique is just data for your next win.'},
      ],
    },
    {
      'title': 'The Missed Opportunity',
      'description': 'You forgot to call a friend on their birthday.',
      'choices': [
        {'text': 'Wait for them to call you first.', 'points': 5, 'feedback': 'Pride is the enemy of connection.'},
        {'text': 'Call now, apologize, and wish them well.', 'points': 25, 'feedback': 'Authenticity heals! Taking responsibility is a high-level behavior.'},
        {'text': 'Send a quick text and hope they aren\'t mad.', 'points': 15, 'feedback': 'It\'s a start, but a direct call shows more care.'},
      ],
    },
  ];

  void _handleChoice(int index) {
    if (_hasResponded) return;

    setState(() {
      _hasResponded = true;
      _selectedChoiceIndex = index;
    });

    final points = _scenarios[_currentScenarioIndex]['choices'][index]['points'] as int;
    if (points > 0) {
      ref.read(authStateProvider.notifier).addPoints(points);
    }
  }

  Future<void> _nextScenario() async {
    if (_currentScenarioIndex < _scenarios.length - 1) {
      setState(() {
        _currentScenarioIndex++;
        _hasResponded = false;
        _selectedChoiceIndex = null;
      });
    } else {
      // Grant points for successful completion
      await ref.read(authStateProvider.notifier).addPoints(50);
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily Mindset Challenge Complete! +EXP Earned'),
          backgroundColor: AppColors.primaryAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final scenario = _scenarios[_currentScenarioIndex];

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Daily Challenge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                children: List.generate(_scenarios.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentScenarioIndex 
                            ? AppColors.primaryAccent 
                            : (isDarkMode ? Colors.white10 : Colors.black12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              
              // Scenario Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.cardBg : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
                  boxShadow: isDarkMode ? null : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _scenarios[_currentScenarioIndex]['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _scenarios[_currentScenarioIndex]['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 32),
              
              // Choices
              ...List.generate(scenario['choices'].length, (index) {
                final choice = scenario['choices'][index];
                final isSelected = _selectedChoiceIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _handleChoice(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _hasResponded 
                            ? (isSelected 
                                ? AppColors.primaryAccent.withValues(alpha: 0.1) 
                                : (isDarkMode ? AppColors.cardBg : Colors.grey[100]))
                            : (isDarkMode ? AppColors.cardBg : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasResponded && isSelected 
                              ? AppColors.primaryAccent 
                              : (isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        choice['text'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (200 * index).ms).slideX();
              }),

              const SizedBox(height: 16),
              const Spacer(),

              // Feedback Section
              if (_hasResponded) 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        scenario['choices'][_selectedChoiceIndex!]['feedback'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _nextScenario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_currentScenarioIndex < _scenarios.length - 1 ? 'Next Scenario' : 'Finish Challenge'),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}
