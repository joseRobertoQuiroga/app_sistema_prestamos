import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Fallo de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fallo de servidor/API
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Fallo de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Fallo no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}