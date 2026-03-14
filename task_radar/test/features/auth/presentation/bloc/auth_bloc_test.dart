import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthUseCase mockCheckAuthUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    image: 'https://dummyjson.com/icon/emilys/128',
    role: 'admin',
  );

  setUpAll(() {
    registerFallbackValue(const LoginParams(username: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthUseCase = MockCheckAuthUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthUseCase: mockCheckAuthUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('estado inicial deve ser AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] quando login é bem-sucedido',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthError] quando login falha',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Credenciais inválidas')),
        );
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'wrong', password: 'wrong')),
      expect: () => [
        const AuthLoading(),
        const AuthError('Credenciais inválidas'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthUnauthenticated] quando logout é realizado',
      build: () {
        when(
          () => mockLogoutUseCase(any()),
        ).thenAnswer((_) async => Right(Unit.instance));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('CheckAuthRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthAuthenticated] quando usuário está autenticado',
      build: () {
        when(() => mockCheckAuthUseCase()).thenAnswer((_) async => true);
        when(
          () => mockGetCurrentUserUseCase(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthRequested()),
      expect: () => [const AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthUnauthenticated] quando usuário não está autenticado',
      build: () {
        when(() => mockCheckAuthUseCase()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('GetCurrentUserRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthAuthenticated] quando obtém usuário com sucesso',
      build: () {
        when(
          () => mockGetCurrentUserUseCase(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const GetCurrentUserRequested()),
      expect: () => [const AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthError] quando falha ao obter usuário',
      build: () {
        when(() => mockGetCurrentUserUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro no servidor')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const GetCurrentUserRequested()),
      expect: () => [const AuthError('Erro no servidor')],
    );
  });
}
