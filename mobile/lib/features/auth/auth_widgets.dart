import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';

/// Page title with an accent bar, and a short line under it.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 15, color: AppColors.muted)),
      ],
    );
  }
}

/// Libyan mobile number typed after a fixed "+218" box (with or without the leading 0).
class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller, this.errorText, this.onSubmitted});

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the country box on the left in both languages, as on printed numbers.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    const countryBox = _CountryCodeBox();

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹+ ]'))],
      decoration: InputDecoration(
        hintText: l10n.phoneHint,
        helperText: l10n.phoneHelper,
        helperMaxLines: 2,
        errorText: errorText,
        errorMaxLines: 3,
        prefixIcon: rtl ? null : countryBox,
        suffixIcon: rtl ? countryBox : null,
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? l10n.requiredField : null,
      onFieldSubmitted: onSubmitted,
    );
  }
}

class _CountryCodeBox extends StatelessWidget {
  const _CountryCodeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.navyTint,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(13)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          LibyaFlag(width: 26),
          SizedBox(width: 8),
          Text(
            '+218',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// Drawn (not an emoji) so it shows the same on every phone and browser.
class LibyaFlag extends StatelessWidget {
  const LibyaFlag({super.key, this.width = 24});

  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: CustomPaint(size: Size(width, width / 2), painter: _LibyaFlagPainter()),
    );
  }
}

class _LibyaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // Red, black (double height) and green bands.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 4), paint..color = const Color(0xFFE70013));
    canvas.drawRect(Rect.fromLTWH(0, h / 4, w, h / 2), paint..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(0, h * 3 / 4, w, h / 4), paint..color = const Color(0xFF239E46));

    // White crescent opening to the right, and a star.
    final center = Offset(w / 2 - h * 0.04, h / 2);
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: h * 0.2)),
      Path()..addOval(Rect.fromCircle(center: center.translate(h * 0.06, 0), radius: h * 0.165)),
    );
    canvas.drawPath(crescent, paint..color = Colors.white);
    canvas.drawPath(_star(center.translate(h * 0.17, 0), h * 0.1), paint);
  }

  Path _star(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(r * math.cos(angle), r * math.sin(angle));
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Password with a show / hide button.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    this.errorText,
    this.validator,
    this.onSubmitted,
    this.newPassword = false,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  /// Lets password managers offer to save / generate it.
  final bool newPassword;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      autofillHints: [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password],
      textInputAction: widget.onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 3,
        suffixIcon: IconButton(
          tooltip: _hidden ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.subtle),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
      validator: widget.validator ?? (value) => (value == null || value.isEmpty) ? l10n.requiredField : null,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}

/// Validators for a new password and its confirmation.
abstract final class PasswordRules {
  static const minLength = 6;

  static FormFieldValidator<String> newPassword(BuildContext context) => (value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) return l10n.requiredField;
    return value.length < minLength ? l10n.passwordTooShort(minLength) : null;
  };

  static FormFieldValidator<String> confirmation(BuildContext context, TextEditingController password) => (value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) return l10n.requiredField;
    return value != password.text ? l10n.passwordsDontMatch : null;
  };
}

/// 6-digit SMS code (Arabic digits accepted). Calls [onCompleted] once all digits are typed.
class CodeField extends StatelessWidget {
  const CodeField({super.key, required this.controller, this.errorText, this.onCompleted, this.autofocus = true});

  static const length = 6;

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onCompleted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('otp-field'),
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLength: length,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]'))],
      style: const TextStyle(fontSize: 26, letterSpacing: 12, fontWeight: FontWeight.w700),
      decoration: InputDecoration(counterText: '', hintText: '••••••', errorText: errorText, errorMaxLines: 3),
      onChanged: (value) {
        if (value.length == length) onCompleted?.call();
      },
    );
  }
}

/// "Resend in 59 s" countdown, then a button that asks for a new code.
class ResendCodeButton extends StatefulWidget {
  const ResendCodeButton({super.key, required this.onResend, this.waitSeconds = 60});

  /// Returns the seconds to wait before the next resend.
  final Future<int?> Function() onResend;
  final int waitSeconds;

  @override
  State<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<ResendCodeButton> {
  Timer? _timer;
  late int _secondsLeft;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _start(widget.waitSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(int seconds) {
    _timer?.cancel();
    _secondsLeft = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      final wait = await widget.onResend();
      if (mounted && wait != null) setState(() => _start(wait));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextButton(
      onPressed: _secondsLeft > 0 || _sending ? null : _resend,
      child: Text(_secondsLeft > 0 ? l10n.resendIn(_secondsLeft) : l10n.resendCode),
    );
  }
}
