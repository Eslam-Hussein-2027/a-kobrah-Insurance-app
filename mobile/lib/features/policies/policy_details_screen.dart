import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_exception.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'models.dart';
import 'pdf_saver.dart';
import 'policies_repository.dart';
import 'policy_tile.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _Header(policy: policy),
              const SizedBox(height: 16),
              if (policy.verificationUrl != null) ...[
                _VerificationQr(url: policy.verificationUrl!),
                const SizedBox(height: 16),
              ],
              if (policy.status == PolicyStatus.pendingPayment) ...[
                _PendingPayment(policy: policy),
                const SizedBox(height: 4),
              ],
              SectionTitle(context.l10n.policyData, padding: const EdgeInsets.fromLTRB(0, 8, 0, 10)),
              _Details(policy: policy),
              if (policy.travel != null) ...[
                SectionTitle(context.l10n.travellers),
                _Travellers(travel: policy.travel!),
              ],
              if (policy.canDownloadPdf) ...[const SizedBox(height: 16), _DownloadButton(policy: policy)],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(policy.productName, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ),
            PolicyStatusChip(status: policy.status, label: policy.statusLabel),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          policySubject(context, policy),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.35),
        ),
        Text(
          policy.policyNo,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontSize: 14, color: AppColors.muted, letterSpacing: 0.3),
        ),
      ],
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
    final travel = policy.travel;
    return SectionCard(
      child: Column(
        children: [
          InfoRow(label: l10n.coverage, value: policy.coverageType?.name ?? policy.title),
          if (vehicle != null) ...[
            InfoRow(label: l10n.vehicle, value: '${vehicle.title} ${vehicle.year}'),
            InfoRow(label: l10n.plateNo, value: vehicle.plateNo, ltr: true),
          ],
          if (travel != null) ...[
            InfoRow(label: l10n.destination, value: travel.zoneLabel),
            InfoRow(label: l10n.tripLength, value: l10n.daysCount(travel.days)),
          ],
          InfoRow(label: l10n.startDate, value: formatDate(context, policy.startDate)),
          InfoRow(label: l10n.endDate, value: formatDate(context, policy.endDate)),
          if (policy.issuedAt != null) InfoRow(label: l10n.issuedAt, value: formatDate(context, policy.issuedAt!)),
          const Divider(height: 20),
          InfoRow(label: l10n.premium, value: formatMoney(context, policy.premium), emphasize: true),
        ],
      ),
    );
  }
}

class _Travellers extends StatelessWidget {
  const _Travellers({required this.travel});

  final TravelDetails travel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListGroup(
      children: [
        for (final traveller in travel.travellers)
          NavRow(
            icon: Icons.person_outline,
            title: traveller.fullName,
            subtitle:
                '${l10n.bornOn(formatDate(context, traveller.birthDate))} · ${l10n.passportShort(traveller.passportNo)}',
          ),
      ],
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
  bool _paying = false;
  bool _checking = false;

  /// Online attempt started from this screen; checked again when the customer returns to the app.
  int? _paymentId;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (_paymentId != null) _checkPayment(silent: true);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _payOnline() async {
    final l10n = context.l10n;
    setState(() => _paying = true);
    try {
      final payment = await ref.read(policiesRepositoryProvider).payOnline(widget.policy.id);
      setState(() => _paymentId = payment.id);
      final opened = await launchUrl(Uri.parse(payment.checkoutUrl!), mode: LaunchMode.inAppBrowserView);
      if (!opened && mounted) showMessage(context, l10n.unexpectedError, isError: true);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  /// Asks the server (which asks the payment provider) for the result.
  Future<void> _checkPayment({bool silent = false}) async {
    final paymentId = _paymentId;
    if (paymentId == null || _checking) return;

    final l10n = context.l10n;
    setState(() => _checking = true);
    try {
      final payment = await ref.read(policiesRepositoryProvider).payment(paymentId);
      if (!mounted) return;

      if (payment.isPaid) {
        showMessage(context, l10n.paymentSucceeded);
        ref
          ..invalidate(policyProvider(widget.policy.id))
          ..invalidate(policiesProvider);
      } else if (payment.isFailed) {
        setState(() => _paymentId = null);
        showMessage(context, l10n.paymentFailed, isError: true);
      } else if (!silent) {
        showMessage(context, l10n.paymentNotConfirmedYet);
      }
    } on ApiException catch (e) {
      if (mounted && !silent) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.cancelPolicyRequest,
      message: l10n.cancelRequestConfirm,
      confirmLabel: l10n.cancelPolicyRequest,
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
            color: AppColors.notice,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.noticeBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.pendingPaymentTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                l10n.pendingPaymentBody,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, color: const Color(0xFF4A4E60)),
              ),
              const SizedBox(height: 14),
              PrimaryButton(label: l10n.payOnline, icon: Icons.credit_card, loading: _paying, onPressed: _payOnline),
              if (_paymentId != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _checking ? null : () => _checkPayment(),
                  icon: _checking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: Text(l10n.checkPaymentStatus),
                ),
              ],
              const SizedBox(height: 12),
              Text(l10n.orPayAtOffice, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 4),
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
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _cancelling ? null : _cancel,
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          icon: const Icon(Icons.close, size: 18),
          label: Text(l10n.cancelPolicyRequest),
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

/// QR code the customer can show at a checkpoint; scanning opens the company's verification page.
class _VerificationQr extends StatelessWidget {
  const _VerificationQr({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          QrImageView(
            data: url,
            size: 176,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          Text(l10n.verificationQrTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            l10n.verificationQrHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}
