/// Configuration API partagée (alignée sur backMineralMapping).
///
/// Émulateur Android : `10.0.2.2` pointe vers le localhost de la machine hôte.
/// Appareil réel / réseau : passer `--dart-define=API_BASE_URL=http://IP:3000`.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  static Map<String, String> jsonHeaders({bool flutterAgent = true}) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (flutterAgent) 'User-Agent': 'Flutter',
    };
  }
}
