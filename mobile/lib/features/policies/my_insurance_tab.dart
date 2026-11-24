import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../catalog/catalog_repository.dart';
import '../catalog/product_icon.dart';
import '../requests/request_tile.dart';
import '../requests/requests_repository.dart';
import 'models.dart';
import 'policies_repository.dart';
import 'policy_tile.dart';

enum InsuranceFilter { all, active, requests }

class InsuranceFilterController extends Notifier<InsuranceFilter> {
  @override
  InsuranceFilter build() => InsuranceFilter.all;

  void select(InsuranceFilter filter) => state = filter;
}

final insuranceFilterProvider = NotifierProvider<InsuranceFilterController, InsuranceFilter>(
  InsuranceFilterController.new,
);

/// "My insurance": every policy (motor + travel) and the requests sent to the company.
class MyInsuranceTab extends ConsumerWidget {
  const MyInsuranceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(insuranceFilterProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tabMyInsurance, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                ChoiceChips<InsuranceFilter>(
                  options: [
                    (InsuranceFilter.all, l10n.filterAllPolicies),
                    (InsuranceFilter.active, l10n.filterActive),
                    (InsuranceFilter.requests, l10n.filterRequests),
                  ],
                  selected: filter,
                  onSelected: ref.read(insuranceFilterProvider.notifier).select,
                ),
              ],
            ),
          ),
          Expanded(child: filter == InsuranceFilter.requests ? const _RequestsList() : _PoliciesList(filter: filter)),
        ],
      ),
    );
  }
}

class _PoliciesList extends ConsumerWidget {
  const _PoliciesList({required this.filter});

  final InsuranceFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncView(
      value: ref.watch(policiesProvider),
      onRetry: () => ref.invalidate(policiesProvider),
      builder: (all) {
        final policies = filter == InsuranceFilter.active
            ? all.where((p) => p.status == PolicyStatus.active).toList()
            : all;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(policiesProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              if (policies.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: EmptyView(
                    icon: Icons.description_outlined,
                    title: l10n.noPolicies,
                    subtitle: l10n.noPoliciesHint,
                  ),
                )
              else
                ListGroup(children: [for (final policy in policies) PolicyTile(policy: policy)]),
            ],
          ),
        );
      },
    );
  }
}

class _RequestsList extends ConsumerWidget {
  const _RequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final products = ref.watch(productsProvider).asData?.value ?? const [];

    IconData iconFor(String code) => productIcon(products.where((p) => p.code == code).firstOrNull?.icon ?? '');

    return AsyncView(
      value: ref.watch(requestsProvider),
      onRetry: () => ref.invalidate(requestsProvider),
      builder: (requests) => RefreshIndicator(
        onRefresh: () => ref.refresh(requestsProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: EmptyView(icon: Icons.outbox_outlined, title: l10n.noRequests, subtitle: l10n.noRequestsHint),
              )
            else ...[
              ListGroup(
                children: [
                  for (final request in requests) RequestTile(request: request, icon: iconFor(request.productCode)),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.requestsNotificationHint, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}
