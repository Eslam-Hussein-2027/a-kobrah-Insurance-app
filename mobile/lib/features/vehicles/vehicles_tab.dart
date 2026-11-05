import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'vehicle.dart';
import 'vehicle_header.dart';
import 'vehicles_repository.dart';

class VehiclesTab extends ConsumerWidget {
  const VehiclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabVehicles)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
      ),
      body: AsyncView(
        value: ref.watch(vehiclesProvider),
        onRetry: () => ref.invalidate(vehiclesProvider),
        builder: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyView(
              icon: Icons.directions_car_outlined,
              title: l10n.noVehicles,
              subtitle: l10n.noVehiclesHint,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(vehiclesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _VehicleCard(vehicle: vehicles[index]),
            ),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  const _VehicleCard({required this.vehicle});

  final Vehicle vehicle;

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  child: const Icon(Icons.directions_car_filled, color: AppColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(child: VehicleHeader(vehicle: vehicle)),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      context.push('/vehicles/${vehicle.id}/edit', extra: vehicle);
                    } else {
                      _delete(context, ref);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.edit)),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                        title: Text(l10n.delete, style: const TextStyle(color: AppColors.danger)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: FilledButton.tonalIcon(
                onPressed: () => context.push('/insure/${vehicle.id}'),
                icon: const Icon(Icons.shield_outlined),
                label: Text(l10n.insureVehicle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
