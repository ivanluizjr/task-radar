import 'package:equatable/equatable.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';

enum TodosStatus { initial, loading, loaded, error }

class TodosState extends Equatable {
  final List<Todo> allTodos;
  final TodosStatus status;
  final bool hasReachedMax;
  final int total;
  final int currentSkip;
  final TodoFilter filter;
  final String searchQuery;
  final TodoSortBy sortBy;
  final SortOrder sortOrder;
  final String? errorMessage;
  final int? userId;

  const TodosState({
    this.allTodos = const [],
    this.status = TodosStatus.initial,
    this.hasReachedMax = false,
    this.total = 0,
    this.currentSkip = 0,
    this.filter = TodoFilter.all,
    this.searchQuery = '',
    this.sortBy = TodoSortBy.id,
    this.sortOrder = SortOrder.ascending,
    this.errorMessage,
    this.userId,
  });

  List<Todo> get filteredTodos {
    var todos = List<Todo>.from(allTodos);

    switch (filter) {
      case TodoFilter.completed:
        todos = todos.where((t) => t.completed).toList();
      case TodoFilter.pending:
        todos = todos.where((t) => !t.completed).toList();
      case TodoFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      todos = todos
          .where(
            (t) => t.todo.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (sortBy) {
      case TodoSortBy.id:
        todos.sort(
          (a, b) => sortOrder == SortOrder.ascending
              ? a.id.compareTo(b.id)
              : b.id.compareTo(a.id),
        );
      case TodoSortBy.alphabetical:
        todos.sort(
          (a, b) => sortOrder == SortOrder.ascending
              ? a.todo.toLowerCase().compareTo(b.todo.toLowerCase())
              : b.todo.toLowerCase().compareTo(a.todo.toLowerCase()),
        );
      case TodoSortBy.status:
        todos.sort((a, b) {
          final aVal = a.completed ? 1 : 0;
          final bVal = b.completed ? 1 : 0;
          return sortOrder == SortOrder.ascending
              ? aVal.compareTo(bVal)
              : bVal.compareTo(aVal);
        });
    }

    return todos;
  }

  TodosState copyWith({
    List<Todo>? allTodos,
    TodosStatus? status,
    bool? hasReachedMax,
    int? total,
    int? currentSkip,
    TodoFilter? filter,
    String? searchQuery,
    TodoSortBy? sortBy,
    SortOrder? sortOrder,
    String? errorMessage,
    int? userId,
  }) {
    return TodosState(
      allTodos: allTodos ?? this.allTodos,
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
      currentSkip: currentSkip ?? this.currentSkip,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    allTodos,
    status,
    hasReachedMax,
    total,
    currentSkip,
    filter,
    searchQuery,
    sortBy,
    sortOrder,
    errorMessage,
    userId,
  ];
}
