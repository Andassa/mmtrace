# mmtrace — API Mineral Mapping

L’app mobile consomme le backend `backMineralMapping`.

## URL API

Par défaut (émulateur Android) : `http://10.0.2.2:3000`

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
# appareil réel / réseau local :
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
```

Config centralisée : `lib/config/api_config.dart`

## Auth

`POST /sendDatalogin` avec header `User-Agent: Flutter` → JSON `{ redirect, role, user }`.
