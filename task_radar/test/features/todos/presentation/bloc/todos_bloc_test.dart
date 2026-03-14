import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/usecases/create_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/delete_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_by_user_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/update_todo_usecase.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockGetTodosByUserUseCase extends Mock implements GetTodosByUserUseCase {}

class MockCreateTodoUseCase extends Mock implements CreateTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

void main() {
  late TodosBloc todosBloc;
  late MockGetTodosUseCase mockGetTodosUseCase;
  late MockGetTodosByUserUseCase mockGetTodosByUserUseCase;
  late MockCreateTodoUseCase mockCreateTodoUseCase;
  late MockUpdateTodoUseCase mockUpdateTodoUseCase;
  late MockDeleteTodoUseCase mockDeleteTodoUseCase;

  const tTodo1 = Todo(id: 1, todo: 'Tarefa 1', completed: false, userId: 1);
  const tTodo2 = Todo(id: 2, todo: 'Tarefa 2', completed: true, userId: 1);
  const tTodos = [tTodo1, tTodo2];

  setUpAll(() {
    registerFallbackValue(const GetTodosParams(limit: 20, skip: 0));
    registerFallbackValue(
      const GetTodosByUserParams(userId: 1, limit: 20, skip: 0),
    );
    registerFallbackValue(const CreateTodoParams(todo: '', userId: 1));
    registerFallbackValue(const UpdateTodoParams(id: 1));
    registerFallbackValue(1);
  });

  setUp(() {
    mockGetTodosUseCase = MockGetTodosUseCase();
    mockGetTodosByUserUseCase = MockGetTodosByUserUseCase();
    mockCreateTodoUseCase = MockCreateTodoUseCase();
    mockUpdateTodoUseCase = MockUpdateTodoUseCase();
    mockDeleteTodoUseCase = MockDeleteTodoUseCase();

    todosBloc = TodosBloc(
      getTodosUseCase: mockGetTodosUseCase,
      getTodosByUserUseCase: mockGetTodosByUserUseCase,
      createTodoUseCase: mockCreateTodoUseCase,
      updateTodoUseCase: mockUpdateTodoUseCase,
      deleteTodoUseCase: mockDeleteTodoUseCase,
    );
  });

  tearDown(() {
    todosBloc.close();
  });

  test('estado inicial deve ser TodosState vazio', () {
    expect(todosBloc.state, const TodosState());
  });

  group('LoadTodos', () {
    blocTest<TodosBloc, TodosState>(
      'emite [loading, loaded] quando carrega todos com sucesso',
      build: () {
        when(
          () => mockGetTodosUseCase(any()),
        ).thenAnswer((_) async => const Right((todos: tTodos, total: 2)));
        return todosBloc;
      },
      act: (bloc) => bloc.add(const LoadTodos()),
      expect: () => [
        const TodosState(status: TodosStatus.loading),
        const TodosState(
          status: TodosStatus.loaded,
          allTodos: tTodos,
          total: 2,
          currentSkip: 20,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emite [loading, error] quando falha ao carregar todos',
      build: () {
        when(() => mockGetTodosUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro no servidor')),
        );
        return todosBloc;
      },
      act: (bloc) => bloc.add(const LoadTodos()),
      expect: () => [
        const TodosState(status: TodosStatus.loading),
        const TodosState(
          status: TodosStatus.error,
          errorMessage: 'Erro no servidor',
        ),
      ],
    );
  });

  group('CreateTodoRequested', () {
    const tNewTodo = Todo(
      id: 3,
      todo: 'Nova tarefa',
      completed: false,
      userId: 1,
    );

    blocTest<TodosBloc, TodosState>(
      'adiciona todo à lista quando criação é bem-sucedida',
      build: () {
        when(
          () => mockCreateTodoUseCase(any()),
        ).thenAnswer((_) async => const Right(tNewTodo));
        return todosBloc;
      },
      seed: () => const TodosState(
        status: TodosStatus.loaded,
        allTodos: tTodos,
        total: 2,
      ),
      act: (bloc) =>
          bloc.add(const CreateTodoRequested(todo: 'Nova tarefa', userId: 1)),
      expect: () => [
        const TodosState(
          status: TodosStatus.loaded,
          allTodos: [tNewTodo, ...tTodos],
          total: 3,
        ),
      ],
    );
  });

  group('DeleteTodoRequested', () {
    blocTest<TodosBloc, TodosState>(
      'remove todo da lista quando exclusão é bem-sucedida',
      build: () {
        when(
          () => mockDeleteTodoUseCase(any()),
        ).thenAnswer((_) async => const Right(tTodo1));
        return todosBloc;
      },
      seed: () => const TodosState(
        status: TodosStatus.loaded,
        allTodos: tTodos,
        total: 2,
      ),
      act: (bloc) => bloc.add(const DeleteTodoRequested(1)),
      expect: () => [
        const TodosState(
          status: TodosStatus.loaded,
          allTodos: [tTodo2],
          total: 1,
        ),
      ],
    );
  });

  group('FilterTodos', () {
    blocTest<TodosBloc, TodosState>(
      'atualiza filtro para concluídas',
      build: () => todosBloc,
      seed: () =>
          const TodosState(status: TodosStatus.loaded, allTodos: tTodos),
      act: (bloc) => bloc.add(const FilterTodos(TodoFilter.completed)),
      expect: () => [
        const TodosState(
          status: TodosStatus.loaded,
          allTodos: tTodos,
          filter: TodoFilter.completed,
        ),
      ],
    );
  });

  group('SearchTodos', () {
    blocTest<TodosBloc, TodosState>(
      'atualiza query de busca',
      build: () => todosBloc,
      seed: () =>
          const TodosState(status: TodosStatus.loaded, allTodos: tTodos),
      act: (bloc) => bloc.add(const SearchTodos('Tarefa 1')),
      expect: () => [
        const TodosState(
          status: TodosStatus.loaded,
          allTodos: tTodos,
          searchQuery: 'Tarefa 1',
        ),
      ],
    );
  });
}
