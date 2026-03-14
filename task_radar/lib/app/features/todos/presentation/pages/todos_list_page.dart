import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class TodosListPage extends StatefulWidget {
  const TodosListPage({super.key});

  @override
  State<TodosListPage> createState() => _TodosListPageState();
}

class _TodosListPageState extends State<TodosListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

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
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar tarefas...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<TodosBloc>().add(SearchTodos(value));
                },
              )
            : const Text('Tarefas'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<TodosBloc>().add(const ClearSearch());
                }
              });
            },
          ),
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              context.read<TodosBloc>().add(
                SortTodosRequested(sortBy: option.sortBy, order: option.order),
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortOption(TodoSortBy.id, SortOrder.descending),
                child: const Text('Mais recentes'),
              ),
              PopupMenuItem(
                value: _SortOption(TodoSortBy.id, SortOrder.ascending),
                child: const Text('Mais antigos'),
              ),
              PopupMenuItem(
                value: _SortOption(
                  TodoSortBy.alphabetical,
                  SortOrder.ascending,
                ),
                child: const Text('A-Z'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
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

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TodosBloc>().add(const LoadTodos());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todos.length + (!state.hasReachedMax ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= todos.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final todo = todos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.completed,
                            onChanged: (_) {
                              context.read<TodosBloc>().add(
                                ToggleTodoStatus(
                                  id: todo.id,
                                  completed: !todo.completed,
                                ),
                              );
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                          title: Text(
                            todo.todo,
                            style: TextStyle(
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.completed ? Colors.grey : null,
                            ),
                          ),
                          onTap: () {
                            context.push('/todos/${todo.id}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/todos/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'Todas',
                selected: state.filter == TodoFilter.all,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.all),
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Concluídas',
                selected: state.filter == TodoFilter.completed,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.completed),
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pendentes',
                selected: state.filter == TodoFilter.pending,
                onSelected: () => context.read<TodosBloc>().add(
                  const FilterTodos(TodoFilter.pending),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortOption {
  final TodoSortBy sortBy;
  final SortOrder order;

  const _SortOption(this.sortBy, this.order);
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
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
