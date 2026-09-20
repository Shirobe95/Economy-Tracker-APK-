---
id: DEC-012
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-20
updated: 2026-09-20
---

# DEC-012 · La copia se guarda como archivo, no solo se comparte

## Decisión

«Guardar copia en el móvil» pasa a ser la acción principal, con un selector del
sistema que deja el archivo donde Andy diga, con su nombre y su extensión.
«Compartir copia» sigue existiendo, pero como acción secundaria.

## Qué lo provocó

Andy exportó una copia y la compartió por WhatsApp. Le llegó como
`DOC-20260920-WA0018._`: renombrada y **sin extensión**. Así no se puede volver
a elegir para restaurar, ni la reconoce ningún visor. Tuvo que pasarla por esta
conversación para recuperar un `.json` usable.

Compartir era la única vía de salida que tenía la aplicación. Eso convertía la
copia de seguridad —lo único que hay entre los datos y un cambio de móvil
(DEC-002)— en algo que una aplicación de mensajería podía dejar inservible sin
avisar. No era un detalle cosmético.

La pantalla avisa además de que un archivo compartido puede llegar sin su
extensión.

## El fallo de los acentos, en el mismo viaje

Al restaurar, «Suscripción» entraba como «SuscripciÃ³n». El restaurador leía los
bytes con `String.fromCharCodes`, que trata **cada byte como un carácter**: eso
es Latin-1, no UTF-8. La «ó» son dos bytes (`C3 B3`) y salían como dos
caracteres de basura.

Corregido con `utf8.decode` en `BackupService.decodeBytes`, que además:

- se salta el BOM que añaden algunos editores de Windows, porque `jsonDecode`
  no admite nada delante de la llave inicial;
- si el archivo no es UTF-8, lo dice con un mensaje claro en vez de meter
  basura en la base.

Probado con el viaje completo —exportar, pasar por bytes como hace el selector,
restaurar— comprobando que «Futón Espai» y «Suscripción» sobreviven intactos.

Relacionado: [[DEC-002 · Sin backend ni login]] ·
[[ECON-000K · Seguridad backup y release Android]]
