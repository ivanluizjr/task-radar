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
      (data) {
        final nextState = state.copyWith(
          status: TodosStatus.loaded,
          allTodos: data.todos,
          total: data.total,
          currentSkip: _pageSize,
          hasReachedMax: data.todos.length >= data.total,
        );
        emit(nextState);
        // Se há filtro ativo e poucos itens visíveis, carrega próxima página silenciosamente
        if (!nextState.hasReachedMax &&
            nextState.filter != TodoFilter.all &&
            nextState.filteredTodos.length < _pageSize) {
          add(const LoadMoreTodos(silent: true));
        }
      },
    );
  }

  Future<void> _onLoadMoreTodos(
    LoadMoreTodos event,
    Emitter<TodosState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == TodosStatus.loading ||
        state.searchQuery.isNotEmpty) {
      return;
    }

    // Cargas disparadas pelo usuário (scroll) mostram spinner; auto-cargas são silenciosas
    if (!event.silent) {
      emit(state.copyWith(status: TodosStatus.loading));
    }

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
        final nextState = state.copyWith(
          status: TodosStatus.loaded,
          allTodos: allTodos,
          total: data.total,
          currentSkip: state.currentSkip + _pageSize,
          hasReachedMax: allTodos.length >= data.total,
        );
        emit(nextState);
        // Continua carregando silenciosamente se filtro ativo ainda tem poucos resultados
        if (!nextState.hasReachedMax &&
            nextState.filter != TodoFilter.all &&
            nextState.filteredTodos.length < _pageSize) {
          add(const LoadMoreTodos(silent: true));
        }
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
    // Optimistic: remove immediately
    final previousTodos = List.of(state.allTodos);
    final previousTotal = state.total;
    final updatedTodos = state.allTodos.where((t) => t.id != event.id).toList();
    emit(state.copyWith(allTodos: updatedTodos, total: state.total - 1));

    final result = await _deleteTodoUseCase(event.id);

    result.fold((failure) {
      // Rollback on failure
      emit(
        state.copyWith(
          allTodos: previousTodos,
          total: previousTotal,
          errorMessage: failure.message,
        ),
      );
    }, (_) {});
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatus event,
    Emitter<TodosState> emit,
  ) async {
    // Optimistic: toggle immediately
    final previousTodos = List.of(state.allTodos);
    final optimisticTodos = state.allTodos
        .map(
          (t) => t.id == event.id ? t.copyWith(completed: event.completed) : t,
        )
        .toList();
    emit(state.copyWith(allTodos: optimisticTodos));

    final result = await _updateTodoUseCase(
      UpdateTodoParams(id: event.id, completed: event.completed),
    );

    result.fold(
      (failure) {
        // Rollback on failure
        emit(
          state.copyWith(
            allTodos: previousTodos,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedTodo) {
        final updatedTodos = state.allTodos
            .map((t) => t.id == updatedTodo.id ? updatedTodo : t)
            .toList();
        emit(state.copyWith(allTodos: updatedTodos));
      },
    );
  }

  void _onFilterTodos(FilterTodos event, Emitter<TodosState> emit) {
    final nextState = state.copyWith(filter: event.filter);
    emit(nextState);
    // Ao aplicar filtro, auto-carrega silenciosamente se há poucos itens visíveis
    if (event.filter != TodoFilter.all &&
        !nextState.hasReachedMax &&
        nextState.filteredTodos.length < _pageSize) {
      add(const LoadMoreTodos(silent: true));
    }
  }

  void _onSearchTodos(SearchTodos event, Emitter<TodosState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearSearch(ClearSearch event, Emitter<TodosState> emit) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _onSortTodos(SortTodosRequested event, Emitter<TodosState> emit) {
    emit(
      state.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.order,
        sortVersion: state.sortVersion + 1,
      ),
    );
  }
}
