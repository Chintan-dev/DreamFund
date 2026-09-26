import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'family_provider.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Dream Vault'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Family Vault Banner
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.family_restroom, color: AppColors.secondary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(family.familyName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text('${family.members.length} Members • Combined Vault', style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lightCardBorder),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Invite Code: ${family.inviteCode}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: family.inviteCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invite code copied to clipboard!')),
                                  );
                                },
                                child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Total Family Saved Funds', style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatINR(family.totalFamilySavings),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text('Family Members & Contributions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: family.members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = family.members[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: Text(
                        member.name[0],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(member.role),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatINR(member.totalContributed),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                        const Text('Contributed', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
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
