import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_radar/app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    image: 'https://dummyjson.com/icon/emilys/128',
    role: 'admin',
  );

  const tParams = LoginParams(username: 'emilys', password: 'emilyspass');

  test('deve retornar User quando login é bem-sucedido', () async {
    when(
      () => mockRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await useCase(tParams);

    expect(result.isRight, true);
    result.fold(
      (failure) => fail('Deveria ser Right'),
      (user) => expect(user, tUser),
    );
    verify(
      () => mockRepository.login(username: 'emilys', password: 'emilyspass'),
    ).called(1);
  });

  test('deve retornar Failure quando login falha', () async {
    when(
      () => mockRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(AuthFailure('Credenciais inválidas')));

    final result = await useCase(tParams);

    expect(result.isLeft, true);
    result.fold(
      (failure) => expect(failure.message, 'Credenciais inválidas'),
      (_) => fail('Deveria ser Left'),
    );
  });
}
