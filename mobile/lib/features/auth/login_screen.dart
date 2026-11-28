import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

/// First screen for signed-out users: phone + password, or go to sign-up.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(normalizeLibyanPhone(_phone.text), _password.text);
      // Signed in: the router moves to the home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.fieldError('phone') ?? e.fieldError('password'));
      if (_error == null) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppLogo(height: 56),
                      const SizedBox(height: 36),
                      AuthHeader(title: l10n.loginTitle, subtitle: l10n.loginWelcomeBack),
                      const SizedBox(height: 28),
                      LabeledField(
                        label: l10n.phoneLabel,
                        child: PhoneField(key: const Key('phone-field'), controller: _phone),
                      ),
                      LabeledField(
                        label: l10n.password,
                        child: PasswordField(
                          key: const Key('password-field'),
                          controller: _password,
                          hint: l10n.passwordHint,
                          errorText: _error,
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(label: l10n.loginButton, loading: _loading, onPressed: _submit),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => context.push('/register'), child: Text(l10n.newUserRegister)),
                      TextButton.icon(
                        onPressed: () => context.push('/verify'),
                        icon: const Icon(Icons.verified_user_outlined, size: 20),
                        label: Text(l10n.verifyPolicyLink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
