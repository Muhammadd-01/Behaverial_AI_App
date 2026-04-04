import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../auth/screens/auth_screen.dart';
import '../widgets/chatbot_sheet.dart';
import 'edit_profile_screen.dart';

/// Settings screen with privacy controls, premium, and profile management
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Card
                _buildProfileCard(context, user),

                const SizedBox(height: 24),

                // Profile Settings Section
                _buildSection('Profile Settings', [
                  _settingsAction(
                    'Edit Profile',
                    'Update name and profile photo',
                    Icons.person_outline_rounded,
                    AppColors.primaryAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _settingsAction(
                    'Account Security',
                    'Password and authentication',
                    Icons.security_rounded,
                    AppColors.secondaryAccent,
                    () => _showSnackBar(context, 'Security settings coming soon'),
                  ),
                ]),

                const SizedBox(height: 20),

                // AI Coach Card
                _buildCoachCard(context),

                const SizedBox(height: 20),

                // Premium Card
                if (!settings.isPremium) _buildPremiumCard(ref),
                if (!settings.isPremium) const SizedBox(height: 20),

                // Privacy & Permissions
                _buildSection('Privacy & Permissions', [
                  _settingsToggle(
                    'Behavior Tracking',
                    'Allow app to analyze your inputs',
                    Icons.track_changes_rounded,
                    settings.trackingEnabled,
                    () => ref.read(settingsProvider.notifier).toggleTracking(),
                  ),
                  _settingsToggle(
                    'Notifications',
                    'Daily reminders and insights',
                    Icons.notifications_none_rounded,
                    settings.notificationsEnabled,
                    () => ref.read(settingsProvider.notifier).toggleNotifications(),
                  ),
                  _settingsToggle(
                    'Islamic Content',
                    'Show Quran verses and Hadith',
                    Icons.auto_stories_rounded,
                    settings.islamicContentEnabled,
                    () => ref.read(settingsProvider.notifier).toggleIslamicContent(),
                  ),
                ]),

                const SizedBox(height: 20),

                // Data Management
                _buildSection('Data Management', [
                  _settingsAction(
                    'Export My Data',
                    'Download all your data',
                    Icons.download_rounded,
                    AppColors.secondaryAccent,
                    () => _showSnackBar(context, 'Data export started...'),
                  ),
                  _settingsAction(
                    'Delete All Data',
                    'Permanently remove all your data',
                    Icons.delete_forever_rounded,
                    AppColors.negative,
                    () => _showDeleteConfirm(context),
                  ),
                ]),

                const SizedBox(height: 20),

                // Display Settings
                _buildSection('Display', [
                  _settingsAction(
                    'App Theme',
                    'Dark (Default)',
                    Icons.dark_mode_rounded,
                    AppColors.primaryAccent,
                    () => _showSnackBar(context, 'Theme selection coming soon'),
                  ),
                  _settingsAction(
                    'Language',
                    'English',
                    Icons.language_rounded,
                    AppColors.secondaryAccent,
                    () => _showSnackBar(context, 'Language support coming soon'),
                  ),
                ]),

                const SizedBox(height: 20),

                // About
                _buildSection('About', [
                  _settingsAction(
                    'Privacy Policy',
                    'How we handle your data',
                    Icons.policy_rounded,
                    AppColors.textSecondary,
                    () {},
                  ),
                  _settingsAction(
                    'Terms of Service',
                    'App usage terms',
                    Icons.description_rounded,
                    AppColors.textSecondary,
                    () {},
                  ),
                  _settingsAction(
                    'App Version',
                    'v1.0.0 (Build 1)',
                    Icons.info_outline_rounded,
                    AppColors.textSecondary,
                    () {},
                  ),
                ]),

                const SizedBox(height: 20),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.negative),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.negative, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.negative,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryAccent, width: 2),
              image: user?.photoUrl.isNotEmpty == true
                  ? DecorationImage(
                      image: NetworkImage(user!.photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.photoUrl.isEmpty == true
                ? Center(
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.edit_note_rounded,
                color: AppColors.primaryAccent, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ChatbotSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryAccent.withValues(alpha: 0.15),
              AppColors.glassWhite,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Positivity Coach',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chat with your personal AI coach',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.highlight.withValues(alpha: 0.15),
            AppColors.glassWhite,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.highlight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Unlock advanced analytics & AI coaching',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Benefits
          _premiumBenefit('Unlimited daily insights'),
          _premiumBenefit('Advanced analytics & trends'),
          _premiumBenefit('AI personal coaching'),
          _premiumBenefit('Priority support'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => ref.read(settingsProvider.notifier).upgradeToPremium(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.highlight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Upgrade — \$4.99/month',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.highlight, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _settingsToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.3),
            activeThumbColor: AppColors.primaryAccent,
            inactiveTrackColor: AppColors.cardBgLight,
          ),
        ],
      ),
    );
  }

  Widget _settingsAction(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete All Data?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete all your data including analyses, reports, and progress. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar(context, 'All data has been deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.negative,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
