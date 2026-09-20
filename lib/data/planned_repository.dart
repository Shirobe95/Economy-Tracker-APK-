import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import 'recurrence_schedule.dart';

/// Un compromiso futuro: dinero que todavia no se ha movido.
///
/// Puede venir de dos sitios y la pantalla no deberia tener que distinguirlos
/// para pintarlos:
///
/// - un movimiento anotado que sigue pendiente o previsto;
/// - una ocurrencia de una regla recurrente que aun no se ha registrado.
///
/// El segundo caso es el que faltaba: las reglas no materializan filas, asi
/// que un alquiler de 850 todos los meses no aparecia en ningun listado de lo
/// que queda por pagar. Quien mira cuanto le queda del mes no distingue entre
/// «lo apunte a mano» y «se repite solo»: las dos cosas son dinero que se va.
class PlannedItem {
  const PlannedItem({
    required this.date,
    required this.concept,
    required this.amount,
    required this.type,
    required this.currency,
    this.movement,
    this.rule,
  });

  /// Fecha prevista, normalizada a dia.
  final DateTime date;
  final String concept;
  final int amount;
  final MovementType type;
  final String currency;

  /// Fila ya existente, si el compromiso esta anotado.
  final Transaction? movement;

  /// Regla de la que sale, si es una repeticion todavia sin anotar.
  final RecurringRule? rule;

  /// Sale de una regla y no tiene fila propia todavia.
  bool get isProjected => movement == null;

  /// Se identifica de forma estable entre recargas, para claves de lista.
  String get key => movement != null
      ? 'tx-${movement!.id}'
      : 'rule-${rule!.id}-${isoDay(date)}';

  bool isOverdue(DateTime today) => date.isBefore(Dates.day(today));

  PlannedItem copyWith({int? amount}) => PlannedItem(
    date: date,
    concept: concept,
    amount: amount ?? this.amount,
    type: type,
    currency: currency,
    movement: movement,
    rule: rule,
  );
}

/// Ventana de compromisos que se consulta.
class PlannedWindow {
  const PlannedWindow({required this.from, required this.to});

  /// Desde el primer dia del mes pasado hasta [months] meses por delante.
  ///
  /// Se mira tambien hacia atras a proposito: un recibo que vencio hace una
  /// semana y sigue sin pagar es justo lo que hay que ver, y esconderlo por
  /// estar en el pasado es como no tenerlo.
  ///
  /// Dos meses por delante y no mas: con una ventana larga, una sola regla
  /// mensual llena la lista de Inicio con el mismo concepto repetido y tapa
  /// todo lo demas.
  factory PlannedWindow.around(DateTime today, {int months = 2}) {
    final month = Dates.monthStart(today);
    return PlannedWindow(
      from: DateTime.utc(month.year, month.month - 1),
      to: DateTime.utc(month.year, month.month + months),
    );
  }

  /// Un mes natural completo.
  factory PlannedWindow.month(DateTime month) => PlannedWindow(
    from: Dates.monthStart(month),
    to: Dates.nextMonthStart(month),
  );

  /// Inclusivo.
  final DateTime from;

  /// Exclusivo.
  final DateTime to;

  bool contains(DateTime date) => !date.isBefore(from) && date.isBefore(to);
}

/// Compromisos previstos, juntando movimientos pendientes y repeticiones.
class PlannedRepository {
  PlannedRepository(this._db);

  final AppDatabase _db;

  Stream<List<PlannedItem>> watchPlanned(PlannedWindow window) {
    return watchTables(_db, [
      _db.transactions,
      _db.recurringRules,
    ]).asyncMap((_) => _load(window));
  }

  Future<List<PlannedItem>> _load(PlannedWindow window) async {
    final movements = await (_db.select(
      _db.transactions,
    )..where((t) => t.isDeleted.equals(false))).get();
    final rules = await (_db.select(
      _db.recurringRules,
    )..where((r) => r.isActive.equals(true))).get();

    final items = <PlannedItem>[];

    // Lo que ya esta anotado y sigue sin ocurrir.
    for (final movement in movements) {
      if (movement.status.isRealised) continue;
      if (movement.status == MovementStatus.cancelado) continue;
      if (!window.contains(movement.expectedDate)) continue;

      items.add(
        PlannedItem(
          date: movement.expectedDate,
          concept: movement.concept,
          amount: movement.amount,
          type: movement.type,
          currency: movement.currency,
          movement: movement,
        ),
      );
    }

    // Que ocurrencias de regla tienen ya una fila, pagada o no. Las que la
    // tienen ya han entrado arriba (o estan cobradas): anadirlas otra vez
    // seria contar el mismo recibo dos veces.
    final anotadas = <String>{
      for (final movement in movements)
        if (movement.recurringRuleId != null)
          '${movement.recurringRuleId}|${isoDay(movement.expectedDate)}',
    };

    for (final rule in rules) {
      final schedule = RecurrenceSchedule.fromRule(rule);
      for (final date in schedule.between(from: window.from, to: window.to)) {
        if (anotadas.contains('${rule.id}|${isoDay(date)}')) continue;

        items.add(
          PlannedItem(
            date: date,
            concept: rule.concept,
            amount: rule.amount,
            type: rule.type,
            currency: rule.currency,
            rule: rule,
          ),
        );
      }
    }

    items.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.concept.compareTo(b.concept);
    });
    return items;
  }
}

final plannedRepositoryProvider = Provider<PlannedRepository>(
  (ref) => PlannedRepository(ref.watch(appDatabaseProvider)),
);

/// Compromisos de los proximos meses, para Inicio.
final upcomingPlannedProvider = StreamProvider<List<PlannedItem>>(
  (ref) => ref
      .watch(plannedRepositoryProvider)
      .watchPlanned(PlannedWindow.around(Dates.today())),
);

/// Compromisos de un mes concreto, para el listado de gastos.
final monthlyPlannedProvider =
    StreamProvider.family<List<PlannedItem>, DateTime>(
      (ref, month) => ref
          .watch(plannedRepositoryProvider)
          .watchPlanned(PlannedWindow.month(month)),
    );
