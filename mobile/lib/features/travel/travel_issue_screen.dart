import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../persons/person.dart';
import '../persons/persons_repository.dart';
import 'travel_models.dart';
import 'travel_repository.dart';

/// Travel step 1: destination, trip length, start date and travellers.
class TravelIssueScreen extends ConsumerWidget {
  const TravelIssueScreen({super.key, this.initialZone, this.initialDays});

  /// Pre-selected from the price calculator.
  final String? initialZone;
  final int? initialDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncView(
      value: ref.watch(travelOptionsProvider),
      onRetry: () => ref.invalidate(travelOptionsProvider),
      builder: (options) => options.zones.isEmpty
          ? Scaffold(
              appBar: AppBar(),
              body: ErrorView(message: l10n.travelUnavailable),
            )
          : _TravelForm(options: options, initialZone: initialZone, initialDays: initialDays),
    );
  }
}

class _TravelForm extends ConsumerStatefulWidget {
  const _TravelForm({required this.options, this.initialZone, this.initialDays});

  final TravelOptions options;
  final String? initialZone;
  final int? initialDays;

  @override
  ConsumerState<_TravelForm> createState() => _TravelFormState();
}

class _TravelFormState extends ConsumerState<_TravelForm> {
  late TravelZone _zone = widget.options.zone(widget.initialZone ?? '') ?? widget.options.zones.first;
  late int _days = widget.initialDays ?? _zone.durations.first.days;
  DateTime _startDate = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));

  /// null until the customer changes the selection: the first saved person (usually the account
  /// holder) is selected by default.
  Set<int>? _selected;

  TravelDuration get _duration => _zone.duration(_days) ?? _zone.durations.first;

  void _selectZone(TravelZone zone) => setState(() {
    _zone = zone;
    if (zone.duration(_days) == null) _days = zone.durations.first.days;
  });

  Future<void> _pickStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: today,
      lastDate: today.add(Duration(days: widget.options.maxStartDaysAhead)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _continue(List<Person> travellers) {
    context.push(
      '/travel/review',
      extra: TravelSelection(zone: _zone, duration: _duration, startDate: _startDate, travellers: travellers),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final persons = ref.watch(personsProvider);
    final all = persons.asData?.value ?? const <Person>[];
    final selectedIds = _selected ?? {if (all.isNotEmpty) all.first.id};
    final travellers = [
      for (final person in all)
        if (selectedIds.contains(person.id)) person,
    ];
    final missingPassport = travellers.where((p) => !p.canTravel).toList();
    final canContinue = travellers.isNotEmpty && missingPassport.isEmpty;
    final total = _duration.pricePerTraveller * travellers.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelIssueTitle)),
      bottomNavigationBar: BottomActionBar(
        caption: travellersLabel(context, travellers.length),
        amount: formatMoney(context, amount(total)),
        button: PrimaryButton(label: l10n.continueLabel, onPressed: canContinue ? () => _continue(travellers) : null),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StepHeader(step: 1, total: 3, label: l10n.travelStepTrip),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(l10n.destination),
                for (final zone in widget.options.zones) ...[
                  OptionTile(
                    title: zone.label,
                    subtitle: zone.description,
                    selected: zone.value == _zone.value,
                    onTap: () => _selectZone(zone),
                    trailing: Text(
                      l10n.fromPrice(formatMoney(context, amount(zone.startingPrice))),
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SectionTitle(l10n.tripLength, padding: const EdgeInsets.fromLTRB(0, 14, 0, 10)),
                ChoiceChips<int>(
                  expand: _zone.durations.length <= 4,
                  options: [for (final d in _zone.durations) (d.days, daysLabel(context, d.days))],
                  selected: _days,
                  onSelected: (days) => setState(() => _days = days),
                ),
                const SizedBox(height: 10),
                FieldBox(
                  label: l10n.travelDate,
                  value: formatDate(context, isoDate(_startDate)),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickStartDate,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.coverageEndsOn(formatDate(context, isoDate(_startDate.add(Duration(days: _days - 1))))),
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
                SectionTitle(
                  l10n.travellers,
                  trailing: TextButton(onPressed: () => context.push('/persons/new'), child: Text(l10n.addPerson)),
                ),
                AsyncView(
                  value: persons,
                  onRetry: () => ref.invalidate(personsProvider),
                  builder: (list) => list.isEmpty
                      ? NoticeBanner(tone: StatusTone.info, message: l10n.addTravellersHint)
                      : ListGroup(
                          children: [
                            for (final person in list)
                              CheckRow(
                                title: person.fullName,
                                checked: selectedIds.contains(person.id),
                                trailing: Text(
                                  person.canTravel ? person.relationshipLabel : l10n.passportMissing,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: person.canTravel ? AppColors.muted : AppColors.warning,
                                  ),
                                ),
                                onChanged: (checked) => setState(() {
                                  final ids = {...selectedIds};
                                  checked ? ids.add(person.id) : ids.remove(person.id);
                                  _selected = ids;
                                }),
                              ),
                          ],
                        ),
                ),
                if (missingPassport.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  NoticeBanner(
                    icon: Icons.badge_outlined,
                    message: l10n.passportRequiredFor(missingPassport.map((p) => p.fullName).join('، ')),
                    action: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                      onPressed: () =>
                          context.push('/persons/${missingPassport.first.id}/edit', extra: missingPassport.first),
                      child: Text(l10n.addPassport),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String daysLabel(BuildContext context, int days) => context.l10n.daysCount(days);

String travellersLabel(BuildContext context, int count) => context.l10n.travellersCount(count);
