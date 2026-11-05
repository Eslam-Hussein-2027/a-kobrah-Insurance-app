import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'models.dart';
import 'pdf_saver.dart';
import 'policies_repository.dart';
import 'status_chip.dart';

class PolicyDetailsScreen extends ConsumerWidget {
  const PolicyDetailsScreen({super.key, required this.policyId});

  final int policyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.policyDetails)),
      body: AsyncView(
        value: ref.watch(policyProvider(policyId)),
        onRetry: () => ref.invalidate(policyProvider(policyId)),
        builder: (policy) => RefreshIndicator(
          onRefresh: () async => ref.refresh(policyProvider(policyId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(policy: policy),
              const SizedBox(height: 12),
              _Details(policy: policy),
              const SizedBox(height: 16),
              if (policy.status == PolicyStatus.pendingPayment) _PendingPayment(policy: policy),
              if (policy.canDownloadPdf) _DownloadButton(policy: policy),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
      ),
      child: Column(
        children: [
          Text(context.l10n.policyNo, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            policy.policyNo,
            textDirection: TextDirection.ltr,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: PolicyStatusChip(status: policy.status, label: policy.statusLabel),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = policy.vehicle;
    return SectionCard(
      child: Column(
        children: [
          if (policy.coverageType != null) InfoRow(label: l10n.coverage, value: policy.coverageType!.name),
          if (vehicle != null) ...[
            InfoRow(label: l10n.plateNo, value: vehicle.plateNo, ltr: true),
            InfoRow(label: l10n.vehicle, value: '${vehicle.title} ${vehicle.year}'),
          ],
          InfoRow(label: l10n.startDate, value: policy.startDate, ltr: true),
          InfoRow(label: l10n.endDate, value: policy.endDate, ltr: true),
          if (policy.issuedAt != null)
            InfoRow(label: l10n.issuedAt, value: policy.issuedAt!.substring(0, 10), ltr: true),
          const Divider(height: 20),
          InfoRow(label: l10n.premium, value: formatMoney(context, policy.premium), emphasize: true),
        ],
      ),
    );
  }
}

class _PendingPayment extends ConsumerStatefulWidget {
  const _PendingPayment({required this.policy});

  final Policy policy;

  @override
  ConsumerState<_PendingPayment> createState() => _PendingPaymentState();
}

class _PendingPaymentState extends ConsumerState<_PendingPayment> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.cancelRequest,
      message: l10n.cancelRequestConfirm,
      confirmLabel: l10n.cancelRequest,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(policiesRepositoryProvider).cancel(widget.policy.id);
      ref
        ..invalidate(policyProvider(widget.policy.id))
        ..invalidate(policiesProvider);
      if (mounted) showMessage(context, l10n.policyCancelled);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    l10n.pendingPaymentTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.pendingPaymentBody, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${l10n.customerService}: ', style: theme.textTheme.bodyMedium),
                  Text(
                    AppConfig.customerServicePhone,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _cancelling ? null : _cancel,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
          icon: const Icon(Icons.close),
          label: Text(l10n.cancelRequest),
        ),
      ],
    );
  }
}

class _DownloadButton extends ConsumerStatefulWidget {
  const _DownloadButton({required this.policy});

  final Policy policy;

  @override
  ConsumerState<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<_DownloadButton> {
  bool _loading = false;

  Future<void> _download() async {
    if (!canSavePdf) {
      showMessage(context, context.l10n.pdfMobileOnly);
      return;
    }

    setState(() => _loading = true);
    try {
      final bytes = await ref.read(policiesRepositoryProvider).pdf(widget.policy.id);
      await saveAndOpenPdf(bytes, '${widget.policy.policyNo}.pdf');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: context.l10n.downloadPdf,
      icon: Icons.picture_as_pdf_outlined,
      loading: _loading,
      onPressed: _download,
    );
  }
}
