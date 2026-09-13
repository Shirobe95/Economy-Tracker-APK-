# Economy Tracker

Aplicación Android personal de control financiero y previsión. Local-first: los
datos viven solo en el teléfono, sin backend, sin cuenta de usuario y sin
sincronización (DEC-001, DEC-002).

## Qué responde la aplicación

1. Cuánto dinero hay ahora mismo.
2. Cuánto se ha gastado y cuánto se ha cobrado.
3. Qué falta cobrar y qué falta pagar.
4. Cómo termina el mes.
5. Qué saldo se proyecta a 3, 6, 12 y 24 meses.
6. Si el objetivo de ahorro se está cumpliendo.

## Instalar el APK

No hace falta compilar nada en local. Cada push construye el APK:

1. Abre [Actions](https://github.com/Shirobe95/Economy-Tracker-APK-/actions)
   y entra en el último run verde de **Build APK**.
2. Descarga el artifact `economy-tracker-apk`.
3. Instala `app-arm64-v8a-release.apk` (es el que corresponde a cualquier
   móvil moderno). Si tu teléfono es antiguo, usa `app-armeabi-v7a-release.apk`;
   si dudas, `app-release.apk` funciona en todos a cambio de ocupar más.

La firma es la de depuración, así que Android pedirá permiso para instalar
desde fuera de la tienda. La firma de publicación corresponde al corte K.

## Desarrollo

Requiere Flutter 3.47.3 o posterior.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # tras tocar el esquema
flutter analyze
flutter test
flutter run
```

## Estructura

```
lib/
├─ app/            configuración, rutas y tema
│  └─ theme/       tokens y tema PALIKO, centralizados
├─ core/
│  ├─ database/    esquema Drift, enums y conversores
│  ├─ utils/       dinero y fechas
│  └─ widgets/     componentes compartidos
├─ data/           repositorios y motor de previsión
└─ features/       una carpeta por sección de la app
docs/vault/        documentación canónica del proyecto
```

## Reglas del proyecto que conviene no romper

Estas no son preferencias de estilo: cada una evita un error con dinero real.

- **Los importes son enteros en céntimos, nunca `double`.** El parser vive en
  `core/utils/money.dart` y rechaza más de dos decimales, separadores de miles
  y cualquier valor que desborde un entero de 64 bits. Las sumas pasan por
  `BigInt` y devuelven `null` antes que dar la vuelta en silencio.
- **Las fechas financieras son días del calendario, no instantes.** Se guardan
  como texto ISO. Como timestamp, el día leído dependería del huso horario del
  dispositivo.
- **El saldo no se almacena.** Se deriva de los movimientos reales cada vez, así
  que editar un gasto ya pagado recalcula en lugar de arrastrar un valor viejo.
- **Un gasto se paga y un ingreso se cobra**, nunca al revés, y ambos exigen la
  fecha en la que el dinero se movió de verdad.
- **Las restricciones viven en el esquema**, no solo en la capa de aplicación.
  Ojo: Drift descarta las claves foráneas de `references()` en cuanto la tabla
  declara `customConstraints`, así que en este proyecto todas se escriben a
  mano en `customConstraints`.
- **Nunca se muestra una cifra que no sostenga un dato real.** Un cero en una
  casilla vacía se lee como un saldo de cero, que no es lo mismo que no saberlo.
- **Las reglas recurrentes no materializan movimientos.** Consultar sus próximas
  fechas es una consulta, no un efecto: no escribe y no puede duplicar un gasto.

## Copia de seguridad

Tus datos viven solo en el teléfono. **Ajustes → Copia de seguridad** exporta
un JSON con todo y permite restaurarlo. Hazlo antes de cambiar de móvil,
antes de desinstalar y antes de cambiar la clave de firma: cualquiera de las
tres cosas se lleva la base de datos por delante.

El archivo no está cifrado. Guárdalo donde guardarías un extracto bancario.

## Documentación

`docs/vault/` contiene la documentación canónica: visión, modelo financiero,
arquitectura, modelo de datos, sistema visual, mockups aprobados y decisiones
DEC-001 a DEC-007. Ante cualquier duda de comportamiento, manda el Vault.
