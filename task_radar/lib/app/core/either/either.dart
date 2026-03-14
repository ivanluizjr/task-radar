final class Unit {
  const Unit._();

  static final instance = Unit._();

  @override
  String toString() => 'Unit';
}

sealed class Either<L, R> {
  const Either();

  B fold<B>(B Function(L left) onLeft, B Function(R right) onRight);

  Either<L, T> map<T>(T Function(R right) f);

  Either<L, T> flatMap<T>(Either<L, T> Function(R right) f);

  bool get isLeft;
  bool get isRight;

  L? get leftOrNull => fold((l) => l, (_) => null);

  R? get rightOrNull => fold((_) => null, (r) => r);
}

final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  B fold<B>(B Function(L left) onLeft, B Function(R right) onRight) =>
      onLeft(value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  Either<L, T> map<T>(T Function(R right) f) => Left<L, T>(value);

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) f) =>
      Left<L, T>(value);

  @override
  String toString() => 'Left($value)';
}

final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  B fold<B>(B Function(L left) onLeft, B Function(R right) onRight) =>
      onRight(value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  Either<L, T> map<T>(T Function(R right) f) => Right<L, T>(f(value));

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) f) => f(value);

  @override
  String toString() => 'Right($value)';
}
