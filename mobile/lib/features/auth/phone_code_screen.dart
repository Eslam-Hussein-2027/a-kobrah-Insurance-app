import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'models.dart';

/// Sign-up, step 2: the code texted to the phone. The form is sent again with it.
class PhoneCodeScreen extends ConsumerStatefulWidget {
  const PhoneCodeScreen({super.key, required this.input});

  final RegistrationInput input;

  @override
  ConsumerState<PhoneCodeScreen> createState() => _PhoneCodeScreenState();
}

class _PhoneCodeScreenState extends ConsumerState<PhoneCodeScreen> {
  final _code = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = context.l10n;
    final code = toWesternDigits(_code.text.trim());
    if (code.length != CodeField.length) {
      setState(() => _error = l10n.otpLength);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(widget.input, code: code);
      // Registered: the router moves to the home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      final codeError = e.fieldError('code');
      if (codeError != null || e.fieldErrors.isEmpty) {
        setState(() => _error = codeError ?? errorMessage(context, e));
      } else {
        // The form itself was refused (e.g. the number was registered meanwhile): back to it.
        showMessage(context, e.fieldErrors.values.first.first, isError: true);
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<int?> _resend() async {
    try {
      final step = await ref.read(authControllerProvider.notifier).register(widget.input);
      if (mounted) showMessage(context, context.l10n.codeResent);
      return step is PhoneCodeSent ? step.resendAfterSeconds : null;
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.sms_outlined, size: 52, color: AppColors.blue),
                  const SizedBox(height: 16),
                  Text(
                    l10n.verifyPhoneTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.otpSubtitle('\u2066${widget.input.phone}\u2069'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  CodeField(controller: _code, errorText: _error, onCompleted: _loading ? null : _confirm),
                  const SizedBox(height: 20),
                  PrimaryButton(label: l10n.confirm, loading: _loading, onPressed: _confirm),
                  const SizedBox(height: 8),
                  ResendCodeButton(onResend: _resend),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
