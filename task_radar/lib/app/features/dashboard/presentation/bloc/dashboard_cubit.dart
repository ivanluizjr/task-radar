import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';
import 'package:task_radar/app/features/quotes/domain/usecases/get_random_quote_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todo_summary_usecase.dart';

class DashboardState extends Equatable {
  final bool isSummaryLoading;
  final bool isQuoteLoading;
  final int totalTodos;
  final int completedTodos;
  final int pendingTodos;
  final Quote? quote;
  final String? summaryError;
  final String? quoteError;
  final String? userName;

  const DashboardState({
    this.isSummaryLoading = false,
    this.isQuoteLoading = false,
    this.totalTodos = 0,
    this.completedTodos = 0,
    this.pendingTodos = 0,
    this.quote,
    this.summaryError,
    this.quoteError,
    this.userName,
  });

  double get completionPercentage =>
      totalTodos > 0 ? completedTodos / totalTodos : 0;

  DashboardState copyWith({
    bool? isSummaryLoading,
    bool? isQuoteLoading,
    int? totalTodos,
    int? completedTodos,
    int? pendingTodos,
    Quote? quote,
    String? summaryError,
    String? quoteError,
    String? userName,
  }) {
    return DashboardState(
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isQuoteLoading: isQuoteLoading ?? this.isQuoteLoading,
      totalTodos: totalTodos ?? this.totalTodos,
      completedTodos: completedTodos ?? this.completedTodos,
      pendingTodos: pendingTodos ?? this.pendingTodos,
      quote: quote ?? this.quote,
      summaryError: summaryError,
      quoteError: quoteError,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
    isSummaryLoading,
    isQuoteLoading,
    totalTodos,
    completedTodos,
    pendingTodos,
    quote,
    summaryError,
    quoteError,
    userName,
  ];
}

class DashboardCubit extends Cubit<DashboardState> {
  final GetTodoSummaryUseCase _getTodoSummaryUseCase;
  final GetRandomQuoteUseCase _getRandomQuoteUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  DashboardCubit({
    required GetTodoSummaryUseCase getTodoSummaryUseCase,
    required GetRandomQuoteUseCase getRandomQuoteUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _getTodoSummaryUseCase = getTodoSummaryUseCase,
       _getRandomQuoteUseCase = getRandomQuoteUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const DashboardState());

  Future<void> loadDashboard() async {
    _loadSummary();
    _loadQuote();
  }

  Future<void> _loadSummary() async {
    emit(state.copyWith(isSummaryLoading: true));

    final userResult = await _getCurrentUserUseCase(const NoParams());
    await userResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            isSummaryLoading: false,
            summaryError: failure.message,
          ),
        );
      },
      (user) async {
        emit(state.copyWith(userName: user.firstName));
        final result = await _getTodoSummaryUseCase(user.id);
        result.fold(
          (failure) => emit(
            state.copyWith(
              isSummaryLoading: false,
              summaryError: failure.message,
            ),
          ),
          (summary) => emit(
            state.copyWith(
              isSummaryLoading: false,
              totalTodos: summary.total,
              completedTodos: summary.completed,
              pendingTodos: summary.pending,
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadQuote() async {
    emit(state.copyWith(isQuoteLoading: true));

    final result = await _getRandomQuoteUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(isQuoteLoading: false, quoteError: failure.message),
      ),
      (quote) => emit(state.copyWith(isQuoteLoading: false, quote: quote)),
    );
  }

  void refreshQuote() => _loadQuote();

  void refreshSummary() => _loadSummary();
}
