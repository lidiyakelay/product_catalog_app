import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceDark : Colors.grey.shade300;
    final highlightColor =
        isDark ? AppColors.outlineDark : Colors.grey.shade100;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SizedBox(
          height: 136,
          child: Row(
            children: [
              Container(width: 136, height: 136, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(height: 16, width: double.infinity),
                      const SizedBox(height: 8),
                      _shimmerBox(height: 12, width: 80),
                      const Spacer(),
                      _shimmerBox(height: 16, width: 100),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _shimmerBox(height: 12, width: 50),
                          const Spacer(),
                          _shimmerBox(height: 16, width: 60),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class ShimmerLoadingList extends StatelessWidget {
  final int itemCount;

  const ShimmerLoadingList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingSm),
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}
