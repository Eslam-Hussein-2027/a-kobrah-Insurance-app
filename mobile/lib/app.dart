import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n.dart';
import 'core/locale_controller.dart';
import 'core/router.dart';
import 'core/theme.dart';

class AkobrahApp extends ConsumerWidget {
  const AkobrahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Arabic (RTL) first; the layout direction follows the locale automatically.
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
    );
  }
}
