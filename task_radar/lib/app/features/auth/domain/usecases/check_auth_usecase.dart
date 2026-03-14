import 'package:task_radar/app/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  Future<bool> call() {
    return _repository.isAuthenticated();
  }
}
