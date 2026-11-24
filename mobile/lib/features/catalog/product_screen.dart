import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'catalog_models.dart';
import 'catalog_repository.dart';
import 'product_icon.dart';

/// One product: what it covers, required documents, and the two entry points
/// ("issue a policy" / "know the price"). Request-based products open the request form instead.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: AsyncView(
        value: ref.watch(productProvider(code)),
        onRetry: () => ref.invalidate(productsProvider),
        builder: (product) =>
            product == null ? ErrorView(message: context.l10n.unexpectedError) : _ProductBody(product: product),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({required this.product});

  final Product product;

  /// Where the two actions lead for this product.
  ({String issue, String price}) _routes() => switch (product.code) {
    Product.motor => (issue: '/motor/issue', price: '/motor/estimate'),
    Product.travel => (issue: '/travel/issue', price: '/travel/estimate'),
    _ => (
      issue: '/requests/new?product=${product.code}&kind=issue',
      price: '/requests/new?product=${product.code}&kind=quote',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final routes = _routes();
    final instant = product.isInstant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBox(productIcon(product.icon), size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(product.description, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StatusPill(
            label: instant ? l10n.issuedInstantly : l10n.issuedAfterReview,
            tone: instant ? StatusTone.success : StatusTone.neutral,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.note_add_outlined,
                filled: true,
                title: instant ? l10n.issuePolicy : l10n.requestPolicy,
                subtitle: instant ? l10n.issuePolicyHint : l10n.requestPolicyHint,
                onTap: () => context.push(routes.issue),
              ),
              const Divider(),
              _ActionRow(
                icon: Icons.calculate_outlined,
                title: instant ? l10n.knowThePrice : l10n.requestQuote,
                subtitle: instant ? l10n.knowThePriceHint : l10n.requestQuoteHint,
                onTap: () => context.push(routes.price),
              ),
            ],
          ),
        ),
        SectionTitle(l10n.whatIsCovered),
        for (final cover in product.covers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check, size: 18, color: AppColors.success),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(cover, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        if (product.documents.isNotEmpty) ...[
          SectionTitle(l10n.requiredDocuments, padding: const EdgeInsets.fromLTRB(0, 16, 0, 10)),
          ListGroup(
            children: [
              for (final document in product.documents) NavRow(icon: Icons.description_outlined, title: document.label),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Text('${l10n.haveAQuestion} ', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const Text(
              AppConfig.customerServicePhone,
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: filled ? AppColors.navy : AppColors.navyTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: filled ? Colors.white : AppColors.navy, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}
