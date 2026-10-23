import 'package:radar_labor/core/errors/failure.dart';

/// Thrown while opening the database; carries the typed [failure].
final class DatabaseOpenException implements Exception {
  const DatabaseOpenException(this.failure);

  final Failure failure;

  @override
  String toString() => 'DatabaseOpenException(${failure.runtimeType})';
}
