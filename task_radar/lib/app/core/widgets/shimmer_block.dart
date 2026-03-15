import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';

class ShimmerBlock extends StatelessWidget {
  final double height;

  const ShimmerBlock({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return Shimmer.fromColors(
      baseColor: appColors.shimmerBase,
      highlightColor: appColors.shimmerHighlight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: appColors.shimmerSurface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
