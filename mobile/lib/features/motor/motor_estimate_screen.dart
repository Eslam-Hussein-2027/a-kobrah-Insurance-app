import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';

/// "Know the price" for compulsory insurance, before registering the vehicle.
class MotorEstimateScreen extends ConsumerStatefulWidget {
  const MotorEstimateScreen({super.key});

  @override
  ConsumerState<MotorEstimateScreen> createState() => _MotorEstimateScreenState();
}

class _MotorEstimateScreenState extends ConsumerState<MotorEstimateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _engine = TextEditingController();
  int? _year;
  Quote? _quote;
  bool _loading = false;

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final quote = await ref
          .read(policiesRepositoryProvider)
          .estimate(manufactureYear: _year!, engineCc: int.parse(toWesternDigits(_engine.text.trim())));
      if (mounted) setState(() => _quote = quote);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentYear = DateTime.now().year;
    final quote = _quote;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.motorPriceTitle)),
      bottomNavigationBar: BottomActionBar(
        button: quote == null
            ? PrimaryButton(label: l10n.calculatePrice, loading: _loading, onPressed: _calculate)
            : PrimaryButton(label: l10n.issueNow, onPressed: () => context.pushReplacement('/motor/issue')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _year,
              menuMaxHeight: 320,
              decoration: InputDecoration(labelText: l10n.year),
              items: [
                for (var year = currentYear + 1; year >= 1970; year--)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              validator: (value) => value == null ? l10n.requiredField : null,
              onChanged: (value) => setState(() {
                _year = value;
                _quote = null;
              }),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _engine,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
              decoration: InputDecoration(labelText: l10n.engineCc, suffixText: l10n.ccUnit, hintText: '1600'),
              onChanged: (_) {
                if (_quote != null) setState(() => _quote = null);
              },
              validator: (value) {
                final cc = int.tryParse(toWesternDigits(value?.trim() ?? ''));
                return (cc == null || cc < 50 || cc > 10000) ? l10n.engineCcInvalid : null;
              },
            ),
            const SizedBox(height: 22),
            if (quote != null) ...[
              PriceCard(
                title: l10n.estimatedPriceOneYear,
                total: formatMoney(context, quote.premium),
                rows: [
                  (l10n.basePrice, formatMoney(context, quote.basePrice)),
                  for (final factor in quote.factors) ('${factor.label} (${factor.input})', '× ${factor.multiplier}'),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text(l10n.estimateDisclaimer, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
