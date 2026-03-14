import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';
import 'package:task_radar/app/features/quotes/domain/usecases/get_random_quote_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todo_summary_usecase.dart';

class MockGetTodoSummaryUseCase extends Mock implements GetTodoSummaryUseCase {}

class MockGetRandomQuoteUseCase extends Mock implements GetRandomQuoteUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetTodoSummaryUseCase mockGetTodoSummaryUseCase;
  late MockGetRandomQuoteUseCase mockGetRandomQuoteUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    role: 'admin',
  );

  const tQuote = Quote(id: 1, quote: 'Test quote', author: 'Author');

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(1);
  });

  setUp(() {
    mockGetTodoSummaryUseCase = MockGetTodoSummaryUseCase();
    mockGetRandomQuoteUseCase = MockGetRandomQuoteUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    cubit = DashboardCubit(
      getTodoSummaryUseCase: mockGetTodoSummaryUseCase,
      getRandomQuoteUseCase: mockGetRandomQuoteUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('estado inicial deve ter todos os campos zerados', () {
    expect(cubit.state, const DashboardState());
    expect(cubit.state.completionPercentage, 0);
  });

  test('completionPercentage calcula corretamente', () {
    final state = const DashboardState(totalTodos: 10, completedTodos: 7);
    expect(state.completionPercentage, 0.7);
  });

  group('refreshQuote', () {
    blocTest<DashboardCubit, DashboardState>(
      'carrega frase com sucesso',
      build: () {
        when(
          () => mockGetRandomQuoteUseCase(any()),
        ).thenAnswer((_) async => const Right(tQuote));
        return cubit;
      },
      act: (cubit) => cubit.refreshQuote(),
      expect: () => [
        const DashboardState(isQuoteLoading: true),
        const DashboardState(isQuoteLoading: false, quote: tQuote),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emite erro quando falha ao carregar frase',
      build: () {
        when(
          () => mockGetRandomQuoteUseCase(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Erro')));
        return cubit;
      },
      act: (cubit) => cubit.refreshQuote(),
      expect: () => [
        const DashboardState(isQuoteLoading: true),
        const DashboardState(isQuoteLoading: false, quoteError: 'Erro'),
      ],
    );
  });

  group('refreshSummary', () {
    blocTest<DashboardCubit, DashboardState>(
      'carrega resumo com sucesso',
      build: () {
        when(
          () => mockGetCurrentUserUseCase(any()),
        ).thenAnswer((_) async => const Right(tUser));
        when(() => mockGetTodoSummaryUseCase(any())).thenAnswer(
          (_) async => const Right((total: 10, completed: 7, pending: 3)),
        );
        return cubit;
      },
      act: (cubit) => cubit.refreshSummary(),
      expect: () => [
        const DashboardState(isSummaryLoading: true),
        const DashboardState(
          isSummaryLoading: false,
          totalTodos: 10,
          completedTodos: 7,
          pendingTodos: 3,
        ),
      ],
    );
  });
}
