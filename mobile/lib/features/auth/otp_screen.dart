import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';
import 'models.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendSeconds = 60;

  final _code = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
      }
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final code = toWesternDigits(_code.text.trim());
    if (code.length != 6) {
      setState(() => _error = l10n.otpLength);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ref.read(authControllerProvider.notifier).verifyOtp(widget.phone, code);
      if (!mounted) return;
      if (result is NeedsRegistration) {
        context.go('/register', extra: result.registrationToken);
      }
      // LoggedIn: the router redirects to the home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.fieldError('code') ?? e.fieldError('phone') ?? errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authControllerProvider.notifier).sendOtp(widget.phone);
      if (!mounted) return;
      _startCountdown();
      showMessage(context, context.l10n.codeResent);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
                  const Icon(Icons.sms_outlined, size: 56, color: AppColors.blue),
                  const SizedBox(height: 16),
                  Text(
                    l10n.otpTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.otpSubtitle('\u2066${widget.phone}\u2069'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    key: const Key('otp-field'),
                    controller: _code,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]'))],
                    style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      errorText: _error,
                      errorMaxLines: 3,
                    ),
                    onChanged: (value) {
                      if (value.length == 6 && !_loading) _verify();
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: l10n.confirm, loading: _loading, onPressed: _verify),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _secondsLeft > 0 ? null : _resend,
                    child: Text(_secondsLeft > 0 ? l10n.resendIn(_secondsLeft) : l10n.resendCode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
