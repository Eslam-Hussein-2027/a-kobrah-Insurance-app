import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import 'models.dart';
import 'policies_repository.dart';

/// Pay with a wallet / bank app (DPAY): phone number → code sent by the payment service → confirm.
/// Pops `true` when the payment went through.
class OtpPaymentSheet extends ConsumerStatefulWidget {
  const OtpPaymentSheet({super.key, required this.policy, required this.options});

  final Policy policy;
  final PaymentOptions options;

  @override
  ConsumerState<OtpPaymentSheet> createState() => _OtpPaymentSheetState();
}

class _OtpPaymentSheetState extends ConsumerState<OtpPaymentSheet> {
  late final _phone = TextEditingController(text: ref.read(authControllerProvider).asData?.value?.phone ?? '');
  final _code = TextEditingController();
  late String? _method = widget.options.methods.firstOrNull?.value;

  /// Set once the payment service has sent the code.
  OnlinePayment? _payment;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final payment = await ref
          .read(policiesRepositoryProvider)
          .payOnline(widget.policy.id, phone: normalizeLibyanPhone(_phone.text), payMethod: _method);
      setState(() {
        _payment = payment;
        _code.clear();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('phone') ?? errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final payment = _payment;
    if (payment == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(policiesRepositoryProvider)
          .confirmPayment(payment.id, toWesternDigits(_code.text.trim()));
      if (!mounted) return;

      if (result.payment.isPaid) {
        Navigator.of(context).pop(true);
      } else if (result.payment.isFailed) {
        // Declined: start again from the phone number (a new session is needed).
        setState(() {
          _payment = null;
          _error = result.message ?? context.l10n.paymentFailed;
        });
      } else {
        setState(() => _error = result.message ?? context.l10n.paymentNotConfirmedYet);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('otp') ?? errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final waitingForCode = _payment != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.payOnline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(
            '${widget.policy.policyNo} · ${formatMoney(context, widget.policy.premium)}',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          if (!waitingForCode) ...[
            if (widget.options.methods.length > 1) ...[
              Text(l10n.payWith, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ChoiceChips<String>(
                options: [for (final m in widget.options.methods) (m.value, m.label)],
                selected: _method,
                onSelected: (value) => setState(() => _method = value),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩+ ]'))],
              decoration: InputDecoration(
                labelText: l10n.walletPhone(_methodLabel()),
                helperText: l10n.walletPhoneHint,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: l10n.sendPaymentCode, loading: _busy, onPressed: _sendCode),
          ] else ...[
            Text(
              l10n.enterPaymentCode(_phone.text.trim()),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3D4155), height: 1.6),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
              style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w600),
              decoration: InputDecoration(counterText: '', errorText: _error),
              onSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: l10n.confirmPayment, loading: _busy, onPressed: _confirm),
            TextButton(
              onPressed: _busy ? null : () => setState(() => _payment = null),
              child: Text(l10n.changeNumberOrResend),
            ),
          ],
        ],
      ),
    );
  }

  String _methodLabel() =>
      widget.options.methods.where((m) => m.value == _method).firstOrNull?.label ?? context.l10n.paymentService;
}
