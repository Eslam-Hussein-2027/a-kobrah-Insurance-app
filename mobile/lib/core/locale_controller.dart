import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

/// App language: Arabic by default, English optional. Persisted on the device.
class LocaleController extends Notifier<Locale> {
  static const _key = 'locale';

  @override
  Locale build() {
    _restore();
    return const Locale('ar');
  }

  Future<void> _restore() async {
    final saved = await ref.read(keyValueStoreProvider).read(_key);
    if (saved != null && saved != state.languageCode) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(keyValueStoreProvider).write(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
