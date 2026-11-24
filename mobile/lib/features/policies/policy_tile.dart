import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'models.dart';
import 'status_chip.dart';

/// One line for a policy: product, what it covers (vehicle / trip), status and dates.
class PolicyTile extends StatelessWidget {
  const PolicyTile({super.key, required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subject = policySubject(context, policy);
    final dates = switch (policy.status) {
      PolicyStatus.expired => l10n.endedOn(formatDate(context, policy.endDate)),
      PolicyStatus.pendingPayment => l10n.awaitingPayment,
      _ => l10n.validUntil(formatDate(context, policy.endDate)),
    };

    return InkWell(
      onTap: () => context.push('/policies/${policy.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBox(policy.isTravel ? Icons.luggage_outlined : Icons.directions_car_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          policy.productName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      PolicyStatusChip(status: policy.status, label: policy.statusLabel),
                    ],
                  ),
                  Text(subject, style: const TextStyle(fontSize: 13, color: Color(0xFF3D4155))),
                  Text('${policy.policyNo} · $dates', style: const TextStyle(fontSize: 12, color: AppColors.subtle)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the policy covers, in one line: "Toyota Hilux 2019 · 7-334519" or "Europe (Schengen) · 2 travellers".
String policySubject(BuildContext context, Policy policy) {
  final travel = policy.travel;
  if (travel != null) {
    return '${travel.zoneLabel} · ${context.l10n.travellersCount(travel.travellers.length)}';
  }
  final vehicle = policy.vehicle;
  return vehicle == null ? policy.title : '${vehicle.title} ${vehicle.year} · ${vehicle.plateNo}';
}
