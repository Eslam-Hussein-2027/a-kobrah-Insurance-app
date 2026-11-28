import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

/// Forgotten password: phone number → SMS code + new password → signed in.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneInput = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  /// Set once a code was requested for this number.
  String? _phone;
  int _resendAfter = 60;
  bool _loading = false;
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    for (final c in [_phoneInput, _code, _password, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, List<String> fields) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errors = const {};
    });
    try {
      await action();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = {for (final f in fields) f: e.fieldError(f)});
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
    final phone = normalizeLibyanPhone(_phoneInput.text);
    final wait = await ref.read(authControllerProvider.notifier).forgotPassword(phone);
    if (mounted) {
      setState(() {
        _phone = phone;
        _resendAfter = wait;
      });
    }
  }, ['phone']);

  Future<void> _reset() => _run(() async {
    final code = toWesternDigits(_code.text.trim());
    await ref.read(authControllerProvider.notifier).resetPassword(phone: _phone!, code: code, password: _password.text);
    // Signed in: the router moves to the home screen.
  }, ['code', 'password']);

  Future<int?> _resend() async {
    try {
      final wait = await ref.read(authControllerProvider.notifier).forgotPassword(_phone!);
      if (mounted) showMessage(context, context.l10n.codeResent);
      return wait;
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = _phone;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(
          label: phone == null ? l10n.sendCode : l10n.setNewPassword,
          loading: _loading,
          onPressed: phone == null ? _sendCode : _reset,
        ),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              children: [
                if (phone == null) ...[
                  Text(
                    l10n.resetPasswordSubtitle,
                    style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: l10n.phoneLabel,
                    child: PhoneField(
                      controller: _phoneInput,
                      errorText: _errors['phone'],
                      onSubmitted: (_) => _sendCode(),
                    ),
                  ),
                ] else ...[
                  NoticeBanner(icon: Icons.sms_outlined, message: l10n.otpSubtitle('\u2066$phone\u2069')),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: l10n.otpTitle,
                    child: CodeField(controller: _code, errorText: _errors['code']),
                  ),
                  LabeledField(
                    label: l10n.newPassword,
                    child: PasswordField(
                      controller: _password,
                      hint: l10n.newPasswordHint(PasswordRules.minLength),
                      errorText: _errors['password'],
                      validator: PasswordRules.newPassword(context),
                      newPassword: true,
                    ),
                  ),
                  LabeledField(
                    label: l10n.confirmPassword,
                    child: PasswordField(
                      controller: _confirmation,
                      hint: l10n.confirmPassword,
                      validator: PasswordRules.confirmation(context, _password),
                      newPassword: true,
                      onSubmitted: (_) => _reset(),
                    ),
                  ),
                  ResendCodeButton(onResend: _resend, waitSeconds: _resendAfter),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
