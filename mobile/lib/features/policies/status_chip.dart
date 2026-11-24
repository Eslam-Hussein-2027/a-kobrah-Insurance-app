import 'package:flutter/material.dart';

import '../../shared/ui.dart';
import 'models.dart';

StatusTone policyTone(PolicyStatus status) => switch (status) {
  PolicyStatus.active => StatusTone.success,
  PolicyStatus.pendingPayment => StatusTone.warning,
  PolicyStatus.cancelled => StatusTone.danger,
  PolicyStatus.expired || PolicyStatus.unknown => StatusTone.neutral,
};

class PolicyStatusChip extends StatelessWidget {
  const PolicyStatusChip({super.key, required this.status, required this.label});

  final PolicyStatus status;
  final String label;

  @override
  Widget build(BuildContext context) => StatusPill(label: label, tone: policyTone(status));
}
