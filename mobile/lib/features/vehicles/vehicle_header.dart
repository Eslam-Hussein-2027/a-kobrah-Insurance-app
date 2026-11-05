import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import 'vehicle.dart';

/// Plate number + small tags (model, year, engine).
/// Each value is its own widget so Latin and Arabic text are never mixed in one line
/// (mixing them makes the bidi algorithm split "1600 سي سي" away from its unit).
class VehicleHeader extends StatelessWidget {
  const VehicleHeader({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vehicle.plateNo,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.navy),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag(vehicle.title, ltr: true),
            _Tag('${vehicle.year}', ltr: true),
            _Tag('${vehicle.engineCc} ${context.l10n.ccUnit}'),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.ltr = false});

  final String text;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        textDirection: ltr ? TextDirection.ltr : null,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w600),
      ),
    );
  }
}
