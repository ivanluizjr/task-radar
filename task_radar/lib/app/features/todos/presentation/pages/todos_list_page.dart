import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_radar/app/core/widgets/app_search_field.dart';
import 'package:task_radar/app/core/widgets/app_state_widgets.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
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
  _SortMenuChoice _selectedSortMenuChoice = _SortMenuChoice.name;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated
        ? authState.user.id
        : (authState is AuthRefreshing ? authState.user.id : null);
    context.read<TodosBloc>().add(LoadTodos(userId: userId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<TodosBloc>().state;
    if (state.searchQuery.isNotEmpty) return;

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
          BlocBuilder<TodosBloc, TodosState>(
            buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
            builder: (context, state) {
              return AppSearchField(
                controller: _searchController,
                hintText: 'Pesquisar tarefas',
                hasText: state.searchQuery.isNotEmpty,
                onChanged: (value) =>
                    context.read<TodosBloc>().add(SearchTodos(value)),
                onClear: () {
                  _searchController.clear();
                  context.read<TodosBloc>().add(const SearchTodos(''));
                },
              );
            },
          ),
          const SizedBox(height: 8),
          const TodoFilterChipsBar(),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: BlocBuilder<TodosBloc, TodosState>(
                buildWhen: (prev, curr) =>
                    prev.sortBy != curr.sortBy ||
                    prev.sortOrder != curr.sortOrder ||
                    prev.sortVersion != curr.sortVersion,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ordenar por:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      PopupMenuButton<_SortOption>(
                        padding: EdgeInsets.zero,
                        position: PopupMenuPosition.under,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sortMenuLabel(_selectedSortMenuChoice),
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/images/icon_arrow_dow.svg',
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.onSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onSelected: (option) {
                          setState(() {
                            _selectedSortMenuChoice = option.menuChoice;
                          });
                          context.read<TodosBloc>().add(
                            SortTodosRequested(
                              sortBy: option.sortBy,
                              order: option.order,
                            ),
                          );
                        },
                        itemBuilder: (context) {
                          final currentSortBy = state.sortBy == TodoSortBy.id
                              ? TodoSortBy.alphabetical
                              : state.sortBy;
                          return [
                            CheckedPopupMenuItem(
                              value: _SortOption(
                                menuChoice: _SortMenuChoice.name,
                                sortBy: TodoSortBy.alphabetical,
                                order: state.sortOrder,
                              ),
                              checked:
                                  _selectedSortMenuChoice ==
                                  _SortMenuChoice.name,
                              child: const Text('Nome'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortOption(
                                menuChoice: _SortMenuChoice.completionDate,
                                sortBy: TodoSortBy.status,
                                order: state.sortOrder,
                              ),
                              checked:
                                  _selectedSortMenuChoice ==
                                  _SortMenuChoice.completionDate,
                              child: const Text('Data de conclusão'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortOption(
                                menuChoice: _SortMenuChoice.ascending,
                                sortBy: currentSortBy,
                                order: SortOrder.ascending,
                              ),
                              checked:
                                  _selectedSortMenuChoice ==
                                  _SortMenuChoice.ascending,
                              child: const Text('Ordem crescente'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortOption(
                                menuChoice: _SortMenuChoice.descending,
                                sortBy: currentSortBy,
                                order: SortOrder.descending,
                              ),
                              checked:
                                  _selectedSortMenuChoice ==
                                  _SortMenuChoice.descending,
                              child: const Text('Ordem decrescente'),
                            ),
                          ];
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
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
                    onRetry: () =>
                        context.read<TodosBloc>().add(const LoadTodos()),
                  );
                }

                final todos = state.filteredTodos;

                if (todos.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhuma tarefa encontrada',
                  );
                }

                final pendingTodos = todos.where((t) => !t.completed).toList();
                final completedTodos = todos.where((t) => t.completed).toList();

                final showCompletedFirst =
                    state.sortBy == TodoSortBy.status &&
                    state.sortOrder == SortOrder.descending;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TodosBloc>().add(const LoadTodos());
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    children: [
                      if (showCompletedFirst) ...[
                        if (completedTodos.isNotEmpty) ...[
                          const _SectionHeader(title: 'Concluídas'),
                          ...completedTodos.map(
                            (todo) => TodoItemCard(todo: todo),
                          ),
                        ],
                        if (pendingTodos.isNotEmpty) ...[
                          const _SectionHeader(title: 'Pendentes'),
                          ...pendingTodos.map(
                            (todo) => TodoItemCard(todo: todo),
                          ),
                        ],
                      ] else ...[
                        if (pendingTodos.isNotEmpty) ...[
                          const _SectionHeader(title: 'Pendentes'),
                          ...pendingTodos.map(
                            (todo) => TodoItemCard(todo: todo),
                          ),
                        ],
                        if (completedTodos.isNotEmpty) ...[
                          const _SectionHeader(title: 'Concluídas'),
                          ...completedTodos.map(
                            (todo) => TodoItemCard(todo: todo),
                          ),
                        ],
                      ],

                      if (state.searchQuery.isEmpty &&
                          (!state.hasReachedMax &&
                                  state.filter == TodoFilter.all ||
                              state.status == TodosStatus.loading))
                        const AppListFooterLoader(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 0,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => showCreateTodoBottomSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }

  String _sortMenuLabel(_SortMenuChoice choice) {
    switch (choice) {
      case _SortMenuChoice.name:
        return 'Nome';
      case _SortMenuChoice.completionDate:
        return 'Data de conclusão';
      case _SortMenuChoice.ascending:
        return 'Ordem crescente';
      case _SortMenuChoice.descending:
        return 'Ordem decrescente';
    }
  }
}

enum _SortMenuChoice { name, completionDate, ascending, descending }

class _SortOption {
  final _SortMenuChoice menuChoice;
  final TodoSortBy sortBy;
  final SortOrder order;

  const _SortOption({
    required this.menuChoice,
    required this.sortBy,
    required this.order,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
