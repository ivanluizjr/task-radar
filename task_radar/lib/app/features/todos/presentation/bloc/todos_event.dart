import 'package:equatable/equatable.dart';

enum TodoFilter { all, completed, pending }

enum TodoSortBy { id, alphabetical, status }

enum SortOrder { ascending, descending }

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodosEvent {
  final int? userId;

  const LoadTodos({this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadMoreTodos extends TodosEvent {
  /// Quando [silent] é true, o bloc não emite status de loading — os resultados
  /// aparecem silenciosamente na lista sem mostrar o spinner no rodapé.
  final bool silent;

  const LoadMoreTodos({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

class CreateTodoRequested extends TodosEvent {
  final String todo;
  final int userId;

  const CreateTodoRequested({required this.todo, required this.userId});

  @override
  List<Object?> get props => [todo, userId];
}

class UpdateTodoRequested extends TodosEvent {
  final int id;
  final String? todo;
  final bool? completed;

  const UpdateTodoRequested({required this.id, this.todo, this.completed});

  @override
  List<Object?> get props => [id, todo, completed];
}

class DeleteTodoRequested extends TodosEvent {
  final int id;

  const DeleteTodoRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleTodoStatus extends TodosEvent {
  final int id;
  final bool completed;

  const ToggleTodoStatus({required this.id, required this.completed});

  @override
  List<Object?> get props => [id, completed];
}

class FilterTodos extends TodosEvent {
  final TodoFilter filter;

  const FilterTodos(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchTodos extends TodosEvent {
  final String query;

  const SearchTodos(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends TodosEvent {
  const ClearSearch();
}

class SortTodosRequested extends TodosEvent {
  final TodoSortBy sortBy;
  final SortOrder order;

  const SortTodosRequested({required this.sortBy, required this.order});

  @override
  List<Object?> get props => [sortBy, order];
}
