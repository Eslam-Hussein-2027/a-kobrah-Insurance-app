import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/image_picking.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_repository.dart';
import '../vehicles/vehicles_repository.dart';
import 'request_models.dart';
import 'requests_repository.dart';

/// Issue / price request for a staff-handled product. The form is built from the product's
/// field definitions (GET /products), so new questions need no app update.
class RequestFormScreen extends ConsumerWidget {
  const RequestFormScreen({super.key, required this.productCode, required this.kind});

  final String productCode;
  final RequestKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(productProvider(productCode)),
      onRetry: () => ref.invalidate(productsProvider),
      builder: (product) => product == null
          ? Scaffold(
              appBar: AppBar(),
              body: ErrorView(message: context.l10n.unexpectedError),
            )
          : _RequestForm(product: product, kind: kind),
    );
  }
}

class _RequestForm extends ConsumerStatefulWidget {
  const _RequestForm({required this.product, required this.kind});

  final Product product;
  final RequestKind kind;

  @override
  ConsumerState<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<_RequestForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _text = {
    for (final field in widget.product.fields)
      if (_isTyped(field)) field.key: TextEditingController(),
  };
  final _notes = TextEditingController();

  /// Dates and vehicles chosen with pickers.
  final Map<String, String> _picked = {};
  final Map<String, XFile> _documents = {};
  bool _sending = false;
  bool _submitted = false;
  Map<String, String?> _errors = const {};

  static bool _isTyped(ProductField field) =>
      field.type != ProductFieldType.date && field.type != ProductFieldType.vehicle;

  @override
  void dispose() {
    for (final controller in [..._text.values, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _answers() => {
    for (final entry in _text.entries)
      if (entry.value.text.trim().isNotEmpty) entry.key: toWesternDigits(entry.value.text.trim()),
    ..._picked,
  };

  bool _missingPicks() =>
      widget.product.fields.any((field) => field.required && !_isTyped(field) && !_picked.containsKey(field.key));

  Future<void> _attach(ProductDocument document) async {
    final file = await pickDocumentImage(context);
    if (file != null) setState(() => _documents[document.key] = file);
  }

  Future<void> _pickDate(ProductField field) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _picked[field.key] = isoDate(picked));
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final valid = _formKey.currentState!.validate();
    if (!valid || _missingPicks()) {
      setState(() => _submitted = true);
      return;
    }

    setState(() {
      _sending = true;
      _errors = const {};
    });

    try {
      final request = await ref
          .read(requestsRepositoryProvider)
          .submit(
            product: widget.product.code,
            kind: widget.kind,
            answers: _answers(),
            notes: _notes.text.trim(),
            documents: _documents,
          );
      ref.invalidate(requestsProvider);
      if (!mounted) return;
      showMessage(context, l10n.requestSent);
      context.pushReplacement('/requests/${request.id}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _errors = {for (final field in widget.product.fields) field.key: e.fieldError('answers.${field.key}')},
      );
      if (e.fieldErrors.isEmpty || _errors.values.every((error) => error == null)) {
        showMessage(context, errorMessage(context, e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = widget.product;
    final phone = ref.watch(authControllerProvider).asData?.value?.phone ?? '';

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomActionBar(
        button: PrimaryButton(label: l10n.sendRequest, loading: _sending, onPressed: _send),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(product.title, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            Text(
              widget.kind == RequestKind.quote ? l10n.requestQuote : l10n.requestPolicy,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            for (final field in product.fields) ...[const SizedBox(height: 14), _buildField(field)],
            const SizedBox(height: 14),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(labelText: '${l10n.notes} (${l10n.optional})', alignLabelWithHint: true),
            ),
            if (product.documents.isNotEmpty) ...[
              SectionTitle(l10n.documents, padding: const EdgeInsets.fromLTRB(0, 8, 0, 10)),
              ListGroup(children: [for (final document in product.documents) _documentRow(document)]),
              const SizedBox(height: 6),
              Text(l10n.documentsLaterHint, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
            const SizedBox(height: 16),
            NoticeBanner(tone: StatusTone.info, icon: Icons.support_agent, message: l10n.requestContactHint(phone)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(ProductField field) {
    final l10n = context.l10n;
    final label = field.required ? field.label : '${field.label} (${l10n.optional})';
    final missing = _submitted && field.required && !_picked.containsKey(field.key);

    switch (field.type) {
      case ProductFieldType.date:
        final value = _picked[field.key];
        return _withError(
          FieldBox(
            label: label,
            value: value == null ? l10n.choose : formatDate(context, value),
            icon: Icons.calendar_today_outlined,
            onTap: () => _pickDate(field),
          ),
          _errors[field.key] ?? (missing ? l10n.requiredField : null),
        );
      case ProductFieldType.vehicle:
        final vehicles = ref.watch(vehiclesProvider).asData?.value ?? const [];
        return DropdownButtonFormField<String>(
          initialValue: _picked[field.key],
          decoration: InputDecoration(
            labelText: label,
            errorText: _errors[field.key] ?? (missing ? l10n.requiredField : null),
            helperText: vehicles.isEmpty ? l10n.addVehicleFirst : null,
          ),
          items: [
            for (final vehicle in vehicles)
              DropdownMenuItem(
                value: vehicle.id.toString(),
                child: Text('${vehicle.title} ${vehicle.year} · ${vehicle.plateNo}'),
              ),
          ],
          onChanged: (value) => setState(() {
            if (value != null) _picked[field.key] = value;
          }),
        );
      case ProductFieldType.integer || ProductFieldType.number || ProductFieldType.text:
        final numeric = field.type != ProductFieldType.text;
        return TextFormField(
          controller: _text[field.key],
          keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: numeric ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.]'))] : null,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: label, errorText: _errors[field.key]),
          validator: (value) => field.required && (value == null || value.trim().isEmpty) ? l10n.requiredField : null,
        );
    }
  }

  Widget _withError(Widget child, String? error) {
    if (error == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
          child: Text(error, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _documentRow(ProductDocument document) {
    final l10n = context.l10n;
    final attached = _documents.containsKey(document.key);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            attached ? Icons.check_circle : Icons.attach_file,
            size: 20,
            color: attached ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(document.label, style: const TextStyle(fontSize: 14))),
          TextButton(onPressed: () => _attach(document), child: Text(attached ? l10n.replace : l10n.attach)),
        ],
      ),
    );
  }
}
