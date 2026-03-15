import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:task_radar/app/features/dashboard/presentation/widgets/dashboard_greeting.dart';
import 'package:task_radar/app/features/dashboard/presentation/widgets/dashboard_quote_section.dart';
import 'package:task_radar/app/features/dashboard/presentation/widgets/dashboard_tasks_card.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/create_todo_sheet.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 0,
        onPressed: () => showCreateTodoBottomSheet(context),
        child: Icon(Icons.add),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardCubit>().loadDashboard();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 32),
                DashboardGreeting(userName: state.userName),
                const SizedBox(height: 16),
                DashboardQuoteSection(state: state),
                const SizedBox(height: 32),
                Text(
                  'Suas tarefas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                DashboardTasksCard(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}
