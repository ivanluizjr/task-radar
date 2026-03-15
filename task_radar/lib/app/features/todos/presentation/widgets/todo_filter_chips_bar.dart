import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
    final isLight = theme.brightness == Brightness.light;
    final selectedBackground = isLight
        ? theme.appColors.grayLight
        : theme.appColors.grayDark;
    final chipBackground = selected ? selectedBackground : Colors.transparent;
    final textColor = selected
        ? isLight
              ? Colors.black
              : Colors.white
        : (isLight ? Colors.black : Colors.white);
    final borderColor = selected
        ? selectedBackground
        : (isLight ? Colors.black : theme.appColors.grayLight);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: chipBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: 16, color: textColor),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
