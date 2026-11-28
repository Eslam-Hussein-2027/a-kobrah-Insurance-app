import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

/// What the app does, its version, and a link to the privacy notice.
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (Icons.bolt_outlined, l10n.aboutAppFeatureIssue),
      (Icons.account_balance_wallet_outlined, l10n.aboutAppFeaturePay),
      (Icons.qr_code_2, l10n.aboutAppFeatureVerify),
      (Icons.support_agent_outlined, l10n.aboutAppFeatureSupport),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          const Center(child: AppLogo(height: 72)),
          const SizedBox(height: 14),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            '${l10n.appVersion} ${AppConfig.appVersion}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Text(l10n.aboutAppBody, style: const TextStyle(fontSize: 15, height: 1.7)),
          const SizedBox(height: 16),
          ListGroup(
            children: [
              for (final (icon, text) in features)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(icon, size: 22, color: AppColors.navy),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5))),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ListGroup(
            children: [
              NavRow(
                icon: Icons.assignment_outlined,
                title: l10n.privacy,
                onTap: () => context.push('/account/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aboutAppCopyright(DateTime.now().year),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}
