import 'dart:html' as html;

import 'web_storage_diagnostics.dart';

// TO DO: DEBUG TEMPORAL - remover después de diagnosticar
Future<WebStorageDiagnostics> readPlatformWebStorageDiagnostics() async {
  var localStorage = 'NO';
  var privateMode = 'NO-DETERMINADO';
  try {
    final storage = html.window.localStorage;
    const key = '__login_diagnostic_storage_test__';
    storage[key] = DateTime.now().toIso8601String();
    final canRead = storage[key] != null;
    storage.remove(key);
    localStorage = canRead ? 'SI (lectura/escritura OK)' : 'NO (lectura falló)';
  } catch (_) {
    localStorage = 'NO (acceso lanzó excepción)';
    privateMode = 'POSIBLE (storage rechazado)';
  }

  String indexedDb;
  try {
    indexedDb = html.window.indexedDB != null ? 'SI (API disponible)' : 'NO';
  } catch (_) {
    indexedDb = 'NO (acceso lanzó excepción)';
  }

  return WebStorageDiagnostics(
    userAgent: html.window.navigator.userAgent,
    localStorage: localStorage,
    indexedDb: indexedDb,
    privateMode: privateMode,
  );
}
