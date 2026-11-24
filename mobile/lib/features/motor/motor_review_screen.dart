import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicles_repository.dart';

/// Compulsory insurance, step 2: policy data and the price breakdown.
/// Issuing creates a policy awaiting payment; step 3 (payment) is on the policy screen.
class MotorReviewScreen extends ConsumerStatefulWidget {
  const MotorReviewScreen({super.key, required this.vehicleId, required this.startDate});

  final int vehicleId;
  final DateTime startDate;

  @override
  ConsumerState<MotorReviewScreen> createState() => _MotorReviewScreenState();
}

class _MotorReviewScreenState extends ConsumerState<MotorReviewScreen> {
  bool _issuing = false;

  /// Annual policy, same rule as the API: start + 12 months (no overflow past month end) - 1 day.
  DateTime get _endDate {
    final start = widget.startDate;
    final day = start.day.clamp(1, DateUtils.getDaysInMonth(start.year + 1, start.month));
    return DateTime(start.year + 1, start.month, day).subtract(const Duration(days: 1));
  }

  Future<void> _issue(int coverageTypeId) async {
    final l10n = context.l10n;
    final user = ref.read(authControllerProvider).asData?.value;

    if (user != null && !user.kycCompleted) {
      final upload = await confirmDialog(
        context,
        title: l10n.kycMissingTitle,
        message: l10n.kycMissingBody,
        confirmLabel: l10n.goToProfile,
      );
      if (upload && mounted) await context.push('/more/profile');
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
            startDate: widget.startDate.isAfter(today) ? widget.startDate : null,
          );
      ref.invalidate(policiesProvider);
      if (!mounted) return;
      showMessage(context, l10n.policyCreated);
      context.go('/policies/${policy.id}');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehiclesProvider).asData?.value.where((v) => v.id == widget.vehicleId).firstOrNull;
    final coverage = ref.watch(coverageTypesProvider).asData?.value.where((c) => c.isMandatory).firstOrNull;
    final quote = coverage == null
        ? null
        : ref.watch(quoteProvider((vehicleId: widget.vehicleId, coverageTypeId: coverage.id)));
    final premium = quote?.asData?.value.premium;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.motorIssueTitle)),
      bottomNavigationBar: BottomActionBar(
        caption: l10n.total,
        amount: premium == null ? '—' : formatMoney(context, premium),
        button: PrimaryButton(
          label: l10n.issuePolicy,
          loading: _issuing,
          onPressed: premium == null || coverage == null ? null : () => _issue(coverage.id),
        ),
      ),
      body: vehicle == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                StepHeader(step: 2, total: 3, label: l10n.stepReview),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(l10n.policyData),
                      _PolicyData(vehicle: vehicle, start: widget.startDate, end: _endDate),
                      SectionTitle(l10n.priceDetails),
                      if (quote == null)
                        const Center(child: CircularProgressIndicator())
                      else
                        AsyncView(
                          value: quote,
                          onRetry: () => ref.invalidate(quoteProvider),
                          builder: (q) => _PriceBreakdown(quote: q),
                        ),
                      const SizedBox(height: 12),
                      Text(l10n.payAfterIssueHint, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PolicyData extends ConsumerWidget {
  const _PolicyData({required this.vehicle, required this.start, required this.end});

  final Vehicle vehicle;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).asData?.value;
    return SectionCard(
      child: Column(
        children: [
          InfoRow(label: l10n.vehicle, value: '${vehicle.title} ${vehicle.year}'),
          InfoRow(label: l10n.plateNo, value: vehicle.plateNo, ltr: true),
          InfoRow(label: l10n.engineCc, value: '${vehicle.engineCc} ${l10n.ccUnit}'),
          if (user != null) InfoRow(label: l10n.insuredPerson, value: user.name),
          InfoRow(label: l10n.startDate, value: formatDate(context, isoDate(start))),
          InfoRow(label: l10n.endDate, value: formatDate(context, isoDate(end))),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCard(
      child: Column(
        children: [
          InfoRow(label: l10n.basePrice, value: formatMoney(context, quote.basePrice)),
          for (final factor in quote.factors)
            InfoRow(label: '${factor.label} (${factor.input})', value: '× ${factor.multiplier}', ltr: true),
          const Divider(height: 20),
          InfoRow(label: l10n.total, value: formatMoney(context, quote.premium), emphasize: true),
        ],
      ),
    );
  }
}
