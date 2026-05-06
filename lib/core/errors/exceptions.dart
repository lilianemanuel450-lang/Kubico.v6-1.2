class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erro no servidor']);
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erro de cache']);
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sem conexão']);
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Erro de autenticação']);
  @override
  String toString() => 'AuthException: $message';
}
