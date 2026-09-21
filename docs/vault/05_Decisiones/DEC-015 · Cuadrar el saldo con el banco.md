---
id: DEC-015
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-21
updated: 2026-09-21
---

# DEC-015 · Cuadrar el saldo con el banco

## Decisión

Cuadrar el saldo **anota un movimiento de verdad**, con su categoría, su fecha
y su importe, y cuenta como gasto o como ingreso igual que cualquier otro. No
es una corrección invisible.

No se toca el saldo inicial de la cuenta, y no existe ningún tipo de
movimiento «neutro» que quede fuera de los informes.

## Por qué no un ajuste invisible

Era lo fácil: un tipo de movimiento aparte que mueva el saldo y no aparezca en
ninguna métrica. Pero si el banco dice que hay 11 € menos de lo que la
aplicación creía, **esos 11 € se gastaron en algo que no se anotó**. Meterlos
en un cajón que no sale en ningún informe dejaría que ese dinero se escapara
mes tras mes sin que nadie lo viera.

Es exactamente lo contrario de lo que hace esta aplicación en todo lo demás:
[[DEC-003 · Modelo financiero y ahorro]] («sobrar no es ahorrar»),
[[DEC-013 · Mes de arranque y meses parciales]] (un mes a medias no se juzga),
[[DEC-010 · Compromisos previstos, con repeticiones incluidas]] (lo vencido no
se esconde). En todas, la respuesta ha sido enseñar el dato incómodo, no
taparlo.

Puestos en su categoría —«Ajuste de saldo», creada sola la primera vez— se ve
en los informes cuánto dinero se mueve sin saber en qué. Esa cifra es
información útil: si crece, es que se está anotando mal.

## Por qué no editar el saldo inicial

Sería la otra forma fácil. Pero el saldo inicial es el ancla de toda la
historia: cambiarlo reescribe el pasado y todos los saldos de meses anteriores
dejan de cuadrar con lo que realmente pasó.

## Detalles que costaron un fallo cada uno

Todos los cogió la revisión, ninguno la prueba en dispositivo:

- **Se busca una categoría que sirva, no una que se llame así.** El guardado
  rechaza las archivadas y las que no admiten la dirección del movimiento, así
  que reutilizar a ciegas una homónima creada a mano como «solo gastos»
  reventaba justo al cuadrar hacia arriba.
- **El nombre de categoría no es único en el esquema.** Con `getSingleOrNull`,
  dos homónimas daban un «Bad state: Too many elements» incomprensible.
- **Se cuadra contra la cifra que la pantalla enseña**, no contra lo que ponga
  el campo en ese instante. Se escribe más rápido de lo que responde la base:
  confirmar mientras llegaba una respuesta anterior escribía un importe
  distinto del que se había visto y aprobado.
- **Tope de mil millones** antes de restar. No es regla de negocio: evita que
  una resta de enteros de 64 bits desborde y anote el ajuste al revés.

## Qué se descartó antes

Andy preguntó el 2026-09-21 si se podían traer los movimientos del banco
automáticamente (PSD2 / open banking). Es posible —CaixaBank expone API y hay
agregadores con acceso gratuito para las cuentas de uno mismo— pero exige un
servidor donde guardar la clave privada, lo que rompe
[[DEC-002 · Sin backend ni login]], y obliga a reautenticarse con el banco cada
180 días por normativa. **Andy lo descartó.** Cuadrar a mano cubre la misma
necesidad sin dependencias ni mantenimiento.

Relacionado: [[DEC-002 · Sin backend ni login]] ·
[[DEC-003 · Modelo financiero y ahorro]]
