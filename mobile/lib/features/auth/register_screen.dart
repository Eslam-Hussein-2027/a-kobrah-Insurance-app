import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/text_input.dart';
import '../../core/theme.dart';
import '../../shared/image_picking.dart';
import '../../shared/widgets.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.registrationToken});

  final String registrationToken;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  XFile? _idImage;
  XFile? _licenseImage;
  bool _loading = false;
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    _name.dispose();
    _nationalId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _errors = const {};
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            registrationToken: widget.registrationToken,
            name: _name.text.trim(),
            nationalId: toWesternDigits(_nationalId.text.trim()),
            idImage: _idImage,
            licenseImage: _licenseImage,
          );
      // Signed in: the router redirects to the home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.fieldError('registration_token') != null) {
        showMessage(context, context.l10n.registrationExpired, isError: true);
        context.go('/login');
        return;
      }
      setState(
        () => _errors = {
          'name': e.fieldError('name'),
          'national_id': e.fieldError('national_id'),
          'id_image': e.fieldError('id_image'),
          'license_image': e.fieldError('license_image'),
        },
      );
      if (e.fieldErrors.isEmpty) {
        showMessage(context, errorMessage(context, e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (widget.registrationToken.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(message: l10n.registrationExpired, onRetry: () => context.go('/login')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.registerSubtitle, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: _errors['name'],
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nationalId,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      maxLength: 12,
                      decoration: InputDecoration(
                        labelText: l10n.nationalNumber,
                        prefixIcon: const Icon(Icons.badge_outlined),
                        errorText: _errors['national_id'],
                        errorMaxLines: 3,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.documentsOptionalHint,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    _ImageField(
                      label: l10n.idImage,
                      file: _idImage,
                      error: _errors['id_image'],
                      onPick: () async {
                        final file = await pickDocumentImage(context);
                        if (file != null) setState(() => _idImage = file);
                      },
                    ),
                    const SizedBox(height: 10),
                    _ImageField(
                      label: l10n.licenseImage,
                      file: _licenseImage,
                      error: _errors['license_image'],
                      onPick: () async {
                        final file = await pickDocumentImage(context);
                        if (file != null) setState(() => _licenseImage = file);
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(label: l10n.createAccount, loading: _loading, onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageField extends StatelessWidget {
  const _ImageField({required this.label, required this.file, required this.onPick, this.error});

  final String label;
  final XFile? file;
  final VoidCallback onPick;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final selected = file != null;
    return Card(
      child: ListTile(
        leading: Icon(
          selected ? Icons.check_circle : Icons.image_outlined,
          color: selected ? AppColors.success : AppColors.muted,
        ),
        title: Text(label),
        subtitle: error != null
            ? Text(error!, style: const TextStyle(color: AppColors.danger))
            : selected
            ? Text(context.l10n.imageSelected)
            : null,
        trailing: TextButton(onPressed: onPick, child: Text(context.l10n.chooseImage)),
      ),
    );
  }
}
