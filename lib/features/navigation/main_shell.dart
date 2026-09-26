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
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final userAsync = ref.watch(authProvider);
    final user = userAsync.value;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) ...[
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(context, index),
              extended: MediaQuery.of(context).size.width >= 1100,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    ),
                    if (MediaQuery.of(context).size.width >= 1100) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'DreamFund',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.ads_click_outlined),
                  selectedIcon: Icon(Icons.ads_click),
                  label: Text('Savings Dreams'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: Text('Budget & Cashflow'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.family_restroom_outlined),
                  selectedIcon: Icon(Icons.family_restroom),
                  label: Text('Family Vault'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: Text('XP & Badges'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: user == null
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt, color: AppColors.accentGold, size: 20),
                                    Text(
                                      'Lvl ${user.level}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${user.xp} XP',
                                  style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.lightCardBorder),
          ],
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(context, index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.ads_click_outlined),
                  activeIcon: Icon(Icons.ads_click),
                  label: 'Dreams',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.family_restroom_outlined),
                  activeIcon: Icon(Icons.family_restroom),
                  label: 'Family',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Badges',
                ),
              ],
            ),
    );
  }
}
