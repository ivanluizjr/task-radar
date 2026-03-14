import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class UserTodosPage extends StatefulWidget {
  final int userId;
  final String userName;

  const UserTodosPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserTodosPage> createState() => _UserTodosPageState();
}

class _UserTodosPageState extends State<UserTodosPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodosBloc>().add(LoadTodos(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas de ${widget.userName}'),
      ),
      body: BlocBuilder<TodosBloc, TodosState>(
        builder: (context, state) {
          if (state.status == TodosStatus.loading && state.allTodos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.allTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TodosBloc>()
                        .add(LoadTodos(userId: widget.userId)),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final todos = state.filteredTodos;

          if (todos.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    todo.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: todo.completed
                        ? const Color(0xFF4CAF50)
                        : Colors.orange,
                  ),
                  title: Text(
                    todo.todo,
                    style: TextStyle(
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed ? Colors.grey : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
