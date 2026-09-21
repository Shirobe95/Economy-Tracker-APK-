---
id: DEC-014
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-21
updated: 2026-09-21
---

# DEC-014 · Teclado propio para el PIN

## Decisión

El PIN se teclea siempre con un teclado numérico propio —`PinPad`— y lo único
que se ve por pantalla son puntos que se van llenando. Lo usan por igual la
pantalla de bloqueo y los diálogos de poner o cambiar el PIN.

## Qué lo provocó

Andy, el 2026-09-21: *«al entrar el pin no se vean puntos, la línea de
escritura y los números que estamos entrando todo al mismo tiempo»*.

Era un `TextField` con `obscureText`. Eso pinta a la vez tres cosas: los puntos
de relleno, la línea de escritura, y —durante un instante en Android— el dígito
recién pulsado en claro. Con eso el PIN queda medio a la vista de quien mire
por encima del hombro, que es exactamente el ataque contra el que sirve un PIN.

De paso resuelve dos cosas más:

- **El teclado del sistema peleaba con el diálogo de huella**, que sale solo al
  abrir la aplicación. Había un apaño feo: quitar el foco automático cuando la
  huella estaba activada. Ya no hace falta.
- **El teclado del sistema tapaba media pantalla** y movía todo al aparecer.
  Este ocupa un sitio fijo.

## Detalles que costaron un fallo cada uno

- **Las teclas se adaptan al ancho.** Con tamaño fijo, el teclado medía 252 px
  y dentro de un `AlertDialog` en un móvil de 360 dp solo hay 232: las teclas
  de los lados se salían y no se podían pulsar. Lo cogió la revisión, no la
  prueba en dispositivo. Hay test a 360 dp.
- **El hueco del mensaje tiene altura mínima, no fija.** Con altura fija, un
  aviso de huella de tres líneas se veía recortado a un trozo de frase. Con
  altura libre, un «PIN incorrecto» empujaba el teclado y movía la tecla que
  ibas a pulsar. Mínimo de una línea: ni salta ni recorta.
- **El temblor se dispara con un contador, no con un booleano.** Dos fallos
  seguidos tienen que temblar dos veces.

## Confirmar es explícito

No se valida sola al llegar a cierta longitud. El PIN admite de 4 a 8 dígitos y
la aplicación no guarda cuál es la suya —guardarla sería una pista de más—, así
que no hay forma de saber cuándo está completo sin preguntarlo.

Relacionado: [[DEC-011 · Huella como atajo del PIN]] ·
[[ECON-000K · Seguridad backup y release Android]]
