import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Extension methods for working with Either<Failure, T>
extension EitherExtension<T> on Either<Failure, T> {
  /// Returns true if this is a Right (success)
  bool get isSuccess => isRight();

  /// Returns true if this is a Left (failure)
  bool get isFailure => isLeft();

  /// Get the success value or null
  T? get successOrNull => fold((_) => null, (value) => value);

  /// Get the failure or null
  Failure? get failureOrNull => fold((failure) => failure, (_) => null);
}
