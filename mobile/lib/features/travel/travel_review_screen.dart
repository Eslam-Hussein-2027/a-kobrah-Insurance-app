import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../policies/policies_repository.dart';
import 'travel_issue_screen.dart';
import 'travel_models.dart';
import 'travel_repository.dart';

/// Travel step 2: summary and price; issuing creates the policy, payment is step 3 on the policy screen.
class TravelReviewScreen extends ConsumerStatefulWidget {
  const TravelReviewScreen({super.key, required this.selection});

  final TravelSelection selection;

  @override
  ConsumerState<TravelReviewScreen> createState() => _TravelReviewScreenState();
}

class _TravelReviewScreenState extends ConsumerState<TravelReviewScreen> {
  bool _issuing = false;

  Future<void> _issue() async {
    final l10n = context.l10n;
    setState(() => _issuing = true);
    try {
      final policy = await ref.read(travelRepositoryProvider).buy(widget.selection);
      ref.invalidate(policiesProvider);
      if (!mounted) return;
      showMessage(context, l10n.policyCreated);
      context.go('/policies/${policy.id}');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selection = widget.selection;
    final total = formatMoney(context, amount(selection.total));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelIssueTitle)),
      bottomNavigationBar: BottomActionBar(
        caption: l10n.total,
        amount: total,
        button: PrimaryButton(label: l10n.issuePolicy, loading: _issuing, onPressed: _issue),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StepHeader(step: 2, total: 3, label: l10n.stepReview),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(l10n.tripDetails),
                SectionCard(
                  child: Column(
                    children: [
                      InfoRow(label: l10n.destination, value: selection.zone.label),
                      InfoRow(label: l10n.tripLength, value: daysLabel(context, selection.duration.days)),
                      InfoRow(label: l10n.startDate, value: formatDate(context, isoDate(selection.startDate))),
                      InfoRow(label: l10n.endDate, value: formatDate(context, isoDate(selection.endDate))),
                    ],
                  ),
                ),
                SectionTitle(l10n.travellers),
                SectionCard(
                  child: Column(
                    children: [
                      for (final person in selection.travellers)
                        InfoRow(label: person.fullName, value: person.passportNo ?? '', ltr: true),
                    ],
                  ),
                ),
                SectionTitle(l10n.priceDetails),
                SectionCard(
                  child: Column(
                    children: [
                      InfoRow(
                        label: l10n.pricePerTraveller,
                        value: formatMoney(context, amount(selection.duration.pricePerTraveller)),
                      ),
                      InfoRow(label: l10n.travellersNumber, value: '× ${selection.travellers.length}'),
                      const Divider(height: 20),
                      InfoRow(label: l10n.total, value: total, emphasize: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.payAfterIssueHint, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
