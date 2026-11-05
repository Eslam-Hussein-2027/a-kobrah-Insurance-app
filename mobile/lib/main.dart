import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Network failures are shown with a "retry" button instead of silent automatic retries.
    ProviderScope(retry: (_, _) => null, child: const AkobrahApp()),
  );
}
