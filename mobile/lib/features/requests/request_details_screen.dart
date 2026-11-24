import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'request_models.dart';
import 'request_status.dart';
import 'requests_repository.dart';

class RequestDetailsScreen extends ConsumerWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.requestDetails)),
      body: AsyncView(
        value: ref.watch(requestProvider(requestId)),
        onRetry: () => ref.invalidate(requestProvider(requestId)),
        builder: (request) => RefreshIndicator(
          onRefresh: () => ref.refresh(requestProvider(requestId).future),
          child: _RequestBody(request: request),
        ),
      ),
    );
  }
}

class _RequestBody extends ConsumerStatefulWidget {
  const _RequestBody({required this.request});

  final InsuranceRequest request;

  @override
  ConsumerState<_RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends ConsumerState<_RequestBody> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.withdrawRequest,
      message: l10n.withdrawRequestConfirm,
      confirmLabel: l10n.withdrawRequest,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(requestsRepositoryProvider).cancel(widget.request.id);
      ref
        ..invalidate(requestProvider(widget.request.id))
        ..invalidate(requestsProvider);
      if (mounted) showMessage(context, l10n.requestWithdrawn);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = widget.request;
    final replied = request.staffReply != null || request.quotedAmount != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${request.productName} · ${request.kindLabel}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
            StatusPill(label: request.statusLabel, tone: requestTone(request.status)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          request.requestNo,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        Text(
          l10n.sentOn(formatDate(context, request.createdAt)),
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        if (replied)
          _ReplyCard(request: request)
        else
          NoticeBanner(tone: StatusTone.info, icon: Icons.schedule, message: l10n.requestWaitingHint),
        SectionTitle(l10n.requestData),
        SectionCard(
          child: Column(
            children: [
              for (final detail in request.details) InfoRow(label: detail.label, value: detail.value),
              if (request.notes != null) InfoRow(label: l10n.notes, value: request.notes!),
            ],
          ),
        ),
        if (request.documents.isNotEmpty) ...[
          SectionTitle(l10n.documents),
          ListGroup(
            children: [
              for (final document in request.documents)
                NavRow(icon: Icons.attach_file, title: document.label, subtitle: document.name),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (request.canCancel)
          OutlinedButton.icon(
            onPressed: _cancelling ? null : _cancel,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.close),
            label: Text(l10n.withdrawRequest),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${l10n.customerService}: ', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const Text(
              AppConfig.customerServicePhone,
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

/// The company's answer: price offer and/or message.
class _ReplyCard extends StatelessWidget {
  const _ReplyCard({required this.request});

  final InsuranceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_chat_read_outlined, color: AppColors.navy, size: 20),
              const SizedBox(width: 8),
              Text(l10n.companyReply, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          if (request.quotedAmount != null) ...[
            const SizedBox(height: 10),
            Text(l10n.offeredPrice, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            Text(
              formatMoney(context, request.quotedAmount!),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
          ],
          if (request.staffReply != null) ...[
            const SizedBox(height: 8),
            Text(request.staffReply!, style: const TextStyle(fontSize: 14, height: 1.6)),
          ],
          if (request.status == RequestStatus.quoted) ...[
            const SizedBox(height: 10),
            Text(l10n.acceptOfferHint, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}
