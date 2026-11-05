import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';

/// Public check (no login): policy number + plate number → valid / expired / not found.
class VerifyPolicyScreen extends ConsumerStatefulWidget {
  const VerifyPolicyScreen({super.key});

  @override
  ConsumerState<VerifyPolicyScreen> createState() => _VerifyPolicyScreenState();
}

class _VerifyPolicyScreenState extends ConsumerState<VerifyPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _policyNo = TextEditingController();
  final _plateNo = TextEditingController();
  bool _loading = false;
  PolicyVerification? _result;
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    _policyNo.dispose();
    _plateNo.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = null;
      _errors = const {};
    });

    try {
      final result = await ref
          .read(policiesRepositoryProvider)
          .verify(
            policyNo: toWesternDigits(_policyNo.text.trim()).toUpperCase(),
            plateNo: toWesternDigits(_plateNo.text.trim()),
          );
      if (mounted) setState(() => _result = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = {'policy_no': e.fieldError('policy_no'), 'plate_no': e.fieldError('plate_no')});
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n.verifySubtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _policyNo,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.policyNo,
                  hintText: 'POL-2026-000001',
                  hintTextDirection: TextDirection.ltr,
                  prefixIcon: const Icon(Icons.numbers),
                  errorText: _errors['policy_no'],
                  errorMaxLines: 2,
                ),
                validator: required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _plateNo,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.plateNo,
                  hintText: l10n.plateHint,
                  prefixIcon: const Icon(Icons.pin_outlined),
                  errorText: _errors['plate_no'],
                ),
                validator: required,
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: l10n.check, loading: _loading, onPressed: _check),
              if (_result != null) ...[const SizedBox(height: 20), _ResultCard(result: _result!)],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final PolicyVerification result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (color, icon) = result.isValid
        ? (AppColors.success, Icons.verified)
        : result.isExpired
        ? (AppColors.warning, Icons.history)
        : (AppColors.danger, Icons.cancel_outlined);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 44),
          const SizedBox(height: 8),
          Text(
            result.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          if (result.policyNo != null) ...[
            const Divider(height: 24),
            InfoRow(label: l10n.policyNo, value: result.policyNo!, ltr: true),
            if (result.coverageType != null) InfoRow(label: l10n.coverage, value: result.coverageType!),
            if (result.startDate != null) InfoRow(label: l10n.startDate, value: result.startDate!, ltr: true),
            if (result.endDate != null) InfoRow(label: l10n.endDate, value: result.endDate!, ltr: true),
          ],
        ],
      ),
    );
  }
}
