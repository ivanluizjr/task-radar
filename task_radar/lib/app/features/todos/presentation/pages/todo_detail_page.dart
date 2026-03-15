import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_delete_button.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_delete_confirmation_dialog.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_error_snackbar.dart';

class TodoDetailPage extends StatelessWidget {
  final int todoId;

  const TodoDetailPage({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodosBloc, TodosState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showTodoErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final todo = state.allTodos.where((t) => t.id == todoId).firstOrNull;

        if (todo == null) {
          return Scaffold(
            appBar: _buildDetailAppBar(context),
            body: const Center(child: Text('Tarefa não encontrada')),
          );
        }

        final parts = todo.todo.split('\n');
        final title = parts.first;
        final description = parts.length > 1
            ? parts.sublist(1).join('\n')
            : null;

        return Scaffold(
          appBar: _buildDetailAppBar(context),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(thickness: 2),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: TodoDeleteButton(
                    onPressed: () => showTodoDeleteConfirmationDialog(
                      context: context,
                      onConfirm: () {
                        context.read<TodosBloc>().add(
                          DeleteTodoRequested(todo.id),
                        );
                        context.pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildDetailAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Tarefas'),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
