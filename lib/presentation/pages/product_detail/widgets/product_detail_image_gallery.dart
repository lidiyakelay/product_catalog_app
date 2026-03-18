import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ProductDetailImageGallery extends StatelessWidget {
  final List<String> images;
  final int productId;
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const ProductDetailImageGallery({
    super.key,
    required this.images,
    required this.productId,
    required this.isDark,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Hero(
                tag: index == 0
                    ? 'product-image-$productId'
                    : 'product-image-$productId-$index',
                child: _NetworkImage(url: images[index], isDark: isDark),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  final bool isDark;

  const _NetworkImage({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F0F0),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F0F0),
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}
