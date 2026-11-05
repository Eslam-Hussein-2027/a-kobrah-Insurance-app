import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../shared/widgets.dart';
import 'vehicle.dart';
import 'vehicles_repository.dart';

/// Add (vehicle == null) or edit a vehicle.
class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _plate = TextEditingController(text: widget.vehicle?.plateNo);
  late final _vin = TextEditingController(text: widget.vehicle?.vin);
  late final _make = TextEditingController(text: widget.vehicle?.make);
  late final _model = TextEditingController(text: widget.vehicle?.model);
  late final _year = TextEditingController(text: widget.vehicle?.year.toString());
  late final _engine = TextEditingController(text: widget.vehicle?.engineCc.toString());
  bool _saving = false;
  Map<String, String?> _errors = const {};

  bool get _editing => widget.vehicle != null;

  @override
  void dispose() {
    for (final c in [_plate, _vin, _make, _model, _year, _engine]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final input = VehicleInput(
      plateNo: toWesternDigits(_plate.text.trim()),
      vin: toWesternDigits(_vin.text.trim()).toUpperCase(),
      make: _make.text.trim(),
      model: _model.text.trim(),
      year: int.parse(toWesternDigits(_year.text.trim())),
      engineCc: int.parse(toWesternDigits(_engine.text.trim())),
    );

    setState(() {
      _saving = true;
      _errors = const {};
    });

    try {
      final repository = ref.read(vehiclesRepositoryProvider);
      if (_editing) {
        await repository.update(widget.vehicle!.id, input);
      } else {
        await repository.create(input);
      }
      ref.invalidate(vehiclesProvider);
      if (!mounted) return;
      showMessage(context, _editing ? l10n.vehicleUpdated : l10n.vehicleAdded);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _errors = {
          for (final f in ['plate_no', 'vin', 'make', 'model', 'year', 'engine_cc']) f: e.fieldError(f),
        },
      );
      if (e.fieldErrors.isEmpty) showMessage(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty) ? context.l10n.requiredField : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digitsOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]'))];

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.editVehicle : l10n.addVehicle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_plate, l10n.plateNo, 'plate_no', icon: Icons.pin_outlined, hint: l10n.plateHint, ltr: true),
              _field(
                _vin,
                l10n.vin,
                'vin',
                icon: Icons.qr_code_2,
                hint: l10n.vinHint,
                ltr: true,
                maxLength: 17,
                capitalization: TextCapitalization.characters,
              ),
              _field(_make, l10n.make, 'make', icon: Icons.factory_outlined, hint: 'Toyota'),
              _field(_model, l10n.model, 'model', icon: Icons.directions_car_outlined, hint: 'Corolla'),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _year,
                      l10n.year,
                      'year',
                      icon: Icons.event_outlined,
                      numeric: true,
                      formatters: digitsOnly,
                      maxLength: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _engine,
                      l10n.engineCc,
                      'engine_cc',
                      suffix: l10n.ccUnit,
                      icon: Icons.speed_outlined,
                      numeric: true,
                      formatters: digitsOnly,
                      maxLength: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: l10n.save, loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String key, {
    required IconData icon,
    String? hint,
    bool ltr = false,
    bool numeric = false,
    int? maxLength,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        textDirection: ltr || numeric ? TextDirection.ltr : null,
        textCapitalization: capitalization,
        inputFormatters: formatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          counterText: '',
          suffixText: suffix,
          errorText: _errors[key],
          errorMaxLines: 3,
        ),
        validator: _required,
      ),
    );
  }
}
