import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_widgets.dart';

/// Current password, then the new one twice. Other devices are signed out by the server.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    for (final c in [_current, _password, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _errors = const {};
    });
    try {
      await ref.read(authControllerProvider.notifier).changePassword(current: _current.text, password: _password.text);
      if (!mounted) return;
      showMessage(context, l10n.passwordChanged);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _errors = {
          for (final f in ['current_password', 'password']) f: e.fieldError(f),
        },
      );
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(label: l10n.save, loading: _saving, onPressed: _save),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                LabeledField(
                  label: l10n.currentPassword,
                  child: PasswordField(
                    controller: _current,
                    hint: l10n.currentPassword,
                    errorText: _errors['current_password'],
                  ),
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
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
