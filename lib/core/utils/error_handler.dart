import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../errors/failures.dart';

/// Sistema centralizado de tratamento de erros
/// Previne vazamento de informações sensíveis e garante logging adequado
class ErrorHandler {
  ErrorHandler._();

  /// Trata erro de forma segura, registrando detalhes internos mas retornando mensagem genérica
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool reportToSentry = true,
  }) async {
    // Log detalhado apenas em modo debug
    if (kDebugMode) {
      developer.log(
        'Error in ${context ?? "unknown context"}',
        name: 'Kubico.ErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
      
      if (additionalData != null && additionalData.isNotEmpty) {
        developer.log(
          'Additional data: ${additionalData.toString()}',
          name: 'Kubico.ErrorHandler',
        );
      }
    }

    // Envia para Sentry apenas em produção
    if (!kDebugMode && reportToSentry) {
      try {
        await Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            if (context != null) {
              scope.setTag('error_context', context);
            }
            if (additionalData != null) {
              scope.setContexts('additional_data', additionalData);
            }
          },
        );
      } catch (sentryError) {
        // Falha silenciosa se Sentry não estiver configurado
        developer.log(
          'Failed to report to Sentry: $sentryError',
          name: 'Kubico.ErrorHandler',
        );
      }
    }
  }

  /// Converte erros técnicos em mensagens amigáveis ao usuário
  /// NUNCA expõe detalhes técnicos ou stack traces ao usuário
  static String getUserFriendlyMessage(dynamic error) {
    if (error is Failure) {
      return _getFailureMessage(error);
    }

    // Mensagens genéricas para outros tipos de erro
    if (error is FormatException) {
      return 'Formato de dados inválido. Por favor, tente novamente.';
    }

    if (error is TypeError) {
      return 'Ocorreu um erro interno. Por favor, tente novamente.';
    }

    if (error.toString().toLowerCase().contains('network')) {
      return 'Sem conexão à internet. Verifique sua conexão e tente novamente.';
    }

    if (error.toString().toLowerCase().contains('timeout')) {
      return 'A operação demorou muito tempo. Por favor, tente novamente.';
    }

    // Mensagem genérica padrão (nunca revela detalhes técnicos)
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  /// Mensagens específicas para cada tipo de Failure
  static String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      // Não expõe mensagens de erro do servidor diretamente
      if (failure.message.toLowerCase().contains('not found')) {
        return 'Recurso não encontrado.';
      }
      if (failure.message.toLowerCase().contains('unauthorized') ||
          failure.message.toLowerCase().contains('forbidden')) {
        return 'Você não tem permissão para realizar esta ação.';
      }
      return 'Erro no servidor. Por favor, tente novamente mais tarde.';
    }

    if (failure is CacheFailure) {
      return 'Não foi possível carregar dados salvos.';
    }

    if (failure is NetworkFailure) {
      return 'Sem conexão à internet. Verifique sua conexão e tente novamente.';
    }

    if (failure is ValidationFailure) {
      // Mensagens de validação podem ser mostradas ao usuário
      return failure.message;
    }

    if (failure is AuthFailure) {
      return 'Erro de autenticação. Por favor, faça login novamente.';
    }

    return 'Ocorreu um erro. Por favor, tente novamente.';
  }

  /// Registra evento de negócio (não é erro)
  static void logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) {
    if (kDebugMode) {
      developer.log(
        'Event: $eventName',
        name: 'Kubico.Analytics',
      );
      if (parameters != null && parameters.isNotEmpty) {
        developer.log(
          'Parameters: ${parameters.toString()}',
          name: 'Kubico.Analytics',
        );
      }
    }

    // Em produção, enviar para analytics (Firebase, Mixpanel, etc.)
    if (!kDebugMode) {
      Sentry.captureMessage(
        eventName,
        level: SentryLevel.info,
        withScope: (scope) {
          if (parameters != null) {
            scope.setContexts('event_parameters', parameters);
          }
        },
      );
    }
  }

  /// Valida e sanitiza entrada do usuário antes de processar
  static T sanitizeInput<T>(T input, T Function(T) sanitizer) {
    try {
      return sanitizer(input);
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        context: 'InputSanitization',
        reportToSentry: false,
      );
      return input; // Fallback para input original se sanitização falhar
    }
  }
}

/// Failures adicionais para casos específicos
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
