# Nota de contexto del contenedor

Este contenedor en la nube tiene **dos repos clonados**, no solo este:

- `/home/user/Economy-Tracker-APK-` (este repo) — el directorio de trabajo
  primario de la sesión, pero **no** es donde se hace el trabajo activo salvo
  que Andy lo diga explícitamente.
- `/home/user/daily-deck` (`Shirobe95/daily-deck`, branch
  `claude/diseno-limpio-hub`) — **aquí es donde se trabaja siempre**, salvo
  que Andy pida algo específico de Economy Tracker.

Si una tarea llega sin repo explícito, o tras un reinicio de memoria/resumen
de conversación parece ambigua, asume Daily Deck y comprueba primero
`/home/user/daily-deck` (en particular `docs/vault/05_Decisiones/` para el
historial de decisiones DECK-DEC-XXX) antes de preguntar o de asumir que es
sobre este repo.
