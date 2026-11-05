import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'models.dart';
import 'policies_repository.dart';
import 'status_chip.dart';

class PoliciesTab extends ConsumerWidget {
  const PoliciesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabPolicies)),
      body: AsyncView(
        value: ref.watch(policiesProvider),
        onRetry: () => ref.invalidate(policiesProvider),
        builder: (policies) {
          if (policies.isEmpty) {
            return EmptyView(icon: Icons.description_outlined, title: l10n.noPolicies, subtitle: l10n.noPoliciesHint);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(policiesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: policies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _PolicyCard(policy: policies[index]),
            ),
          );
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/policies/${policy.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    // Align (not textAlign) keeps the LTR number on the start side in RTL layouts.
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        policy.policyNo,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                  PolicyStatusChip(status: policy.status, label: policy.statusLabel),
                ],
              ),
              const SizedBox(height: 8),
              if (policy.vehicle != null)
                Text(
                  '${policy.vehicle!.plateNo} • ${policy.vehicle!.title}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              if (policy.coverageType != null)
                Text(policy.coverageType!.name, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              const Divider(height: 20),
              InfoRow(label: l10n.endDate, value: policy.endDate, ltr: true),
              InfoRow(label: l10n.premium, value: formatMoney(context, policy.premium)),
            ],
          ),
        ),
      ),
    );
  }
}
