import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Radar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardCubit>().loadDashboard();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummarySection(context, state),
                const SizedBox(height: 24),
                _buildQuoteSection(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);

    if (state.isSummaryLoading) {
      return _buildShimmerCard(context);
    }

    if (state.summaryError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                state.summaryError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.read<DashboardCubit>().refreshSummary(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: state.completionPercentage,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.surface,
                    color: const Color(0xFF4CAF50),
                  ),
                  Center(
                    child: Text(
                      '${(state.completionPercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Total',
                  state.totalTodos.toString(),
                  theme.colorScheme.primary,
                ),
                _buildStatItem(
                  'Concluídas',
                  state.completedTodos.toString(),
                  const Color(0xFF4CAF50),
                ),
                _buildStatItem(
                  'Pendentes',
                  state.pendingTodos.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildQuoteSection(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);

    if (state.isQuoteLoading) {
      return _buildShimmerCard(context);
    }

    if (state.quoteError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.format_quote, size: 32),
              const SizedBox(height: 8),
              Text(
                'Não foi possível carregar a frase',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              TextButton(
                onPressed: () => context.read<DashboardCubit>().refreshQuote(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.quote == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              '"${state.quote!.quote}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              '— ${state.quote!.author}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Card(
        child: Container(height: 180, padding: const EdgeInsets.all(20)),
      ),
    );
  }
}
