import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/todos/domain/usecases/create_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/delete_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_by_user_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/update_todo_usecase.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

const _pageSize = 20;

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final GetTodosUseCase _getTodosUseCase;
  final GetTodosByUserUseCase _getTodosByUserUseCase;
  final CreateTodoUseCase _createTodoUseCase;
  final UpdateTodoUseCase _updateTodoUseCase;
  final DeleteTodoUseCase _deleteTodoUseCase;

  TodosBloc({
    required GetTodosUseCase getTodosUseCase,
    required GetTodosByUserUseCase getTodosByUserUseCase,
    required CreateTodoUseCase createTodoUseCase,
    required UpdateTodoUseCase updateTodoUseCase,
    required DeleteTodoUseCase deleteTodoUseCase,
  }) : _getTodosUseCase = getTodosUseCase,
       _getTodosByUserUseCase = getTodosByUserUseCase,
       _createTodoUseCase = createTodoUseCase,
       _updateTodoUseCase = updateTodoUseCase,
       _deleteTodoUseCase = deleteTodoUseCase,
       super(const TodosState()) {
    on<LoadTodos>(_onLoadTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<CreateTodoRequested>(_onCreateTodo);
    on<UpdateTodoRequested>(_onUpdateTodo);
    on<DeleteTodoRequested>(_onDeleteTodo);
    on<ToggleTodoStatus>(_onToggleTodoStatus);
    on<FilterTodos>(_onFilterTodos);
    on<SearchTodos>(_onSearchTodos);
    on<ClearSearch>(_onClearSearch);
    on<SortTodosRequested>(_onSortTodos);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) async {
    emit(
      state.copyWith(
        status: TodosStatus.loading,
        userId: event.userId,
        allTodos: [],
        currentSkip: 0,
        hasReachedMax: false,
      ),
    );

    final result = event.userId != null
        ? await _getTodosByUserUseCase(
            GetTodosByUserParams(
              userId: event.userId!,
              limit: _pageSize,
              skip: 0,
            ),
          )
        : await _getTodosUseCase(
            const GetTodosParams(limit: _pageSize, skip: 0),
          );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TodosStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: TodosStatus.loaded,
          allTodos: data.todos,
          total: data.total,
          currentSkip: _pageSize,
          hasReachedMax: data.todos.length >= data.total,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreTodos(
    LoadMoreTodos event,
    Emitter<TodosState> emit,
  ) async {
    if (state.hasReachedMax || state.status == TodosStatus.loading) return;

    emit(state.copyWith(status: TodosStatus.loading));

    final result = state.userId != null
        ? await _getTodosByUserUseCase(
            GetTodosByUserParams(
              userId: state.userId!,
              limit: _pageSize,
              skip: state.currentSkip,
            ),
          )
        : await _getTodosUseCase(
            GetTodosParams(limit: _pageSize, skip: state.currentSkip),
          );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TodosStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (data) {
        final allTodos = [...state.allTodos, ...data.todos];
        emit(
          state.copyWith(
            status: TodosStatus.loaded,
            allTodos: allTodos,
            total: data.total,
            currentSkip: state.currentSkip + _pageSize,
            hasReachedMax: allTodos.length >= data.total,
          ),
        );
      },
    );
  }

  Future<void> _onCreateTodo(
    CreateTodoRequested event,
    Emitter<TodosState> emit,
  ) async {
    final result = await _createTodoUseCase(
      CreateTodoParams(todo: event.todo, userId: event.userId),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (todo) {
        final updatedTodos = [todo, ...state.allTodos];
        emit(state.copyWith(allTodos: updatedTodos, total: state.total + 1));
      },
    );
  }

  Future<void> _onUpdateTodo(
    UpdateTodoRequested event,
    Emitter<TodosState> emit,
  ) async {
    final result = await _updateTodoUseCase(
      UpdateTodoParams(
        id: event.id,
        todo: event.todo,
        completed: event.completed,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (updatedTodo) {
        final updatedTodos = state.allTodos
            .map((t) => t.id == updatedTodo.id ? updatedTodo : t)
            .toList();
        emit(state.copyWith(allTodos: updatedTodos));
      },
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoRequested event,
    Emitter<TodosState> emit,
  ) async {
    final result = await _deleteTodoUseCase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedTodos = state.allTodos
            .where((t) => t.id != event.id)
            .toList();
        emit(state.copyWith(allTodos: updatedTodos, total: state.total - 1));
      },
    );
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatus event,
    Emitter<TodosState> emit,
  ) async {
    final result = await _updateTodoUseCase(
      UpdateTodoParams(id: event.id, completed: event.completed),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (updatedTodo) {
        final updatedTodos = state.allTodos
            .map((t) => t.id == updatedTodo.id ? updatedTodo : t)
            .toList();
        emit(state.copyWith(allTodos: updatedTodos));
      },
    );
  }

  void _onFilterTodos(FilterTodos event, Emitter<TodosState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSearchTodos(SearchTodos event, Emitter<TodosState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearSearch(ClearSearch event, Emitter<TodosState> emit) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _onSortTodos(SortTodosRequested event, Emitter<TodosState> emit) {
    emit(state.copyWith(sortBy: event.sortBy, sortOrder: event.order));
  }
}
