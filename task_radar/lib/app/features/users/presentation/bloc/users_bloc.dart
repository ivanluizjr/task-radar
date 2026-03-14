import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/users/domain/usecases/get_users_usecase.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  const LoadUsers();
}

class LoadMoreUsers extends UsersEvent {
  const LoadMoreUsers();
}

enum UsersStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final List<User> users;
  final UsersStatus status;
  final bool hasReachedMax;
  final int total;
  final int currentSkip;
  final String? errorMessage;

  const UsersState({
    this.users = const [],
    this.status = UsersStatus.initial,
    this.hasReachedMax = false,
    this.total = 0,
    this.currentSkip = 0,
    this.errorMessage,
  });

  UsersState copyWith({
    List<User>? users,
    UsersStatus? status,
    bool? hasReachedMax,
    int? total,
    int? currentSkip,
    String? errorMessage,
  }) {
    return UsersState(
      users: users ?? this.users,
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
      currentSkip: currentSkip ?? this.currentSkip,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    users,
    status,
    hasReachedMax,
    total,
    currentSkip,
    errorMessage,
  ];
}

const _pageSize = 20;

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase _getUsersUseCase;

  UsersBloc({required GetUsersUseCase getUsersUseCase})
    : _getUsersUseCase = getUsersUseCase,
      super(const UsersState()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(
      state.copyWith(
        status: UsersStatus.loading,
        users: [],
        currentSkip: 0,
        hasReachedMax: false,
      ),
    );

    final result = await _getUsersUseCase(
      const GetUsersParams(limit: _pageSize, skip: 0),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UsersStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: UsersStatus.loaded,
          users: data.users,
          total: data.total,
          currentSkip: _pageSize,
          hasReachedMax: data.users.length >= data.total,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UsersState> emit,
  ) async {
    if (state.hasReachedMax || state.status == UsersStatus.loading) return;

    emit(state.copyWith(status: UsersStatus.loading));

    final result = await _getUsersUseCase(
      GetUsersParams(limit: _pageSize, skip: state.currentSkip),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UsersStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (data) {
        final allUsers = [...state.users, ...data.users];
        emit(
          state.copyWith(
            status: UsersStatus.loaded,
            users: allUsers,
            total: data.total,
            currentSkip: state.currentSkip + _pageSize,
            hasReachedMax: allUsers.length >= data.total,
          ),
        );
      },
    );
  }
}
