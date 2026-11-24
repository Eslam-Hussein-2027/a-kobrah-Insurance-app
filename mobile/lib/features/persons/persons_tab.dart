import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'person.dart';
import 'persons_repository.dart';

class PersonsTab extends ConsumerWidget {
  const PersonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(personsProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.tabPersons, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), foregroundColor: AppColors.navy),
                  onPressed: () => context.push('/persons/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.add),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.personsHint, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 14),
            AsyncView(
              value: ref.watch(personsProvider),
              onRetry: () => ref.invalidate(personsProvider),
              builder: (persons) => persons.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: EmptyView(icon: Icons.group_outlined, title: l10n.noPersons, subtitle: l10n.noPersonsHint),
                    )
                  : ListGroup(children: [for (final person in persons) _PersonRow(person: person)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = [
      l10n.bornOn(formatDate(context, person.birthDate)),
      if (person.passportNo != null) l10n.passportShort(maskDocumentNumber(person.passportNo!)),
    ].join(' · ');

    return InkWell(
      onTap: () => context.push('/persons/${person.id}/edit', extra: person),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.navyTint,
              child: Text(
                person.fullName.characters.first,
                style: const TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(person.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: person.relationshipLabel, tone: StatusTone.neutral),
                    ],
                  ),
                  Text(details, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  if (!person.canTravel)
                    Text(l10n.passportMissing, style: const TextStyle(fontSize: 12, color: AppColors.warning)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.subtle, size: 20),
          ],
        ),
      ),
    );
  }
}
