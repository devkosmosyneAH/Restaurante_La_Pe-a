import 'web_storage_diagnostics_stub.dart'
    if (dart.library.html) 'web_storage_diagnostics_web.dart';

class WebStorageDiagnostics {
  const WebStorageDiagnostics({
    required this.userAgent,
    required this.localStorage,
    required this.indexedDb,
    required this.privateMode,
  });

  final String? userAgent;
  final String localStorage;
  final String indexedDb;
  final String privateMode;
}

Future<WebStorageDiagnostics> readWebStorageDiagnostics() =>
    readPlatformWebStorageDiagnostics();
