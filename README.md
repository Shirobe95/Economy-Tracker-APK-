# Economy Tracker

Aplicación Android de control financiero personal y previsión. Local-first:
los datos viven en el dispositivo, sin cuenta ni servidor.

Interfaz construida sobre el sistema visual **PALIKO**: base grafito azulada,
acentos azul-cian, paneles discretos y jerarquía tipográfica fuerte.

## Estado

En construcción. Ver `docs/` para el alcance y las decisiones de diseño.

| Bloque | Estado |
| --- | --- |
| Sistema visual PALIKO | Implementado |
| CI y build del APK | Implementado |
| Modelo de datos y persistencia | Pendiente de especificación |
| Movimientos, categorías y cuentas | Pendiente |
| Previsión y objetivos de ahorro | Pendiente |

## Requisitos

- Flutter 3.47.3 (canal stable)
- JDK 17 para compilar el APK

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Antes de subir cambios:

```bash
dart format .
flutter analyze
flutter test
```

## Obtener el APK

El APK se compila en GitHub Actions en cada push. Para descargarlo:

1. Abrir la pestaña **Actions** del repositorio.
2. Entrar en la ejecución más reciente del workflow **Build APK**.
3. Descargar el artifact `economy-tracker-apk`.

Contiene los APK por arquitectura (`app-arm64-v8a-release.apk` es el habitual
en móviles actuales) y un APK universal que funciona en cualquier dispositivo
a costa de más tamaño.

Para compilar en local, con el SDK de Android instalado:

```bash
flutter build apk --release --split-per-abi
```

## Estructura

```
lib/
  main.dart                 punto de entrada
  app/                      raíz de la aplicación y navegación
  core/
    format/                 formateo de importes y fechas
    theme/                  tokens y tema PALIKO
    widgets/                componentes base del sistema visual
  features/                 módulos funcionales
```
