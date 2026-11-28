import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import 'vehicle.dart';
import 'vehicles_repository.dart';

/// Add (vehicle == null) or edit a vehicle: owner details, then registration details.
class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  static const _fields = [
    'owner_name',
    'owner_address',
    'make',
    'model',
    'color',
    'engine_cc',
    'country_of_origin',
    'year',
    'license_purpose',
    'seats',
    'plate_no',
    'vin',
    'licensing_authority',
  ];

  final _formKey = GlobalKey<FormState>();
  late final Vehicle? _vehicle = widget.vehicle;

  late final _ownerName = TextEditingController(
    text: _vehicle?.ownerName ?? (_vehicle == null ? ref.read(authControllerProvider).asData?.value?.name : null),
  );
  late final _ownerAddress = TextEditingController(text: _vehicle?.ownerAddress);
  late final _model = TextEditingController(text: _vehicle?.model);
  late final _engine = TextEditingController(text: _vehicle?.engineCc.toString());
  late final _seats = TextEditingController(text: _vehicle?.seats?.toString());
  late final _plate = TextEditingController(text: _vehicle?.plateNo);
  late final _vin = TextEditingController(text: _vehicle?.vin);

  late String? _make = _vehicle?.make;
  late String? _color = _vehicle?.color?.value;
  late String? _country = _vehicle?.countryOfOrigin?.value;
  late String? _year = _vehicle?.year.toString();
  late String? _purpose = _vehicle?.licensePurpose?.value;
  late String? _authority = _vehicle?.licensingAuthority?.value;

  bool _saving = false;
  Map<String, String?> _errors = const {};

  bool get _editing => _vehicle != null;

  @override
  void dispose() {
    for (final c in [_ownerName, _ownerAddress, _model, _engine, _seats, _plate, _vin]) {
      c.dispose();
    }
    super.dispose();
  }

  int _number(TextEditingController controller) => int.parse(toWesternDigits(controller.text.trim()));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final input = VehicleInput(
      ownerName: _ownerName.text.trim(),
      ownerAddress: _ownerAddress.text.trim(),
      plateNo: toWesternDigits(_plate.text.trim()),
      vin: toWesternDigits(_vin.text.trim()).toUpperCase(),
      make: _make!,
      model: _model.text.trim(),
      year: int.parse(_year!),
      engineCc: _number(_engine),
      color: _color!,
      countryOfOrigin: _country!,
      licensePurpose: _purpose!,
      seats: _number(_seats),
      licensingAuthority: _authority!,
    );

    setState(() {
      _saving = true;
      _errors = const {};
    });

    try {
      final repository = ref.read(vehiclesRepositoryProvider);
      if (_editing) {
        await repository.update(_vehicle!.id, input);
      } else {
        await repository.create(input);
      }
      ref.invalidate(vehiclesProvider);
      if (!mounted) return;
      showMessage(context, _editing ? l10n.vehicleUpdated : l10n.vehicleAdded);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = {for (final f in _fields) f: e.fieldError(f)});
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredText(String? value) => (value == null || value.trim().isEmpty) ? context.l10n.requiredField : null;

  String? _requiredChoice(String? value) => value == null ? context.l10n.requiredField : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = ref.watch(vehicleOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.editVehicle : l10n.addVehicle)),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(
          label: _editing ? l10n.save : l10n.addVehicle,
          loading: _saving,
          onPressed: options.hasValue ? _save : null,
        ),
      ),
      body: AsyncView(
        value: options,
        onRetry: () => ref.invalidate(vehicleOptionsProvider),
        builder: (options) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              NoticeBanner(title: l10n.notice, message: l10n.checkBeforeSending),
              SectionTitle(l10n.insuredDetails),
              _Section(
                children: [
                  _Labeled(
                    label: l10n.ownerName,
                    child: TextFormField(
                      controller: _ownerName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: l10n.ownerNameHint, errorText: _errors['owner_name']),
                      validator: _requiredText,
                    ),
                  ),
                  _Labeled(
                    label: l10n.ownerAddress,
                    child: TextFormField(
                      controller: _ownerAddress,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.ownerAddressHint, errorText: _errors['owner_address']),
                      validator: _requiredText,
                    ),
                  ),
                ],
              ),
              SectionTitle(l10n.vehicleDetails),
              _Section(
                children: [
                  _Labeled(
                    label: l10n.make,
                    child: ChoiceField(
                      key: const ValueKey('make'),
                      title: l10n.make,
                      options: options.makes,
                      value: _make,
                      allowCustom: true,
                      errorText: _errors['make'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _make = v),
                    ),
                  ),
                  _Labeled(
                    label: l10n.model,
                    child: TextFormField(
                      controller: _model,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(hintText: 'Corolla', errorText: _errors['model']),
                      validator: _requiredText,
                    ),
                  ),
                  _Labeled(
                    label: l10n.vehicleColor,
                    child: ChoiceField(
                      key: const ValueKey('color'),
                      title: l10n.vehicleColor,
                      options: options.colors,
                      value: _color,
                      errorText: _errors['color'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _color = v),
                    ),
                  ),
                  _Labeled(
                    label: l10n.engineCc,
                    child: _NumberField(
                      controller: _engine,
                      maxLength: 5,
                      hint: '1600',
                      suffix: l10n.ccUnit,
                      errorText: _errors['engine_cc'],
                      validator: _requiredText,
                    ),
                  ),
                  _Labeled(
                    label: l10n.countryOfOrigin,
                    child: ChoiceField(
                      key: const ValueKey('country_of_origin'),
                      title: l10n.countryOfOrigin,
                      options: options.countries,
                      value: _country,
                      errorText: _errors['country_of_origin'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _country = v),
                    ),
                  ),
                  _Labeled(
                    label: l10n.year,
                    child: ChoiceField(
                      key: const ValueKey('year'),
                      title: l10n.year,
                      options: options.years,
                      value: _year,
                      hint: l10n.tapToChooseYear,
                      ltrLabels: true,
                      errorText: _errors['year'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _year = v),
                    ),
                  ),
                  _Labeled(
                    label: l10n.licensePurpose,
                    child: ChoiceField(
                      key: const ValueKey('license_purpose'),
                      title: l10n.licensePurpose,
                      options: options.licensePurposes,
                      value: _purpose,
                      errorText: _errors['license_purpose'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _purpose = v),
                    ),
                  ),
                  _Labeled(
                    label: l10n.seats,
                    child: _NumberField(
                      controller: _seats,
                      maxLength: 2,
                      hint: '5',
                      errorText: _errors['seats'],
                      validator: (value) {
                        final missing = _requiredText(value);
                        if (missing != null) return missing;
                        final seats = int.parse(toWesternDigits(value!.trim()));
                        return seats < options.minSeats || seats > options.maxSeats
                            ? l10n.numberBetween(options.minSeats, options.maxSeats)
                            : null;
                      },
                    ),
                  ),
                  _Labeled(
                    label: l10n.metalPlate,
                    child: TextFormField(
                      controller: _plate,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(hintText: l10n.plateHint, errorText: _errors['plate_no']),
                      validator: _requiredText,
                    ),
                  ),
                  _Labeled(
                    label: l10n.vin,
                    child: TextFormField(
                      controller: _vin,
                      textDirection: TextDirection.ltr,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 17,
                      decoration: InputDecoration(
                        hintText: l10n.vinHint,
                        counterText: '',
                        errorText: _errors['vin'],
                        errorMaxLines: 3,
                      ),
                      validator: _requiredText,
                    ),
                  ),
                  _Labeled(
                    label: l10n.licensingAuthority,
                    child: ChoiceField(
                      key: const ValueKey('licensing_authority'),
                      title: l10n.licensingAuthority,
                      options: options.licensingAuthorities,
                      value: _authority,
                      errorText: _errors['licensing_authority'],
                      validator: _requiredChoice,
                      onChanged: (v) => setState(() => _authority = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White card holding a group of fields.
class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// Field with its label above and a red asterisk (every field here is required).
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.danger),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.maxLength,
    required this.validator,
    this.hint,
    this.suffix,
    this.errorText,
  });

  final TextEditingController controller;
  final int maxLength;
  final FormFieldValidator<String> validator;
  final String? hint;
  final String? suffix;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      maxLength: maxLength,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]'))],
      decoration: InputDecoration(hintText: hint, suffixText: suffix, counterText: '', errorText: errorText),
      validator: validator,
    );
  }
}
