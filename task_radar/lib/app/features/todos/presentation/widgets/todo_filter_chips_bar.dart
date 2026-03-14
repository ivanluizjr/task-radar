import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class TodoFilterChipsBar extends StatelessWidget {
  const TodoFilterChipsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              TodoFilterChip(
                label: 'Todas',
                selected: state.filter == TodoFilter.all,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.all),
                ),
              ),
              const SizedBox(width: 8),
              TodoFilterChip(
                label: 'Pendentes',
                selected: state.filter == TodoFilter.pending,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.pending),
                ),
              ),
              const SizedBox(width: 8),
              TodoFilterChip(
                label: 'Concluídas',
                selected: state.filter == TodoFilter.completed,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.completed),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TodoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const TodoFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(color: selected ? Colors.black : null),
    );
  }
}
