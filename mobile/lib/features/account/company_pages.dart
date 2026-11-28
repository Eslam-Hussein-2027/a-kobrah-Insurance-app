import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_repository.dart';

/// Pages fed by GET /company: branches, contact, about and privacy.

Future<void> _open(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

Uri phoneUri(String phone) => Uri(scheme: 'tel', path: phone);

class _CompanyPage extends ConsumerWidget {
  const _CompanyPage({required this.title, required this.builder});

  final String title;
  final Widget Function(BuildContext context, CompanyInfo company) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncView(
        value: ref.watch(companyProvider),
        onRetry: () => ref.invalidate(companyProvider),
        builder: (company) => builder(context, company),
      ),
    );
  }
}

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CompanyPage(
      title: l10n.branchesAndAgents,
      builder: (context, company) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final branch in company.branches) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const IconBox(Icons.place_outlined, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  branch.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (branch.isHeadOffice) ...[
                                const SizedBox(width: 8),
                                StatusPill(label: l10n.headOffice, tone: StatusTone.info),
                              ],
                            ],
                          ),
                          Text(branch.city, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: l10n.call,
                      onPressed: () => _open(phoneUri(branch.phone)),
                      icon: const Icon(Icons.call_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(l10n.agentsComingSoon, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CompanyPage(
      title: l10n.contactUs,
      builder: (context, company) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(company.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ListGroup(
            children: [
              NavRow(
                icon: Icons.call_outlined,
                title: l10n.customerService,
                value: company.phone,
                valueLtr: true,
                onTap: () => _open(phoneUri(company.phone)),
              ),
              NavRow(
                icon: Icons.language,
                title: l10n.website,
                value: Uri.parse(company.website).host,
                valueLtr: true,
                onTap: () => _open(Uri.parse(company.website)),
              ),
              NavRow(icon: Icons.place_outlined, title: l10n.headOffice, subtitle: company.address),
            ],
          ),
        ],
      ),
    );
  }
}

/// About the company / privacy policy: paragraphs from the server.
class CompanyTextScreen extends StatelessWidget {
  const CompanyTextScreen.about({super.key}) : _privacy = false;

  const CompanyTextScreen.privacy({super.key}) : _privacy = true;

  final bool _privacy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CompanyPage(
      title: _privacy ? l10n.privacy : l10n.aboutCompany,
      builder: (context, company) {
        final paragraphs = _privacy ? company.privacy : company.about;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (!_privacy) ...[const Center(child: AppLogo(height: 56)), const SizedBox(height: 20)],
            for (final paragraph in paragraphs) ...[
              Text(paragraph, style: const TextStyle(fontSize: 15, height: 1.8)),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
