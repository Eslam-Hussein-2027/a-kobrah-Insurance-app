import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';

/// Account, company information and settings.
class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.logout,
      message: l10n.logoutConfirm,
      confirmLabel: l10n.logout,
      destructive: true,
    );
    if (confirmed) await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).asData?.value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          if (user != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    user.name.characters.first,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        user.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Shortcut(icon: Icons.privacy_tip_outlined, label: l10n.privacy, route: '/more/privacy'),
              const SizedBox(width: 10),
              _Shortcut(icon: Icons.headset_mic_outlined, label: l10n.contactUs, route: '/more/contact'),
              const SizedBox(width: 10),
              _Shortcut(icon: Icons.apartment_outlined, label: l10n.aboutCompany, route: '/more/about'),
            ],
          ),
          SectionTitle(l10n.account),
          ListGroup(
            children: [
              NavRow(
                icon: Icons.person_outline,
                title: l10n.personalInfo,
                subtitle: user != null && !user.kycCompleted ? l10n.documentsMissing : null,
                onTap: () => context.push('/more/profile'),
              ),
              NavRow(
                icon: Icons.place_outlined,
                title: l10n.branchesAndAgents,
                onTap: () => context.push('/more/branches'),
              ),
            ],
          ),
          SectionTitle(l10n.settings),
          ListGroup(
            children: [
              const _LanguageRow(),
              NavRow(
                icon: Icons.verified_user_outlined,
                title: l10n.verifyPolicyLink,
                onTap: () => context.push('/verify'),
              ),
              NavRow(icon: Icons.info_outline, title: l10n.appVersion, value: AppConfig.appVersion, valueLtr: true),
              NavRow(icon: Icons.logout, title: l10n.logout, destructive: true, onTap: () => _logout(context, ref)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
            child: Column(
              children: [
                Icon(icon, color: AppColors.navy),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppColors.navy, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.language, style: const TextStyle(fontSize: 15))),
          SegmentedButton<String>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: 'ar', label: Text('العربية')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) => ref.read(localeProvider.notifier).setLocale(Locale(selection.first)),
          ),
        ],
      ),
    );
  }
}
