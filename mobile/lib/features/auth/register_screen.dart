import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'models.dart';

/// Sign-up form. When the server texts a code to confirm the phone, the next screen asks for it.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const _fields = ['first_name', 'last_name', 'phone', 'address', 'password'];

  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _phone, _address, _password, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final input = RegistrationInput(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: normalizeLibyanPhone(_phone.text),
      address: _address.text.trim(),
      password: _password.text,
    );

    setState(() {
      _loading = true;
      _errors = const {};
    });
    try {
      final step = await ref.read(authControllerProvider.notifier).register(input);
      if (!mounted) return;
      if (step is PhoneCodeSent) {
        await context.push('/register/verify', extra: input);
      }
      // Registered: the router moves to the home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = {for (final f in _fields) f: e.fieldError(f)});
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty) ? context.l10n.requiredField : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(label: l10n.signUpButton, loading: _loading, onPressed: _submit),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              children: [
                AuthHeader(title: l10n.signUpTitle, subtitle: l10n.signUpSubtitle),
                const SizedBox(height: 24),
                LabeledField(
                  label: l10n.firstName,
                  required: true,
                  child: TextFormField(
                    controller: _firstName,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    decoration: InputDecoration(hintText: l10n.firstName, errorText: _errors['first_name']),
                    validator: _required,
                  ),
                ),
                LabeledField(
                  label: l10n.lastName,
                  required: true,
                  child: TextFormField(
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    decoration: InputDecoration(hintText: l10n.lastName, errorText: _errors['last_name']),
                    validator: _required,
                  ),
                ),
                LabeledField(
                  label: l10n.phoneLabel,
                  required: true,
                  child: PhoneField(controller: _phone, errorText: _errors['phone']),
                ),
                LabeledField(
                  label: l10n.address,
                  required: true,
                  child: TextFormField(
                    controller: _address,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.fullStreetAddress],
                    decoration: InputDecoration(hintText: l10n.address, errorText: _errors['address']),
                    validator: _required,
                  ),
                ),
                LabeledField(
                  label: l10n.password,
                  required: true,
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
                  required: true,
                  child: PasswordField(
                    controller: _confirmation,
                    hint: l10n.confirmPassword,
                    validator: PasswordRules.confirmation(context, _password),
                    newPassword: true,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                    child: Text(l10n.haveAccountSignIn),
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
