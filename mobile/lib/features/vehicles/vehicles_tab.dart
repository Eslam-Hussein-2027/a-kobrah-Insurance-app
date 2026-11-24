import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'vehicle.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';
import 'vehicles_repository.dart';

class VehiclesTab extends ConsumerWidget {
  const VehiclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final policies = ref.watch(policiesProvider).asData?.value ?? const <Policy>[];

    /// Latest pending/active compulsory policy per vehicle.
    final coverage = <int, Policy>{
      for (final policy in policies.reversed)
        if (!policy.isTravel && policy.isBlocking && policy.vehicle != null) policy.vehicle!.id: policy,
    };

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(policiesProvider)
            ..invalidate(vehiclesProvider);
          await ref.read(vehiclesProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.tabVehicles, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), foregroundColor: AppColors.navy),
                  onPressed: () => context.push('/vehicles/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AsyncView(
              value: ref.watch(vehiclesProvider),
              onRetry: () => ref.invalidate(vehiclesProvider),
              builder: (vehicles) => vehicles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: EmptyView(
                        icon: Icons.directions_car_outlined,
                        title: l10n.noVehicles,
                        subtitle: l10n.noVehiclesHint,
                      ),
                    )
                  : Column(
                      children: [
                        for (final vehicle in vehicles) ...[
                          const SizedBox(height: 12),
                          _VehicleCard(vehicle: vehicle, policy: coverage[vehicle.id]),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  const _VehicleCard({required this.vehicle, this.policy});

  final Vehicle vehicle;

  /// Pending or active compulsory policy, if any.
  final Policy? policy;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.deleteVehicleTitle,
      message: l10n.deleteVehicleConfirm(vehicle.plateNo),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(vehiclesRepositoryProvider).delete(vehicle.id);
      ref.invalidate(vehiclesProvider);
      if (context.mounted) showMessage(context, l10n.vehicleDeleted);
    } on ApiException catch (e) {
      if (context.mounted) showMessage(context, errorMessage(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final policy = this.policy;
    final (status, color) = switch (policy?.status) {
      PolicyStatus.active => (l10n.insuredUntil(formatDate(context, policy!.endDate)), AppColors.success),
      PolicyStatus.pendingPayment => (l10n.awaitingPayment, AppColors.warning),
      _ => (l10n.notInsured, AppColors.warning),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.title} ${vehicle.year}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${vehicle.engineCc} ${l10n.ccUnit}',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.only(top: 4), child: PlateBadge(vehicle.plateNo)),
                PopupMenuButton<String>(
                  tooltip: l10n.more,
                  onSelected: (action) {
                    if (action == 'edit') {
                      context.push('/vehicles/${vehicle.id}/edit', extra: vehicle);
                    } else {
                      _delete(context, ref);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.delete, style: const TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: Row(
                children: [
                  CircleAvatar(radius: 3.5, backgroundColor: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                    ),
                  ),
                  policy == null
                      ? FilledButton(
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
                          onPressed: () => context.push('/motor/issue?vehicle=${vehicle.id}'),
                          child: Text(l10n.insureItNow),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                          onPressed: () => context.push('/policies/${policy.id}'),
                          child: Text(l10n.viewPolicy),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
