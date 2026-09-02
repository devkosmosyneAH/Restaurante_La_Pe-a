import 'web_storage_diagnostics.dart';

Future<WebStorageDiagnostics> readPlatformWebStorageDiagnostics() async =>
    const WebStorageDiagnostics(
      userAgent: null,
      localStorage: 'NO-DETERMINADO (plataforma no web)',
      indexedDb: 'NO-DETERMINADO (plataforma no web)',
      privateMode: 'NO-DETERMINADO',
    );
