import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/widgets/shimmer_block.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';

class DashboardQuoteSection extends StatelessWidget {
  final DashboardState state;

  const DashboardQuoteSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isQuoteLoading) {
      return const ShimmerBlock(height: 60);
    }

    if (state.quoteError != null) {
      return GestureDetector(
        onTap: () => context.read<DashboardCubit>().refreshQuote(),
        child: Text(
          'Toque para carregar uma frase motivacional',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    if (state.quote == null) return const SizedBox.shrink();

    return Text(
      '"${state.quote!.quote}" — ${state.quote!.author}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade400,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
