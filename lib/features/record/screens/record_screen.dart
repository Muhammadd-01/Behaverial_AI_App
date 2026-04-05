import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../report/screens/report_screen.dart';
import '../../subscription/screens/subscription_screen.dart';

/// Screen for recording voice, journaling, and mood selection
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen>
    with TickerProviderStateMixin {
  final _journalController = TextEditingController();
  MoodType? _selectedMood;
  bool _isRecording = false;
  String _recordedText = '';
  String? _attachedImageUrl;
  bool _isUploadingImage = false;
  int _selectedInputTab = 0; // 0=Journal, 1=Voice
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isFocusMode = false;
  String _currentVibe = 'Neutral';
  Color _vibeColor = Colors.grey;
  int _currentPromptIndex = 0;

  final List<String> _prompts = [
    'How are you feeling today? Write freely...',
    'What is one thing that made you smile today?',
    'Describe a challenge you faced and how you handled it.',
    'What are you most grateful for in this moment?',
    'If you could send a message to your future self, what would it be?',
  ];

  final List<double> _waveformValues = List.generate(30, (_) => 0.1);
  late AnimationController _waveformController;
  
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() {
        if (_isRecording) {
            setState(() {
              for (int i = 0; i < _waveformValues.length; i++) {
                _waveformValues[i] = 0.1 + (0.8 * (DateTime.now().millisecondsSinceEpoch % (1000 + i*100) / (1000 + i*100)));
              }
            });
        }
      });
    
    _journalController.addListener(_onTextChanged);
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => print('Speech Error: $error'),
        onStatus: (status) => print('Speech Status: $status'),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print('Speech recognition not available: $e');
      _speechEnabled = false;
      if (mounted) setState(() {});
    }
  }

  void _onTextChanged() {
    final text = _journalController.text.toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _currentVibe = 'Neutral';
        _vibeColor = Colors.grey;
      });
      return;
    }

    // Simple real-time sentiment "Vibe Check" simulation
    final positiveWords = ['happy', 'great', 'good', 'love', 'amazing', 'smile', 'grateful', 'peace'];
    final negativeWords = ['sad', 'bad', 'angry', 'hate', 'stressed', 'tired', 'worried', 'difficult'];
    
    int posCount = positiveWords.where((w) => text.contains(w)).length;
    int negCount = negativeWords.where((w) => text.contains(w)).length;

    setState(() {
      if (!_isFocusMode && _journalController.text.length > 5) _isFocusMode = true;
      if (posCount > negCount) {
        _currentVibe = 'Positive';
        _vibeColor = AppColors.primaryAccent;
      } else if (negCount > posCount) {
        _currentVibe = 'Difficult';
        _vibeColor = AppColors.negative;
      } else {
        _currentVibe = 'Reflective';
        _vibeColor = AppColors.secondaryAccent;
      }
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    _pulseController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    try {
      if (!_speechEnabled) {
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) return;
        _speechEnabled = await _speechToText.initialize();
        if (!_speechEnabled) return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not linked yet. Please perform a full rebuild.')),
      );
      return;
    }

    if (_isRecording) {
      await _speechToText.stop();
      _waveformController.stop();
      setState(() => _isRecording = false);
    } else {
      setState(() {
        _isRecording = true;
        _recordedText = '';
      });
      _waveformController.repeat();
      
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recordedText = result.recognizedWords;
          });
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 10),
      );
    }
  }

  Future<void> _analyzeInput() async {
    String inputText = '';
    String inputType = 'journal';

    if (_selectedInputTab == 0) {
      inputText = _journalController.text.trim();
      inputType = 'journal';
    } else {
      inputText = _recordedText;
      inputType = 'voice';
    }

    if (_selectedMood != null) {
      inputText += ' [Mood: ${_selectedMood!.label}]';
    }

    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some input first')),
      );
      return;
    }

    final user = ref.read(authStateProvider).user;
    final dashboard = ref.read(dashboardProvider);
    final currentEntries = dashboard.todayReport?.entriesCount ?? 0;
    final limit = user?.subscriptionTier.dailyLimit ?? 3;

    if (currentEntries >= limit) {
      _showPremiumPaywall();
      return;
    }

    await ref.read(analysisProvider.notifier).analyze(
      text: inputText,
      userId: user?.uid ?? 'demo',
      inputType: inputType,
      imageUrl: _attachedImageUrl,
    );

    if (mounted) {
      HapticFeedback.heavyImpact();
      final analysisState = ref.read(analysisProvider);
      if (analysisState.error != null && analysisState.error!.contains('limit')) {
        _showPremiumPaywall();
      } else if (analysisState.currentResult != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ReportScreen(),
          ),
        );
      }
    }
  }

  void _showPremiumPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.secondaryBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          gradient: AppColors.darkGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 40),
            const Text('🌱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'Daily Limit Reached',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'You\'ve completed your 3 reflections for today. Consistency is great! Upgrade to Bloom or Forest to continue growing without limits.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('View Growing Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Free', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isFocusMode) ...[
                  Text(
                    'Record Your Thoughts',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Express yourself through voice or text',
                    style: TextStyle(
                      fontSize: 15, 
                      color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPromptCarousel(isDarkMode),
                  const SizedBox(height: 24),
                ],
                if (_isFocusMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deep Reflection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isFocusMode = false),
                        child: const Text('Exit Focus'),
                      ),
                    ],
                  ).animate().fadeIn(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!_isFocusMode) Expanded(child: _buildInputToggle(isDarkMode)),
                    if (!_isFocusMode) const SizedBox(width: 12),
                    _buildGrowthIndicator(isDarkMode),
                  ],
                ),
                const SizedBox(height: 24),
                if (_selectedInputTab == 0)
                  _buildJournalInput(isDarkMode)
                else
                  _buildVoiceInput(isDarkMode),
                const SizedBox(height: 24),
                _buildMoodSelector(isDarkMode),
                const SizedBox(height: 32),
                // Analyze button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: analysisState.isAnalyzing ? null : _analyzeInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: analysisState.isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Analyzing...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology_rounded, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Analyze My Input',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildGrowthIndicator(bool isDarkMode) {
    final user = ref.watch(authStateProvider).user;
    final dashboard = ref.watch(dashboardProvider);
    final count = dashboard.todayReport?.entriesCount ?? 0;
    final limit = user?.subscriptionTier.dailyLimit ?? 3;
    final color = count >= limit ? AppColors.negative : AppColors.primaryAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_graph_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            'Daily Growth: $count/$limit',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInputToggle(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : AppColors.cardBgLightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
      ),
      child: Row(
        children: [
          _toggleTab('📝 Journal', 0, isDarkMode),
          _toggleTab('🎙️ Voice', 1, isDarkMode),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, int index, bool isDarkMode) {
    final isSelected = _selectedInputTab == index;
    final user = ref.read(authStateProvider).user;
    final isVoiceLocked = index == 1 && user?.subscriptionTier == SubscriptionTier.seedling;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isVoiceLocked) {
             _showPremiumPaywall();
          } else {
            setState(() => _selectedInputTab = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : (isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark),
                ),
              ),
              if (isVoiceLocked) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock_rounded, size: 12, color: AppColors.secondaryAccent),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalInput(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
        boxShadow: isDarkMode ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              TextField(
                controller: _journalController,
                maxLines: _isFocusMode ? 15 : 8,
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  fontSize: 15,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: _prompts[_currentPromptIndex],
                  hintStyle: TextStyle(
                    color: (isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark).withValues(alpha: 0.6)
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              if (_journalController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _vibeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _vibeColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14, color: _vibeColor),
                            const SizedBox(width: 4),
                            Text(
                              'Vibe: $_currentVibe',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _vibeColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_journalController.text.split(' ').where((w) => w.isNotEmpty).length} words',
                        style: TextStyle(fontSize: 11, color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
      if (_attachedImageUrl != null || _isUploadingImage)
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryAccent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _isUploadingImage 
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : Image.network(_attachedImageUrl!, fit: BoxFit.cover),
                ),
              ),
              if (!_isUploadingImage)
                GestureDetector(
                  onTap: () => setState(() => _attachedImageUrl = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.negative,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryAccent),
              onPressed: _isUploadingImage ? null : _pickJournalImage,
            ),
            if (!_isUploadingImage && _attachedImageUrl == null)
              Text(
                'Add Photo',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _pickJournalImage() async {
  setState(() => _isUploadingImage = true);
  try {
    final url = await ref.read(authStateProvider.notifier).uploadJournalImage(ImageSource.gallery);
    setState(() {
      _attachedImageUrl = url;
      _isUploadingImage = false;
    });
  } catch (e) {
    setState(() => _isUploadingImage = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }
}

  Widget _buildVoiceInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
        boxShadow: isDarkMode ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              _recordedText.isEmpty 
                  ? (_isRecording ? 'Listening...' : 'Record your thoughts') 
                  : _recordedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Waveform centered
          if (_isRecording)
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _waveformValues.map((h) => 
                  Container(
                    width: 3,
                    height: 40 * h,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                ).toList(),
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 32),
          // Recording button centered with pulse animation
          Center(
            child: GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80 * (_isRecording ? _pulseAnimation.value : 1.0),
                    height: 80 * (_isRecording ? _pulseAnimation.value : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isRecording
                          ? const LinearGradient(
                              colors: [AppColors.negative, Color(0xFFDC2626)],
                            )
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppColors.negative
                                  : AppColors.primaryAccent)
                              .withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: _isRecording ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isRecording ? 'TAP TO STOP' : 'TAP TO RECORD',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: _isRecording ? AppColors.negative : (isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select your current mood (optional)',
          style: TextStyle(
            fontSize: 13, 
            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: MoodType.values.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedMood = isSelected ? null : mood;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryAccent.withValues(alpha: 0.15)
                      : (isDarkMode ? AppColors.glassWhite : Colors.white),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : (isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isDarkMode ? null : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primaryAccent
                            : (isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPromptCarousel(bool isDarkMode) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentPromptIndex = (_currentPromptIndex + 1) % _prompts.length;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.secondaryAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Prompt: Tap to change guidelines',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryAccent,
                ),
              ),
            ),
            const Icon(Icons.refresh_rounded, color: AppColors.secondaryAccent, size: 18),
          ],
        ),
      ),
    );
  }
}
