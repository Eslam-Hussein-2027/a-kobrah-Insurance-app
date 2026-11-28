import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../account/account_tab.dart';
import '../policies/my_insurance_tab.dart';
import '../policies/policies_repository.dart';
import '../requests/requests_repository.dart';
import '../vehicles/vehicles_tab.dart';
import 'dashboard_tab.dart';

/// In bar order (first item sits on the right in Arabic).
enum HomeTab { insurance, vehicles, home, account }

class HomeTabController extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.home;

  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabController, HomeTab>(HomeTabController.new);

/// Signed-in shell: four tabs kept alive in an [IndexedStack].
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: const [MyInsuranceTab(), VehiclesTab(), DashboardTab(), AccountTab()],
      ),
      bottomNavigationBar: _BottomNav(
        selected: tab,
        onSelected: (selected) {
          if (selected == HomeTab.insurance) {
            ref
              ..invalidate(policiesProvider)
              ..invalidate(requestsProvider);
          }
          ref.read(homeTabProvider.notifier).select(selected);
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelected});

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = {
      HomeTab.insurance: (Icons.task_outlined, l10n.tabMyInsurance),
      HomeTab.vehicles: (Icons.directions_car_outlined, l10n.tabVehicles),
      HomeTab.home: (Icons.home_outlined, l10n.tabHome),
      HomeTab.account: (Icons.person_outline, l10n.tabAccount),
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final MapEntry(key: tab, value: (icon, label)) in items.entries)
                Expanded(
                  child: _NavItem(icon: icon, label: label, selected: tab == selected, onTap: () => onSelected(tab)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : const Color(0xFF7A7D8C);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
