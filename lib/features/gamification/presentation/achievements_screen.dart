import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import 'gamification_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final user = userAsync.value;
    final achievements = ref.watch(achievementsProvider);

    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final currentLevelXp = xp % 200;
    final levelProgress = (currentLevelXp / 200).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('XP, Levels & Achievements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level & XP Banner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, color: AppColors.accentGold, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Level $level Dreamer', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text('Total XP Earned: $xp XP', style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔥 ${user?.currentStreakDays ?? 1} Day Streak',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearPercentIndicator(
                      lineHeight: 12.0,
                      percent: levelProgress,
                      backgroundColor: AppColors.lightCardBorder,
                      progressColor: AppColors.accentGold,
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$currentLevelXp / 200 XP to Level ${level + 1}', style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                        Text('${((1 - levelProgress) * 200).toInt()} XP remaining', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text('Milestone Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 130,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return Card(
                  color: ach.isUnlocked ? Theme.of(context).cardTheme.color : AppColors.lightBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          ach.icon,
                          style: TextStyle(
                            fontSize: 32,
                            color: ach.isUnlocked ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ach.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: ach.isUnlocked ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ach.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withAlpha(30),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${ach.xpReward} XP',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ach.isUnlocked ? 'Unlocked' : 'Locked',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: ach.isUnlocked ? AppColors.success : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
