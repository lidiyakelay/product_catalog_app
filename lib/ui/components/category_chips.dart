import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelected,
  });

  String _formatCategoryName(String slug) {
    return slug
        .split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return FilterChip(
            label: Text(_formatCategoryName(category)),
            selected: selectedCategory == category,
            onSelected: (_) {
              onSelected(selectedCategory == category ? null : category);
            },
          );
        },
      ),
    );
  }
}
