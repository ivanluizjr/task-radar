import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: appColors.shimmerBase,
        highlightColor: appColors.shimmerHighlight,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 76,
                  height: 34,
                  decoration: BoxDecoration(
                    color: appColors.shimmerSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                Container(
                  width: 64,
                  height: 34,
                  decoration: BoxDecoration(
                    color: appColors.shimmerSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Center(child: CircleAvatar(radius: 46)),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 130,
                height: 34,
                decoration: BoxDecoration(
                  color: appColors.shimmerSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 220,
                height: 24,
                decoration: BoxDecoration(
                  color: appColors.shimmerSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: appColors.shimmerSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Divider(
              color: appColors.shimmerSurface.withValues(alpha: 0.55),
              thickness: 0.8,
            ),
            const SizedBox(height: 18),
            const _ShimmerField(),
            const SizedBox(height: 18),
            const _ShimmerField(),
            const SizedBox(height: 18),
            const _ShimmerField(),
            const SizedBox(height: 18),
            const _ShimmerField(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerField extends StatelessWidget {
  const _ShimmerField();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 110,
          height: 20,
          decoration: BoxDecoration(
            color: appColors.shimmerSurface,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: appColors.shimmerSurface,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
