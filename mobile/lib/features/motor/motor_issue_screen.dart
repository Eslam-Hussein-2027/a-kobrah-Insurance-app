import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicles_repository.dart';

/// Compulsory insurance, step 1: which vehicle and from when.
class MotorIssueScreen extends ConsumerStatefulWidget {
  const MotorIssueScreen({super.key, this.vehicleId});

  /// Pre-selected vehicle (from "Insure it now").
  final int? vehicleId;

  @override
  ConsumerState<MotorIssueScreen> createState() => _MotorIssueScreenState();
}

class _MotorIssueScreenState extends ConsumerState<MotorIssueScreen> {
  late int? _vehicleId = widget.vehicleId;
  DateTime _startDate = DateUtils.dateOnly(DateTime.now());

  Future<void> _pickStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: AppConfig.maxPolicyStartDaysAhead)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicles = ref.watch(vehiclesProvider);
    final policies = ref.watch(policiesProvider).asData?.value ?? const <Policy>[];
    final user = ref.watch(authControllerProvider).asData?.value;

    /// Vehicles that already have a pending or active compulsory policy.
    final blocking = {
      for (final policy in policies)
        if (!policy.isTravel && policy.isBlocking && policy.vehicle != null) policy.vehicle!.id: policy,
    };
    final available = (vehicles.asData?.value ?? const <Vehicle>[]).where((v) => !blocking.containsKey(v.id));
    final selectedId = _vehicleId ?? available.firstOrNull?.id;
    final selected = vehicles.asData?.value.where((v) => v.id == selectedId).firstOrNull;
    final needsDetails = selected != null && !selected.detailsComplete;
    final canContinue = selectedId != null && !blocking.containsKey(selectedId) && !needsDetails;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.motorIssueTitle)),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(
          label: l10n.continueLabel,
          onPressed: canContinue ? () => context.push('/motor/review/$selectedId?start=${isoDate(_startDate)}') : null,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StepHeader(step: 1, total: 3, label: l10n.motorStepVehicle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                NoticeBanner(icon: Icons.info_outline, title: l10n.notice, message: l10n.checkDataNotice),
                SectionTitle(l10n.chooseVehicle),
                AsyncView(
                  value: vehicles,
                  onRetry: () => ref.invalidate(vehiclesProvider),
                  builder: (list) => Column(
                    children: [
                      for (final vehicle in list) ...[
                        _VehicleOption(
                          vehicle: vehicle,
                          blockingPolicy: blocking[vehicle.id],
                          selected: vehicle.id == selectedId,
                          onTap: () => setState(() => _vehicleId = vehicle.id),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                if (needsDetails) ...[
                  NoticeBanner(
                    icon: Icons.edit_note,
                    title: l10n.vehicleDetailsMissing,
                    message: l10n.vehicleDetailsMissingHint,
                    action: FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
                      onPressed: () => context.push('/vehicles/${selected.id}/edit', extra: selected),
                      child: Text(l10n.completeDetails),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.navy),
                  onPressed: () => context.push('/vehicles/new'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNewVehicle),
                ),
                SectionTitle(l10n.policyData),
                FieldBox(
                  label: l10n.coverageStart,
                  value: formatDate(context, isoDate(_startDate)),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 8),
                FieldBox(label: l10n.policyDuration, value: l10n.oneYear),
                const SizedBox(height: 8),
                FieldBox(label: l10n.insuredPerson, value: selected?.ownerName ?? user?.name ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  const _VehicleOption({required this.vehicle, required this.selected, required this.onTap, this.blockingPolicy});

  final Vehicle vehicle;
  final Policy? blockingPolicy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final policy = blockingPolicy;
    final status = policy == null
        ? null
        : policy.status == PolicyStatus.active
        ? l10n.insuredUntil(formatDate(context, policy.endDate))
        : l10n.hasPendingPolicy;

    return OptionTile(
      title: '${vehicle.title} ${vehicle.year}',
      subtitle: '${vehicle.plateNo} · ${vehicle.engineCc} ${l10n.ccUnit}',
      selected: selected && policy == null,
      enabled: policy == null,
      onTap: onTap,
      footer: status == null
          ? null
          : Text(
              status,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
    );
  }
}
