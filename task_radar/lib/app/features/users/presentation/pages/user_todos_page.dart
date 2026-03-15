import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/widgets/app_state_widgets.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_filter_chips_bar.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_item_card.dart';

class UserTodosPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String? userImage;

  const UserTodosPage({
    super.key,
    required this.userId,
    required this.userName,
    this.userImage,
  });

  @override
  State<UserTodosPage> createState() => _UserTodosPageState();
}

class _UserTodosPageState extends State<UserTodosPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodosBloc>().add(const SearchTodos(''));
    context.read<TodosBloc>().add(const FilterTodos(TodoFilter.all));
    context.read<TodosBloc>().add(LoadTodos(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  widget.userImage != null && widget.userImage!.isNotEmpty
                  ? NetworkImage(widget.userImage!)
                  : null,
              child: widget.userImage == null || widget.userImage!.isEmpty
                  ? Text(widget.userName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.userName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const TodoFilterChipsBar(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TodosBloc, TodosState>(
              builder: (context, state) {
                if (state.status == TodosStatus.loading &&
                    state.allTodos.isEmpty) {
                  return const AppCenteredLoading();
                }

                if (state.errorMessage != null && state.allTodos.isEmpty) {
                  return AppErrorRetry(
                    message: state.errorMessage!,
                    onRetry: () => context.read<TodosBloc>().add(
                      LoadTodos(userId: widget.userId),
                    ),
                  );
                }

                final todos = state.filteredTodos;

                if (todos.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhuma tarefa encontrada',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [...todos.map((todo) => TodoItemCard(todo: todo))],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
