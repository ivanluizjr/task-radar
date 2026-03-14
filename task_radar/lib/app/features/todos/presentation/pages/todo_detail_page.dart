import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class TodoDetailPage extends StatelessWidget {
  final int todoId;

  const TodoDetailPage({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TodosBloc, TodosState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final todo = state.allTodos.where((t) => t.id == todoId).firstOrNull;

        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tarefa')),
            body: const Center(child: Text('Tarefa não encontrada')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da Tarefa'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/todos/${todo.id}/edit'),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => _confirmDelete(context, todo),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              todo.completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: todo.completed
                                  ? const Color(0xFF4CAF50)
                                  : Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                todo.completed ? 'Concluída' : 'Pendente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: todo.completed
                                      ? const Color(0xFF4CAF50)
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          todo.todo,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ID: ${todo.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<TodosBloc>().add(
                            ToggleTodoStatus(
                              id: todo.id,
                              completed: !todo.completed,
                            ),
                          );
                    },
                    icon: Icon(
                      todo.completed
                          ? Icons.undo
                          : Icons.check,
                    ),
                    label: Text(
                      todo.completed ? 'Marcar como pendente' : 'Concluir tarefa',
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

  void _confirmDelete(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TodosBloc>().add(DeleteTodoRequested(todo.id));
              context.pop();
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
