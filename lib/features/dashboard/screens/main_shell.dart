import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../record/screens/record_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// Main app shell with bottom navigation bar
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _screens = const [
    DashboardScreen(),
    InsightsScreen(),
    RecordScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);

    // Reactive data loading: Whenever the user signs in, trigger dashboard load.
    ref.listen(authStateProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        ref.read(dashboardProvider.notifier).loadDashboard(next.user!.uid);
      }
    });

    // Handle persistent login case: if user is already here, ensure data starts loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authStateProvider);
      final dash = ref.read(dashboardProvider);
      if (auth.user != null && dash.isLoading && dash.todayReport == null) {
        ref.read(dashboardProvider.notifier).loadDashboard(auth.user!.uid);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBg,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: currentTab == 0,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 0,
                ),
                _NavItem(
                  icon: Icons.insights_rounded,
                  label: 'Insights',
                  isSelected: currentTab == 1,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                ),
                // Center Record button (special FAB-like)
                _RecordNavItem(
                  isSelected: currentTab == 2,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentTab == 3,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard nav item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Special center Record button with gradient
class _RecordNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _RecordNavItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
