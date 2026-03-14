import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';

class TodoItemCard extends StatelessWidget {
  final Todo todo;

  const TodoItemCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('/todos/${todo.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context.read<TodosBloc>().add(
                  ToggleTodoStatus(id: todo.id, completed: !todo.completed),
                );
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.completed
                      ? const Color(0xFF32D583)
                      : Colors.transparent,
                  border: Border.all(
                    color: todo.completed
                        ? const Color(0xFF32D583)
                        : Colors.grey.shade600,
                    width: 2,
                  ),
                ),
                child: todo.completed
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                todo.todo,
                style: TextStyle(
                  color: todo.completed ? Colors.grey.shade500 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
