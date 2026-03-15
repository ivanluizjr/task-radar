import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
import 'package:task_radar/app/core/widgets/app_state_widgets.dart';
import 'package:task_radar/app/core/widgets/shimmer_block.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';

class DashboardTasksCard extends StatelessWidget {
  final DashboardState state;

  const DashboardTasksCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isSummaryLoading) {
      return const ShimmerBlock(height: 220);
    }

    if (state.summaryError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppErrorRetry(
            message: state.summaryError!,
            centered: false,
            onRetry: () => context.read<DashboardCubit>().refreshSummary(),
          ),
        ),
      );
    }

    final completedColor = theme.appColors.green;
    final pendingColor = theme.appColors.grayLight;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: DonutChartPainter(
                  completed: state.completedTodos,
                  pending: state.pendingTodos,
                  completedColor: completedColor,
                  pendingColor: pendingColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.totalTodos}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    label: 'Concluídas',
                    value: state.completedTodos,
                    color: completedColor,
                  ),
                  const SizedBox(height: 16),
                  _LegendItem(
                    label: 'Pendentes',
                    value: state.pendingTodos,
                    color: pendingColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          '$value',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int completed;
  final int pending;
  final Color completedColor;
  final Color pendingColor;

  DonutChartPainter({
    required this.completed,
    required this.pending,
    required this.completedColor,
    required this.pendingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = completed + pending;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final completedSweep = (completed / total) * 2 * math.pi;
    final pendingSweep = (pending / total) * 2 * math.pi;

    final completedPaint = Paint()
      ..color = completedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = pendingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;

    canvas.drawArc(rect, startAngle, completedSweep, false, completedPaint);
    canvas.drawArc(
      rect,
      startAngle + completedSweep,
      pendingSweep,
      false,
      pendingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.completed != completed || oldDelegate.pending != pending;
  }
}
