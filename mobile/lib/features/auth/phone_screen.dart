import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _loading = false;
  String? _phoneError;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = normalizeLibyanPhone(_phone.text);
    setState(() {
      _loading = true;
      _phoneError = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).sendOtp(phone);
      if (mounted) {
        unawaited(context.push(Uri(path: '/login/otp', queryParameters: {'phone': phone}).toString()));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _phoneError = e.fieldError('phone'));
      if (_phoneError == null) {
        showMessage(context, errorMessage(context, e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(height: 64),
                    const SizedBox(height: 40),
                    Text(
                      l10n.welcome,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.loginSubtitle, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 28),
                    TextFormField(
                      key: const Key('phone-field'),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        labelText: l10n.phoneLabel,
                        hintText: '09XXXXXXXX',
                        hintTextDirection: TextDirection.ltr,
                        prefixIcon: const Icon(Icons.phone_iphone),
                        errorText: _phoneError,
                        errorMaxLines: 3,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? l10n.requiredField : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(label: l10n.sendCode, loading: _loading, onPressed: _submit),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context.push('/verify'),
                      icon: const Icon(Icons.verified_user_outlined),
                      label: Text(l10n.verifyPolicyLink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
