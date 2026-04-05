import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';
import 'settings_screen.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { insight, achievement, reminder, security }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Positivity Milestone! 🌟',
      message: 'You\'ve maintained a 75%+ positivity score for 3 days straight. Levels are rising!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.achievement,
    ),
    NotificationModel(
      id: '2',
      title: 'New AI Insight Ready 🧠',
      message: 'Your morning journals show a trend of high gratitude. Tap to see your deep analysis.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.insight,
    ),
    NotificationModel(
      id: '3',
      title: 'Time for Reflection 🖊️',
      message: 'Don\'t forget to record your evening thoughts to keep your streak alive.',
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
      type: NotificationType.reminder,
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Security Alert 🔐',
      message: 'Your account was accessed from a new device in London, UK.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.security,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, 
            color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_mockNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _mockNotifications.clear());
              },
              child: const Text('Clear All', style: TextStyle(color: AppColors.primaryAccent)),
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined, 
              color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: _mockNotifications.isEmpty
            ? _buildEmptyState(isDarkMode)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _mockNotifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(_mockNotifications[index], isDarkMode, index);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isDarkMode, int index) {
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.insight:
        icon = Icons.psychology_rounded;
        iconColor = AppColors.primaryAccent;
        break;
      case NotificationType.achievement:
        icon = Icons.emoji_events_rounded;
        iconColor = AppColors.secondaryAccent;
        break;
      case NotificationType.reminder:
        icon = Icons.notifications_active_rounded;
        iconColor = AppColors.highlight;
        break;
      case NotificationType.security:
        icon = Icons.security_rounded;
        iconColor = AppColors.negative;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.isRead 
              ? (isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark)
              : AppColors.primaryAccent.withValues(alpha: 0.5),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: isDarkMode ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                notification.message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
                ),
              ),
            ),
          ),
          if (!notification.isRead)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, 
            size: 80, color: isDarkMode ? Colors.white10 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when you have new behavioral insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
