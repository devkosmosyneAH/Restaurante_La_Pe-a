import 'dart:async';

// TO DO: DEBUG TEMPORAL - remover después de diagnosticar
class DiagnosticLogger {
  DiagnosticLogger({DateTime? startedAt})
    : startedAt = startedAt ?? DateTime.now();

  final DateTime startedAt;
  final List<String> _lines = <String>[];

  void section(String title) {
    _lines.add('\n=== $title ===');
  }

  void line(String message) {
    _lines.add(message);
  }

  // TO DO: DEBUG TEMPORAL - remover después de diagnosticar
  Future<T> measure<T>(
    String name,
    Future<T> Function() operation, {
    String successStatus = 'OK',
  }) async {
    final started = DateTime.now();
    line('[${started.toIso8601String()}] $name: INICIADO');
    try {
      final result = await operation();
      _recordResult(name, started, successStatus);
      return result;
    } on TimeoutException catch (error, stackTrace) {
      _recordResult(name, started, 'TIMEOUT', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _recordResult(name, started, 'FALLÓ', error, stackTrace);
      rethrow;
    }
  }

  // TO DO: DEBUG TEMPORAL - remover después de diagnosticar
  void result(
    String name,
    DateTime started,
    String status, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _recordResult(name, started, status, error, stackTrace);
  }

  // TO DO: DEBUG TEMPORAL - remover después de diagnosticar
  void _recordResult(
    String name,
    DateTime started,
    String status, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final elapsed = DateTime.now().difference(started).inMilliseconds;
    final timestamp = DateTime.now().toIso8601String();
    var line = '[$timestamp] $name: $status (${elapsed}ms)';
    if (error != null) {
      line += '\n  Tipo: ${error.runtimeType}\n  Mensaje: $error';
      if (stackTrace != null) line += '\n  StackTrace:\n$stackTrace';
    }
    _lines.add(line);
  }

  String get text => _lines.join('\n');
}
