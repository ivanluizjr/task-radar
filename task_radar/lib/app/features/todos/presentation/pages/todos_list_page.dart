import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/create_todo_sheet.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_filter_chips_bar.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_item_card.dart';

class TodosListPage extends StatefulWidget {
  const TodosListPage({super.key});

  @override
  State<TodosListPage> createState() => _TodosListPageState();
}

class _TodosListPageState extends State<TodosListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<TodosBloc>().add(const LoadTodos());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TodosBloc>().add(const LoadMoreTodos());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar tarefas',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
              ),
              onChanged: (value) {
                context.read<TodosBloc>().add(SearchTodos(value));
              },
            ),
          ),
          const SizedBox(height: 8),
          const TodoFilterChipsBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<TodosBloc, TodosState>(
              buildWhen: (prev, curr) =>
                  prev.sortBy != curr.sortBy ||
                  prev.sortOrder != curr.sortOrder,
              builder: (context, state) {
                return Row(
                  children: [
                    Text(
                      'Ordenar por:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<_SortOption>(
                      padding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortLabel(state.sortBy),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      onSelected: (option) {
                        context.read<TodosBloc>().add(
                          SortTodosRequested(
                            sortBy: option.sortBy,
                            order: option.order,
                          ),
                        );
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _SortOption(
                            TodoSortBy.alphabetical,
                            SortOrder.ascending,
                          ),
                          child: const Text('Nome'),
                        ),
                        PopupMenuItem(
                          value: _SortOption(
                            TodoSortBy.status,
                            SortOrder.ascending,
                          ),
                          child: const Text('Data de conclusão'),
                        ),
                        PopupMenuItem(
                          value: _SortOption(
                            TodoSortBy.alphabetical,
                            SortOrder.ascending,
                          ),
                          child: const Text('Ordem crescente'),
                        ),
                        PopupMenuItem(
                          value: _SortOption(
                            TodoSortBy.alphabetical,
                            SortOrder.descending,
                          ),
                          child: const Text('Ordem decrescente'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TodosBloc, TodosState>(
              builder: (context, state) {
                if (state.status == TodosStatus.loading &&
                    state.allTodos.isEmpty) {
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
                          onPressed: () =>
                              context.read<TodosBloc>().add(const LoadTodos()),
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

                final pendingTodos = todos.where((t) => !t.completed).toList();
                final completedTodos = todos.where((t) => t.completed).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TodosBloc>().add(const LoadTodos());
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (pendingTodos.isNotEmpty) ...[
                        _SectionHeader(title: 'Pendentes'),
                        ...pendingTodos.map((todo) => TodoItemCard(todo: todo)),
                      ],
                      if (completedTodos.isNotEmpty) ...[
                        _SectionHeader(title: 'Concluídas'),
                        ...completedTodos.map(
                          (todo) => TodoItemCard(todo: todo),
                        ),
                      ],
                      if (!state.hasReachedMax)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF32D583),
        foregroundColor: Colors.black,
        onPressed: () => showCreateTodoBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _sortLabel(TodoSortBy sortBy) {
    switch (sortBy) {
      case TodoSortBy.alphabetical:
        return 'Nome';
      case TodoSortBy.status:
        return 'Data de conclusão';
      case TodoSortBy.id:
        return 'Nome';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SortOption {
  final TodoSortBy sortBy;
  final SortOrder order;

  const _SortOption(this.sortBy, this.order);
}
