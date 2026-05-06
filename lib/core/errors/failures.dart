import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erro no servidor']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erro de cache']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Sem conexão à internet'])
      : super(message);
}

class LocationFailure extends Failure {
  const LocationFailure([String message = 'Erro de localização'])
      : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Erro de autenticação']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
