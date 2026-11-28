import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_repository.dart';
import '../catalog/product_icon.dart';
import '../policies/models.dart';
import '../policies/policies_repository.dart';
import '../policies/policy_tile.dart';
import '../vehicles/vehicles_repository.dart';
import 'home_screen.dart';

/// Home: the customer's current policy, a reminder for uninsured vehicles, and every product.
class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).asData?.value;
    final policies = ref.watch(policiesProvider).asData?.value ?? const <Policy>[];
    final vehicles = ref.watch(vehiclesProvider).asData?.value ?? const [];

    final active = policies.where((p) => p.status == PolicyStatus.active).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    final coveredVehicleIds = {
      for (final p in policies)
        if (!p.isTravel && p.isBlocking && p.vehicle != null) p.vehicle!.id,
    };
    final uninsured = vehicles.where((v) => !coveredVehicleIds.contains(v.id)).firstOrNull;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(policiesProvider)
            ..invalidate(vehiclesProvider)
            ..invalidate(productsProvider);
          await ref.read(policiesProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Row(
              children: [
                const AppLogo(height: 34),
                const Spacer(),
                _SquareButton(
                  icon: Icons.headset_mic_outlined,
                  tooltip: l10n.contactUs,
                  onTap: () => context.push('/account/contact'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.hello, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
            Text(user?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 16),
            if (active.isNotEmpty)
              _PolicyCard(policy: active.first, otherActive: active.length - 1)
            else
              _NoPolicyCard(onTap: () => context.push('/products/${Product.motor}')),
            if (uninsured != null) ...[
              const SizedBox(height: 12),
              NoticeBanner(
                icon: Icons.directions_car_outlined,
                title: l10n.uninsuredVehicle,
                message: '${uninsured.title} ${uninsured.year} · ${uninsured.plateNo}',
                action: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    minimumSize: const Size(0, 38),
                    textStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context.push('/motor/issue?vehicle=${uninsured.id}'),
                  child: Text(l10n.insureItNow),
                ),
              ),
            ],
            SectionTitle(
              l10n.insuranceProducts,
              padding: const EdgeInsets.fromLTRB(0, 26, 0, 12),
              trailing: TextButton(
                onPressed: () => ref.read(homeTabProvider.notifier).select(HomeTab.insurance),
                child: Text(l10n.myPoliciesCount(active.length)),
              ),
            ),
            AsyncView(
              value: ref.watch(productsProvider),
              onRetry: () => ref.invalidate(productsProvider),
              builder: (products) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [for (final product in products) _ProductTile(product: product)],
              ),
            ),
            const SizedBox(height: 14),
            const _QuickTools(),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22)),
        ),
      ),
    );
  }
}

/// The customer's nearest-to-expiry active policy, as a navy "wallet" card.
class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.policy, required this.otherActive});

  final Policy policy;
  final int otherActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daysLeft = daysUntil(policy.endDate).clamp(0, 100000);
    final totalDays = DateTime.parse(policy.endDate).difference(DateTime.parse(policy.startDate)).inDays + 1;
    final remaining = totalDays <= 0 ? 0.0 : (daysLeft / totalDays).clamp(0.0, 1.0);
    final vehicle = policy.vehicle;
    const faded = Color(0xC7FFFFFF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppColors.navy,
        child: CustomPaint(
          painter: _RingsPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(policy.productName, style: const TextStyle(color: faded, fontSize: 13)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 3, backgroundColor: Color(0xFF6EDBA6)),
                          const SizedBox(width: 6),
                          Text(
                            policy.statusLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicle != null ? '${vehicle.title} ${vehicle.year}' : policySubject(context, policy),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (vehicle != null) PlateBadge(vehicle.plateNo, onDark: true),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.endsOn(formatDate(context, policy.endDate)),
                        style: const TextStyle(color: faded, fontSize: 13),
                      ),
                    ),
                    Text(
                      l10n.daysLeft(daysLeft),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: remaining,
                    minHeight: 4,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.navy,
                          minimumSize: const Size(0, 44),
                          textStyle: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => context.push('/policies/${policy.id}'),
                        icon: const Icon(Icons.qr_code_2, size: 20),
                        label: Text(l10n.verificationCode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                          minimumSize: const Size(0, 44),
                          textStyle: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => context.push('/policies/${policy.id}'),
                        child: Text(l10n.policyDetails),
                      ),
                    ),
                  ],
                ),
                if (otherActive > 0) ...[
                  const SizedBox(height: 10),
                  Text(l10n.otherActivePolicies(otherActive), style: const TextStyle(color: faded, fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fine concentric rings, like the security pattern of a printed certificate.
class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08);
    final center = Offset(size.width * 0.06, size.height * 0.1);
    for (var radius = 36.0; radius <= 150; radius += 14) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NoPolicyCard extends StatelessWidget {
  const _NoPolicyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const IconBox(Icons.shield_outlined, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.noActivePolicy, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(l10n.noActivePolicyHint, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: l10n.issuePolicy,
              style: IconButton.styleFrom(backgroundColor: AppColors.navy),
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/products/${product.code}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(productIcon(product.icon), color: AppColors.navy, size: 28),
              const Spacer(),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
              ),
              Text(
                product.isInstant ? l10n.instantIssue : l10n.onRequest,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: product.isInstant ? AppColors.success : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTools extends StatelessWidget {
  const _QuickTools();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tools = [
      (Icons.calculate_outlined, l10n.calculatePrice, '/motor/estimate'),
      (Icons.verified_user_outlined, l10n.verifyPolicyShort, '/verify'),
      (Icons.place_outlined, l10n.branches, '/account/branches'),
    ];

    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < tools.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1),
              Expanded(
                child: InkWell(
                  onTap: () => context.push(tools[i].$3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    child: Column(
                      children: [
                        Icon(tools[i].$1, color: AppColors.navy, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          tools[i].$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
