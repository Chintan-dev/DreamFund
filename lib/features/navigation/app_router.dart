import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/presentation/dashboard_screen.dart';
import '../goals/presentation/goal_list_screen.dart';
import '../goals/presentation/goal_detail_screen.dart';
import '../goals/presentation/create_goal_screen.dart';
import '../budget/presentation/budget_screen.dart';
import '../family/presentation/family_screen.dart';
import '../gamification/presentation/achievements_screen.dart';
import '../auth/presentation/login_screen.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalListScreen(),
        ),
        GoRoute(
          path: '/goals/create',
          builder: (context, state) => const CreateGoalScreen(),
        ),
        GoRoute(
          path: '/goals/:id',
          builder: (context, state) {
            final goalId = state.pathParameters['id'] ?? '';
            return GoalDetailScreen(goalId: goalId);
          },
        ),
        GoRoute(
          path: '/budget',
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: '/family',
          builder: (context, state) => const FamilyScreen(),
        ),
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
      ],
    ),
  ],
);
