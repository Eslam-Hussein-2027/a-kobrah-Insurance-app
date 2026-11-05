import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png', height: height, fit: BoxFit.contain);
  }
}

/// Loading / error / data for an [AsyncValue]. Keeps showing stale data while refreshing.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) {
      return builder(value.requireValue);
    }
    if (value.hasError) {
      return ErrorView(message: errorMessage(context, value.error!), onRetry: onRetry);
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(context.l10n.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.title, this.subtitle, this.action});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.blue.withValues(alpha: 0.1),
              child: Icon(icon, size: 40, color: AppColors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Text(label);

    if (icon != null && !loading) {
      return FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child);
    }
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}

/// Label on the start, value on the end. Latin/numeric values are forced LTR so
/// dates and numbers are never reordered inside Arabic text.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.ltr = false, this.emphasize = false});

  final String label;
  final String value;
  final bool ltr;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              textDirection: ltr ? TextDirection.ltr : null,
              style: (emphasize ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge)?.copyWith(
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
                color: emphasize ? AppColors.navy : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.title, this.padding = const EdgeInsets.all(16)});

  final String? title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : AppColors.navy));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.l10n.cancel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: const Size(96, 44))
              : FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// "1452.00 دينار ليبي"
String formatMoney(BuildContext context, String amount) => '$amount ${context.l10n.currency}';
