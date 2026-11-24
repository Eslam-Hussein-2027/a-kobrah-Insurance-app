import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'travel_issue_screen.dart';
import 'travel_models.dart';
import 'travel_repository.dart';

/// "Know the price" for travel: prices come from the server's tariff, the total is computed live.
class TravelEstimateScreen extends ConsumerStatefulWidget {
  const TravelEstimateScreen({super.key});

  @override
  ConsumerState<TravelEstimateScreen> createState() => _TravelEstimateScreenState();
}

class _TravelEstimateScreenState extends ConsumerState<TravelEstimateScreen> {
  String? _zoneValue;
  int? _days;
  int _travellers = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelPriceTitle)),
      body: AsyncView(
        value: ref.watch(travelOptionsProvider),
        onRetry: () => ref.invalidate(travelOptionsProvider),
        builder: (options) {
          if (options.zones.isEmpty) return ErrorView(message: l10n.travelUnavailable);

          final zone = options.zone(_zoneValue ?? '') ?? options.zones.first;
          final duration = zone.duration(_days ?? -1) ?? zone.durations.first;
          final total = duration.pricePerTraveller * _travellers;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    SectionTitle(l10n.destination, padding: const EdgeInsets.fromLTRB(0, 8, 0, 10)),
                    ChoiceChips<String>(
                      expand: true,
                      options: [for (final z in options.zones) (z.value, z.label)],
                      selected: zone.value,
                      onSelected: (value) => setState(() => _zoneValue = value),
                    ),
                    SectionTitle(l10n.tripLength),
                    ChoiceChips<int>(
                      expand: zone.durations.length <= 4,
                      options: [for (final d in zone.durations) (d.days, daysLabel(context, d.days))],
                      selected: duration.days,
                      onSelected: (days) => setState(() => _days = days),
                    ),
                    SectionTitle(l10n.travellersNumber),
                    _Stepper(
                      value: _travellers,
                      max: options.maxTravellers,
                      label: travellersLabel(context, _travellers),
                      onChanged: (value) => setState(() => _travellers = value),
                    ),
                    const SizedBox(height: 24),
                    PriceCard(
                      title: l10n.estimatedPrice,
                      total: formatMoney(context, amount(total)),
                      rows: [(l10n.pricePerTraveller, formatMoney(context, amount(duration.pricePerTraveller)))],
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.estimateDisclaimer, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ),
              BottomActionBar(
                button: PrimaryButton(
                  label: l10n.issueNow,
                  onPressed: () => context.pushReplacement('/travel/issue?zone=${zone.value}&days=${duration.days}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.max, required this.label, required this.onChanged});

  final int value;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton.outlined(
              tooltip: l10n.increase,
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton.outlined(
              tooltip: l10n.decrease,
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
