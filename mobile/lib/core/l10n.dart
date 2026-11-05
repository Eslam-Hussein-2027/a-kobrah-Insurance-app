import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'api/api_exception.dart';

export '../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// User-facing text for any error. Server messages are already localized (Accept-Language).
String errorMessage(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ApiException) {
    if (error.kind == ApiErrorKind.network) {
      return l10n.networkError;
    }
    return error.message ?? l10n.unexpectedError;
  }
  return l10n.unexpectedError;
}
