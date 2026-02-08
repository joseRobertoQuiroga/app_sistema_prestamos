# Scripts de Ayuda - Sistema de Préstamos

## Generar código (una vez)
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Generar código (watch mode - recomendado para desarrollo)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Limpiar y regenerar
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Ejecutar en Windows
```bash
flutter run -d windows
```

## Ejecutar en modo release
```bash
flutter run -d windows --release
```

## Análisis de código
```bash
flutter analyze
```

## Ejecutar tests
```bash
flutter test
```

## Generar build de producción
```bash
flutter build windows --release
```

## Ver dispositivos disponibles
```bash
flutter devices
```

## Verificar configuración de Flutter
```bash
flutter doctor -v
```