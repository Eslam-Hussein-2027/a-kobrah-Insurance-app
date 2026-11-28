import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../auth/auth_controller.dart';
import '../auth/models.dart';

/// "My account": profile card, company shortcuts, account pages and settings.
class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

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

    return Column(
      children: [
        _TitleBar(l10n.tabAccount),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              if (user != null) _ProfileCard(user),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Shortcut(
                    icon: Icons.assignment_outlined,
                    color: _ShortcutColors.rose,
                    label: l10n.privacy,
                    route: '/account/privacy',
                  ),
                  const SizedBox(width: 12),
                  _Shortcut(
                    icon: Icons.headset_mic_outlined,
                    color: _ShortcutColors.amber,
                    label: l10n.contactUs,
                    route: '/account/contact',
                  ),
                  const SizedBox(width: 12),
                  _Shortcut(
                    // Material's umbrella is folded; the beach umbrella stood upright reads as an open one.
                    icon: Icons.beach_access_outlined,
                    iconAngle: math.pi / 4,
                    color: _ShortcutColors.sky,
                    label: l10n.aboutCompany,
                    route: '/account/about',
                  ),
                ],
              ),
              SectionTitle(l10n.account),
              ListGroup(
                children: [
                  NavRow(
                    icon: Icons.location_on_outlined,
                    roundIcon: true,
                    title: l10n.branchesAndAgents,
                    onTap: () => context.push('/account/branches'),
                  ),
                  NavRow(
                    icon: Icons.person_outline,
                    roundIcon: true,
                    title: l10n.personalInfo,
                    subtitle: user != null && !user.kycCompleted ? l10n.documentsMissing : null,
                    onTap: () => context.push('/account/profile'),
                  ),
                ],
              ),
              SectionTitle(l10n.settings),
              ListGroup(
                children: [
                  NavRow(
                    icon: Icons.grid_view_outlined,
                    roundIcon: true,
                    title: l10n.appVersion,
                    value: AppConfig.appVersion,
                    valueLtr: true,
                    valueColor: AppColors.blue,
                  ),
                  NavRow(
                    icon: Icons.info_outline,
                    roundIcon: true,
                    title: l10n.aboutApp,
                    onTap: () => context.push('/account/about-app'),
                  ),
                  const _LanguageRow(),
                  NavRow(
                    icon: Icons.qr_code_scanner,
                    roundIcon: true,
                    title: l10n.verifyPolicyLink,
                    onTap: () => context.push('/verify'),
                  ),
                  NavRow(
                    icon: Icons.logout,
                    roundIcon: true,
                    title: l10n.logout,
                    destructive: true,
                    onTap: () => _logout(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navy),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard(this.user);

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().characters.firstOrNull ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.navyTint,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [BoxShadow(color: Color(0x1A14178F), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Text(
              initial,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            user.phone,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Soft background + icon colour for the three shortcut tiles.
enum _ShortcutColors {
  rose(Color(0xFFFCE9E9), Color(0xFFD64545)),
  amber(Color(0xFFFDF4D9), Color(0xFFCC9A06)),
  sky(Color(0xFFE6F1FB), AppColors.blue);

  const _ShortcutColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.color,
    required this.label,
    required this.route,
    this.iconAngle = 0,
  });

  final IconData icon;
  final double iconAngle;
  final _ShortcutColors color;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: color.background, shape: BoxShape.circle),
                  child: Transform.rotate(
                    angle: iconAngle,
                    child: Icon(icon, size: 26, color: color.foreground),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3D4155)),
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
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.neutralTint, shape: BoxShape.circle),
            child: const Icon(Icons.language, size: 21, color: AppColors.ink),
          ),
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
