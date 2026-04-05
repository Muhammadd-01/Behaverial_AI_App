import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Account Security',
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSecurityHeader(isDarkMode),
            const SizedBox(height: 32),
            _buildSecurityItem(
              title: 'Change Password',
              subtitle: 'Last changed 3 months ago',
              icon: Icons.lock_outline_rounded,
              isDarkMode: isDarkMode,
              onTap: () {},
            ),
            _buildSecurityItem(
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              icon: Icons.verified_user_outlined,
              isDarkMode: isDarkMode,
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeColor: AppColors.primaryAccent,
              ),
              onTap: () {},
            ),
            _buildSecurityItem(
              title: 'Biometric Login',
              subtitle: 'Use Fingerprint or Face ID',
              icon: Icons.fingerprint_rounded,
              isDarkMode: isDarkMode,
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primaryAccent,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Text(
              'Active Sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSessionItem(
              device: 'iPhone 15 Pro (Current)',
              location: 'London, UK',
              isDarkMode: isDarkMode,
            ),
            _buildSessionItem(
              device: 'MacBook Pro 16"',
              location: 'London, UK',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Log out from all other devices',
                style: TextStyle(color: AppColors.negative, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.primaryAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Your account is secure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We protect your data with end-to-end encryption',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkMode,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.glassWhite.withValues(alpha: 0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryAccent, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
          ),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, 
          color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark),
      ),
    );
  }

  Widget _buildSessionItem({
    required String device,
    required String location,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.glassWhite.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? AppColors.glassBorder : AppColors.glassBorderDark),
      ),
      child: Row(
        children: [
          Icon(Icons.devices_rounded, 
            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, size: 20),
        ],
      ),
    );
  }
}
