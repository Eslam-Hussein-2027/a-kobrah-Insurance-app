import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'person.dart';
import 'persons_repository.dart';

/// Add (person == null) or edit an insured person.
class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.person});

  final Person? person;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  static const _fields = ['full_name', 'relationship', 'birth_date', 'passport_no', 'national_id'];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.person?.fullName);
  late final _passport = TextEditingController(text: widget.person?.passportNo);
  late final _nationalId = TextEditingController(text: widget.person?.nationalId);
  late Relationship? _relationship = widget.person?.relationship;
  late DateTime? _birthDate = widget.person == null ? null : DateTime.tryParse(widget.person!.birthDate);
  bool _saving = false;

  /// Set on the first save attempt, to show "required" under the date and relationship.
  bool _submitted = false;
  Map<String, String?> _errors = const {};

  bool get _editing => widget.person != null;

  @override
  void dispose() {
    for (final controller in [_name, _passport, _nationalId]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(today.year - 30),
      firstDate: DateTime(1900),
      lastDate: today,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String? _optional(TextEditingController controller) {
    final value = toWesternDigits(controller.text.trim()).replaceAll(' ', '').toUpperCase();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _relationship == null || _birthDate == null) {
      setState(() => _submitted = true);
      return;
    }

    setState(() {
      _saving = true;
      _errors = const {};
    });

    final input = PersonInput(
      fullName: _name.text.trim(),
      relationship: _relationship!,
      birthDate: isoDate(_birthDate!),
      passportNo: _optional(_passport),
      nationalId: _optional(_nationalId),
    );

    try {
      final repository = ref.read(personsRepositoryProvider);
      _editing ? await repository.update(widget.person!.id, input) : await repository.create(input);
      ref.invalidate(personsProvider);
      if (!mounted) return;
      showMessage(context, _editing ? l10n.personUpdated : l10n.personAdded);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = {for (final field in _fields) field: e.fieldError(field)});
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.deletePerson,
      message: l10n.deletePersonConfirm(widget.person!.fullName),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(personsRepositoryProvider).delete(widget.person!.id);
      ref.invalidate(personsProvider);
      if (!mounted) return;
      showMessage(context, l10n.personDeleted);
      context.pop();
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorMessage(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final submitted = _submitted;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.editPerson : l10n.addPerson),
        actions: [
          if (_editing)
            IconButton(
              tooltip: l10n.delete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(label: l10n.save, loading: _saving, onPressed: _save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.fullName, errorText: _errors['full_name']),
              validator: (value) => (value == null || value.trim().length < 3) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<Relationship>(
              initialValue: _relationship,
              decoration: InputDecoration(
                labelText: l10n.relationship,
                errorText: _errors['relationship'] ?? (submitted && _relationship == null ? l10n.requiredField : null),
              ),
              items: [
                for (final relationship in Relationship.values)
                  DropdownMenuItem(value: relationship, child: Text(relationshipLabel(context, relationship))),
              ],
              onChanged: (value) => setState(() => _relationship = value),
            ),
            const SizedBox(height: 14),
            FieldBox(
              label: l10n.birthDate,
              value: _birthDate == null ? l10n.choose : formatDate(context, isoDate(_birthDate!)),
              icon: Icons.calendar_today_outlined,
              onTap: _pickBirthDate,
            ),
            if (_errors['birth_date'] != null || (submitted && _birthDate == null))
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
                child: Text(
                  _errors['birth_date'] ?? l10n.requiredField,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passport,
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.passportNo,
                helperText: l10n.passportNeededForTravel,
                errorText: _errors['passport_no'],
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nationalId,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.number,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
              decoration: InputDecoration(
                labelText: '${l10n.nationalNumber} (${l10n.optional})',
                errorText: _errors['national_id'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String relationshipLabel(BuildContext context, Relationship relationship) {
  final l10n = context.l10n;
  return switch (relationship) {
    Relationship.self => l10n.relationshipSelf,
    Relationship.spouse => l10n.relationshipSpouse,
    Relationship.child => l10n.relationshipChild,
    Relationship.parent => l10n.relationshipParent,
    Relationship.sibling => l10n.relationshipSibling,
    Relationship.other => l10n.relationshipOther,
  };
}
