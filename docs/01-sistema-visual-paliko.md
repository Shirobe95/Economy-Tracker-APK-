# Sistema visual PALIKO

Referencia canónica del estilo de Economy Tracker. Cualquier pantalla nueva se
construye con estos tokens y componentes; no se introducen colores, radios ni
tamaños fuera de esta lista sin actualizar antes este documento.

## Principios

1. **Oscuro por diseño.** No hay tema claro. La identidad depende del contraste
   entre el grafito azulado y el acento cian.
2. **Paneles discretos.** Superficie plana con borde de bajo contraste. Sin
   sombras, sin degradados, sin bordes brillantes.
3. **Jerarquía por tipografía y espacio**, no por decoración. El acento cian se
   reserva para acción, foco y selección.
4. **El color con significado va sobre los datos.** Verde para ingreso, rojo
   para gasto, violeta para dato proyectado. Nunca como adorno.
5. **Sin subtítulos ornamentales ni métricas inventadas.** Si un bloque no tiene
   dato real, muestra su estado vacío.

## Color

Definido en `lib/core/theme/paliko_colors.dart`.

### Fondos

| Token | Hex | Uso |
| --- | --- | --- |
| `background` | `#0B0F14` | Fondo raíz de la app |
| `surface` | `#121820` | Paneles y tarjetas |
| `surfaceElevated` | `#18202B` | Hojas modales, campos, menús |
| `surfaceSubtle` | `#0F151D` | Barra de navegación, filas alternas |

### Bordes

| Token | Hex | Uso |
| --- | --- | --- |
| `border` | `#223040` | Borde estándar de panel |
| `borderStrong` | `#2E4155` | Botones outline, bordes activos |
| `divider` | `#1A2431` | Separadores dentro de un panel |

### Acentos

| Token | Hex | Uso |
| --- | --- | --- |
| `accent` | `#22D3EE` | Acción principal, foco, selección |
| `accentDim` | `#0E7490` | Variante en reposo, bordes destacados |
| `accentSurface` | `#22D3EE` al 10 % | Fondo de panel destacado, indicadores |
| `accentSecondary` | `#4C8FFF` | Series de datos, elementos informativos |

### Texto

| Token | Hex | Uso |
| --- | --- | --- |
| `textPrimary` | `#E6EDF3` | Títulos, importes, contenido principal |
| `textSecondary` | `#9AAAB8` | Texto de apoyo, iconos |
| `textMuted` | `#6B7C8C` | Etiquetas de sección, texto terciario |
| `textOnAccent` | `#04141A` | Texto sobre acento sólido |

### Semánticos

| Token | Hex | Significado |
| --- | --- | --- |
| `positive` | `#3DDC97` | Ingreso, saldo positivo, objetivo cumplido |
| `negative` | `#FF6B6B` | Gasto, saldo negativo, presupuesto excedido |
| `warning` | `#F5B84C` | Aviso, pago próximo, previsión ajustada |
| `forecast` | `#8B7FE8` | Dato proyectado o simulado, frente al real |

La distinción entre `forecast` y el resto es deliberada: el usuario debe
distinguir de un vistazo un dato registrado de una estimación.

## Espaciado y radios

Escala de 4 px en `lib/core/theme/paliko_spacing.dart`:
`xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 48`.

- Margen lateral de pantalla: `lg` (16).
- Separación entre secciones: `xl` (24).
- Radios: `sm 8` (chips, iconos pequeños), `md 12` (botones, campos),
  `lg 16` (paneles), `xl 20` (hojas modales), `pill` (barras de progreso).

## Tipografía

Fuente del sistema, sin descargas en tiempo de ejecución. La identidad se
apoya en la jerarquía, definida en `lib/core/theme/paliko_typography.dart`.

- `labelSmall` en versales con tracking amplio es el encabezado de sección.
  Es el único recurso ornamental permitido.
- Los importes usan cifras tabulares (`FontFeature.tabularFigures`) para que
  las columnas de cifras queden alineadas entre filas.
- Tres tamaños de importe: `amountLarge` (saldo destacado), `amountMedium`
  (filas de listado), `amountSmall` (desgloses y comparativas).

## Componentes base

En `lib/core/widgets/`:

| Componente | Función |
| --- | --- |
| `PalikoPanel` | Contenedor estándar. `accented: true` para el bloque principal de la pantalla; como mucho uno por vista. |
| `PalikoSectionHeader` | Etiqueta de sección en versales con acción opcional a la derecha. |
| `PalikoAmount` | Importe con color semántico según el signo y cifras tabulares. |
| `PalikoEmptyState` | Estado vacío: icono contenido, mensaje breve y una única acción. |

## Importes

Se manejan **siempre en céntimos como enteros** (`int`), nunca en `double`.
Las sumas de coma flotante acumulan error y en una app de previsión ese error
se propaga a lo largo de meses de proyección.

`lib/core/format/money.dart` centraliza el formateo y el parseo con
convenciones españolas: coma decimal, punto de millar y símbolo `€` pospuesto.
`formatSigned` usa el signo menos tipográfico (U+2212), que se alinea con las
cifras tabulares mejor que el guion.

## Pantalla de referencia

`lib/features/design_system/design_system_screen.dart` renderiza todos los
componentes con datos de muestra. Sirve para validar el estilo en el
dispositivo real. Se retirará cuando la navegación definitiva ocupe su lugar.
