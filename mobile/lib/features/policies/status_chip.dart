import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'models.dart';

class PolicyStatusChip extends StatelessWidget {
  const PolicyStatusChip({super.key, required this.status, required this.label});

  final PolicyStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      PolicyStatus.active => (AppColors.success, Icons.verified),
      PolicyStatus.pendingPayment => (AppColors.warning, Icons.schedule),
      PolicyStatus.cancelled => (AppColors.danger, Icons.block),
      PolicyStatus.expired || PolicyStatus.unknown => (AppColors.muted, Icons.history),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
