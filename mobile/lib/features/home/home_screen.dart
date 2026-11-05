import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../policies/policies_repository.dart';
import '../policies/policies_tab.dart';
import '../profile/profile_tab.dart';
import '../vehicles/vehicles_tab.dart';

enum HomeTab { vehicles, policies, profile }

class HomeTabController extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.vehicles;

  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabController, HomeTab>(HomeTabController.new);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tab = ref.watch(homeTabProvider);

    return Scaffold(
      body: IndexedStack(index: tab.index, children: const [VehiclesTab(), PoliciesTab(), ProfileTab()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) {
          final selected = HomeTab.values[index];
          if (selected == HomeTab.policies) ref.invalidate(policiesProvider);
          ref.read(homeTabProvider.notifier).select(selected);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.directions_car_outlined),
            selectedIcon: const Icon(Icons.directions_car_filled),
            label: l10n.tabVehicles,
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: l10n.tabPolicies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
