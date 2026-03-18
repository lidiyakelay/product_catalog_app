import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/product.dart';

class ProductDetailDetailsCard extends StatelessWidget {
  final Product product;

  const ProductDetailDetailsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Details', style: theme.textTheme.titleMedium),
            const Divider(height: 20),
            _DetailRow(label: 'Brand', value: product.brand),
            _DetailRow(label: 'Category', value: product.category),
            _DetailRow(label: 'Stock', value: '${product.stock} units'),
            _DetailRow(
              label: 'Rating',
              value: '${product.rating.toStringAsFixed(1)} / 5.0',
            ),
            if (product.discountPercentage > 0)
              _DetailRow(
                label: 'Discount',
                value: '${product.discountPercentage.toStringAsFixed(0)}%',
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
