import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/image_picking.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../auth/models.dart';

/// Account details and the KYC documents required before issuing a motor policy.
class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.personalInfo)),
      body: user == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: () => ref.read(authControllerProvider.notifier).refreshUser(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _UserCard(user: user),
                  const SizedBox(height: 12),
                  _DocumentsCard(user: user),
                ],
              ),
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.navy,
                child: Text(
                  user.name.characters.first,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(height: 24),
          InfoRow(label: l10n.phoneLabel, value: user.phone, ltr: true),
          if (user.nationalId != null) InfoRow(label: l10n.nationalNumber, value: user.nationalId!, ltr: true),
        ],
      ),
    );
  }
}

class _DocumentsCard extends ConsumerStatefulWidget {
  const _DocumentsCard({required this.user});

  final AppUser user;

  @override
  ConsumerState<_DocumentsCard> createState() => _DocumentsCardState();
}

class _DocumentsCardState extends ConsumerState<_DocumentsCard> {
  String? _uploading;

  Future<void> _upload(String field) async {
    final l10n = context.l10n;
    final file = await pickDocumentImage(context);
    if (file == null || !mounted) return;

    setState(() => _uploading = field);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .uploadDocuments(
            idImage: field == 'id_image' ? file : null,
            licenseImage: field == 'license_image' ? file : null,
          );
      if (mounted) showMessage(context, l10n.documentUploaded);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.fieldError(field) ?? errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCard(
      title: l10n.documents,
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Column(
        children: [
          _row(l10n.idImage, 'id_image', widget.user.idImage),
          _row(l10n.licenseImage, 'license_image', widget.user.licenseImage),
        ],
      ),
    );
  }

  Widget _row(String label, String field, DocumentStatus status) {
    final l10n = context.l10n;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        status.uploaded ? Icons.check_circle : Icons.error_outline,
        color: status.uploaded ? AppColors.success : AppColors.warning,
      ),
      title: Text(label),
      subtitle: Text(status.uploaded ? l10n.uploaded : l10n.notUploaded),
      trailing: _uploading == field
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4))
          : TextButton(
              onPressed: _uploading == null ? () => _upload(field) : null,
              child: Text(status.uploaded ? l10n.replace : l10n.upload),
            ),
    );
  }
}
