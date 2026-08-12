import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D2D3F) : AppTheme.grey200,
      highlightColor: isDark ? const Color(0xFF3D3D5C) : AppTheme.grey100,
      child: Container(
        width: width,
        height: height ?? 80,
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const ShimmerList({super.key, this.count = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: ShimmerLoading(height: itemHeight),
      ),
    );
  }
}

class ShimmerTutorCard extends StatelessWidget {
  const ShimmerTutorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D2D3F) : AppTheme.grey200,
      highlightColor: isDark ? const Color(0xFF3D3D5C) : AppTheme.grey100,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}