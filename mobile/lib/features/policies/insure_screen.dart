import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../home/home_screen.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicle_header.dart';
import '../vehicles/vehicles_repository.dart';
import 'models.dart';
import 'policies_repository.dart';

/// Quote preview + policy issuance for one vehicle.
class InsureScreen extends ConsumerStatefulWidget {
  const InsureScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  ConsumerState<InsureScreen> createState() => _InsureScreenState();
}

class _InsureScreenState extends ConsumerState<InsureScreen> {
  int? _coverageTypeId;
  DateTime _startDate = DateUtils.dateOnly(DateTime.now());
  bool _issuing = false;

  Future<void> _pickStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _issue(int coverageTypeId) async {
    final l10n = context.l10n;
    final user = ref.read(authControllerProvider).asData?.value;

    if (user != null && !user.kycCompleted) {
      await _showKycDialog();
      return;
    }

    setState(() => _issuing = true);
    try {
      final today = DateUtils.dateOnly(DateTime.now());
      final policy = await ref
          .read(policiesRepositoryProvider)
          .create(
            vehicleId: widget.vehicleId,
            coverageTypeId: coverageTypeId,
            startDate: _startDate.isAfter(today) ? _startDate : null,
          );
      ref.invalidate(policiesProvider);
      ref.read(homeTabProvider.notifier).select(HomeTab.policies);
      if (!mounted) return;
      showMessage(context, l10n.policyCreated);
      context.go('/policies/${policy.id}');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  Future<void> _showKycDialog() async {
    final l10n = context.l10n;
    final goToProfile = await confirmDialog(
      context,
      title: l10n.kycMissingTitle,
      message: l10n.kycMissingBody,
      confirmLabel: l10n.goToProfile,
    );
    if (goToProfile && mounted) {
      ref.read(homeTabProvider.notifier).select(HomeTab.profile);
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicles = ref.watch(vehiclesProvider);
    final coverageTypes = ref.watch(coverageTypesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insureVehicle)),
      body: AsyncView(
        value: vehicles,
        onRetry: () => ref.invalidate(vehiclesProvider),
        builder: (list) {
          final vehicle = list.where((v) => v.id == widget.vehicleId).firstOrNull;
          if (vehicle == null) {
            return ErrorView(message: l10n.vehicleNotFound);
          }
          return AsyncView(
            value: coverageTypes,
            onRetry: () => ref.invalidate(coverageTypesProvider),
            builder: (types) {
              final selectedId = _coverageTypeId ?? (types.isNotEmpty ? types.first.id : null);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _VehicleSummary(vehicle: vehicle),
                  const SizedBox(height: 12),
                  if (types.length > 1)
                    ...types.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CoverageOption(
                          type: type,
                          selected: type.id == selectedId,
                          onTap: () => setState(() => _coverageTypeId = type.id),
                        ),
                      ),
                    )
                  else if (types.isNotEmpty)
                    _CoverageOption(type: types.first, selected: true, onTap: null),
                  const SizedBox(height: 12),
                  if (selectedId != null) ...[
                    _QuoteCard(vehicleId: vehicle.id, coverageTypeId: selectedId),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_outlined, color: AppColors.blue),
                        title: Text(l10n.coverageStart),
                        subtitle: Text(
                          _isoDate(_startDate),
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                        ),

                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: _pickStartDate,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: l10n.issuePolicy,
                      icon: Icons.shield_outlined,
                      loading: _issuing,
                      onPressed: () => _issue(selectedId),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String _isoDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.directions_car_filled, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(child: VehicleHeader(vehicle: vehicle)),
          ],
        ),
      ),
    );
  }
}

class _CoverageOption extends StatelessWidget {
  const _CoverageOption({required this.type, required this.selected, required this.onTap});

  final CoverageType type;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppColors.blue : AppColors.border, width: selected ? 1.6 : 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.blue),
        title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: type.description != null ? Text(type.description!) : null,
      ),
    );
  }
}

class _QuoteCard extends ConsumerWidget {
  const _QuoteCard({required this.vehicleId, required this.coverageTypeId});

  final int vehicleId;
  final int coverageTypeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final args = (vehicleId: vehicleId, coverageTypeId: coverageTypeId);

    return SectionCard(
      title: l10n.quoteTitle,
      child: AsyncView(
        value: ref.watch(quoteProvider(args)),
        onRetry: () => ref.invalidate(quoteProvider(args)),
        builder: (quote) => Column(
          children: [
            InfoRow(label: l10n.basePrice, value: formatMoney(context, quote.basePrice)),
            for (final factor in quote.factors)
              InfoRow(label: '${factor.label} (${factor.input})', value: '× ${factor.multiplier}', ltr: true),
            const Divider(height: 20),
            InfoRow(label: l10n.totalPremium, value: formatMoney(context, quote.premium), emphasize: true),
          ],
        ),
      ),
    );
  }
}
