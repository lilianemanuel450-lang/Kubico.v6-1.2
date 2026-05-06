import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Utilitário para monitoramento de performance
class PerformanceMonitor {
  PerformanceMonitor._();

  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _measurements = {};

  /// Inicia medição de performance para uma operação
  static void startTrace(String traceName) {
    if (!kDebugMode) return; // Apenas em debug
    
    _timers[traceName] = Stopwatch()..start();
    developer.log(
      'Started trace: $traceName',
      name: 'Kubico.Performance',
    );
  }

  /// Finaliza medição e registra o tempo
  static void stopTrace(String traceName) {
    if (!kDebugMode) return;
    
    final timer = _timers[traceName];
    if (timer == null) {
      developer.log(
        'Trace not found: $traceName',
        name: 'Kubico.Performance',
      );
      return;
    }

    timer.stop();
    final elapsedMs = timer.elapsedMilliseconds;

    // Armazena medição
    _measurements.putIfAbsent(traceName, () => []).add(elapsedMs);

    developer.log(
      'Completed trace: $traceName in ${elapsedMs}ms',
      name: 'Kubico.Performance',
    );

    _timers.remove(traceName);
  }

  /// Mede tempo de execução de uma função assíncrona
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      _logMeasurement(operationName, stopwatch.elapsedMilliseconds);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Operation failed: $operationName in ${stopwatch.elapsedMilliseconds}ms',
        name: 'Kubico.Performance',
        error: e,
      );
      rethrow;
    }
  }

  /// Mede tempo de execução de uma função síncrona
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    if (!kDebugMode) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      _logMeasurement(operationName, stopwatch.elapsedMilliseconds);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Operation failed: $operationName in ${stopwatch.elapsedMilliseconds}ms',
        name: 'Kubico.Performance',
        error: e,
      );
      rethrow;
    }
  }

  /// Registra medição com estatísticas
  static void _logMeasurement(String operationName, int elapsedMs) {
    _measurements.putIfAbsent(operationName, () => []).add(elapsedMs);

    final measurements = _measurements[operationName]!;
    final avg = measurements.reduce((a, b) => a + b) / measurements.length;
    final min = measurements.reduce((a, b) => a < b ? a : b);
    final max = measurements.reduce((a, b) => a > b ? a : b);

    developer.log(
      'Performance: $operationName\n'
      '  Current: ${elapsedMs}ms\n'
      '  Average: ${avg.toStringAsFixed(2)}ms\n'
      '  Min: ${min}ms\n'
      '  Max: ${max}ms\n'
      '  Samples: ${measurements.length}',
      name: 'Kubico.Performance',
    );

    // Alerta se operação for muito lenta
    if (elapsedMs > 1000) {
      developer.log(
        '⚠️ SLOW OPERATION: $operationName took ${elapsedMs}ms',
        name: 'Kubico.Performance',
      );
    }
  }

  /// Obtém estatísticas de performance
  static Map<String, Map<String, dynamic>> getStats() {
    final stats = <String, Map<String, dynamic>>{};

    for (final entry in _measurements.entries) {
      final measurements = entry.value;
      if (measurements.isEmpty) continue;

      final avg = measurements.reduce((a, b) => a + b) / measurements.length;
      final min = measurements.reduce((a, b) => a < b ? a : b);
      final max = measurements.reduce((a, b) => a > b ? a : b);

      stats[entry.key] = {
        'average_ms': avg,
        'min_ms': min,
        'max_ms': max,
        'count': measurements.length,
      };
    }

    return stats;
  }

  /// Limpa todas as medições
  static void clear() {
    _measurements.clear();
    _timers.clear();
  }

  /// Monitora uso de memória (apenas debug)
  static void logMemoryUsage(String context) {
    if (!kDebugMode) return;

    developer.log(
      'Memory check at: $context',
      name: 'Kubico.Memory',
    );
  }

  /// Marca um ponto de verificação no fluxo de execução
  static void checkpoint(String checkpointName) {
    if (!kDebugMode) return;

    developer.log(
      'Checkpoint: $checkpointName',
      name: 'Kubico.Performance',
      time: DateTime.now(),
    );
  }
}

/// Extension para facilitar medição de futures
extension PerformanceFutureExtension<T> on Future<T> {
  Future<T> measured(String operationName) {
    return PerformanceMonitor.measureAsync(operationName, () => this);
  }
}
