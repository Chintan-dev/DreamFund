import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/auth_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(String location) {
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/budget')) return 2;
    if (location.startsWith('/family')) return 3;
    if (location.startsWith('/achievements')) return 4;
    return 0; // Dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/goals');
        break;
      case 2:
        context.go('/budget');
        break;
      case 3:
        context.go('/family');
        break;
      case 4:
        context.go('/achievements');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final userAsync = ref.watch(authProvider);
    final user = userAsync.value;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) ...[
            // Dashtrans Next.js 16 Shadcn UI Sidebar Navigation (260px)
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: AppColors.darkSurface,
                border: Border(
                  right: BorderSide(color: AppColors.darkCardBorder, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'DreamFund',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Financial OS v2.0',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColors.darkCardBorder),
                  const SizedBox(height: 16),

                  // Menu Sections
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        _buildSectionHeader('FINANCIAL VAULT'),
                        _buildNavItem(
                          context,
                          index: 0,
                          label: 'Overview Dashboard',
                          icon: Icons.grid_view_rounded,
                          isSelected: selectedIndex == 0,
                        ),
                        _buildNavItem(
                          context,
                          index: 1,
                          label: 'Savings Dreams',
                          icon: Icons.track_changes_rounded,
                          isSelected: selectedIndex == 1,
                          badge: '3 Active',
                        ),
                        _buildNavItem(
                          context,
                          index: 2,
                          label: 'Budget & Cashflow',
                          icon: Icons.account_balance_wallet_rounded,
                          isSelected: selectedIndex == 2,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader('COMMUNITY & REWARDS'),
                        _buildNavItem(
                          context,
                          index: 3,
                          label: 'Family Vault',
                          icon: Icons.groups_rounded,
                          isSelected: selectedIndex == 3,
                        ),
                        _buildNavItem(
                          context,
                          index: 4,
                          label: 'XP & Badges',
                          icon: Icons.emoji_events_rounded,
                          isSelected: selectedIndex == 4,
                          badge: 'Lvl ${user?.level ?? 1}',
                          badgeColor: AppColors.accentGold,
                        ),
                      ],
                    ),
                  ),

                  // Bottom Sidebar User Status Widget
                  if (user != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withAlpha(40),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0] : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.darkBackground, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  '${user.xp} XP • ${user.currentStreakDays}d Streak 🔥',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Main Content Area with Top Header Bar
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.darkSurface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.darkCardBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search Bar (Shadcn style with keyboard shortcut Ctrl+K tag)
                      if (isDesktop)
                        Expanded(
                          child: Container(
                            height: 38,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.darkCardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Search dreams, budgets, transactions...',
                                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.darkCardBorder),
                                  ),
                                  child: const Text(
                                    '⌘K',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),

                      // Quick Action "+ New Goal"
                      ElevatedButton.icon(
                        onPressed: () => context.go('/goals/create'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('+ New Goal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Notification Bell
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkCardBorder),
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textPrimary),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Profile Avatar
                      if (!isDesktop && user != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withAlpha(40),
                          child: Text(
                            user.name[0],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(context, index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              backgroundColor: AppColors.darkSurface,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes_rounded),
                  label: 'Dreams',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups_rounded),
                  label: 'Family',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_rounded),
                  label: 'Badges',
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    String? badge,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: AppColors.primary.withAlpha(60)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.primary).withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
