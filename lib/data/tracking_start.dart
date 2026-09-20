import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/utils/dates.dart';

/// Que tan cubierto esta un mes por el seguimiento.
///
/// Sirve para no juzgar meses que la aplicacion no vivio enteros. Un mes con
/// −227 € porque se empezo a usar el dia 14 no es un mes malo: es un mes a
/// medias, y pintarlo como fracaso es mentir sobre el esfuerzo de alguien.
enum MonthCoverage {
  /// Anterior al seguimiento: no habia aplicacion, no hay nada que contar.
  untracked,

  /// Se empezo a usar a mitad: faltan los dias de antes.
  partial,

  /// El mes corriente, que todavia no ha terminado.
  inProgress,

  /// Mes cerrado y cubierto de principio a fin. El unico que se puede juzgar.
  complete;

  /// Si tiene sentido decir «cumpliste» o «no cumpliste» el objetivo.
  bool get isComparable => this == MonthCoverage.complete;

  bool get isVisible => this != MonthCoverage.untracked;
}

/// Desde cuando hay seguimiento de verdad.
///
/// Se toma el primero de dos datos, el que sea mas antiguo:
///
/// - el dia en que la aplicacion se abrio por primera vez, que se guarda en
///   preferencias la primera vez que se pregunta;
/// - el primer movimiento que hay en la base.
///
/// Hacen falta los dos. Solo el primero perderia la historia al restaurar una
/// copia en un movil nuevo, donde la aplicacion es nueva pero los datos no.
/// Solo el segundo daria por no cubierto un mes que se vivio entero sin gastar
/// nada.
class TrackingStart {
  const TrackingStart(this.firstDay);

  /// Primer dia con seguimiento, o `null` si no hay nada todavia.
  final DateTime? firstDay;

  DateTime? get firstMonth =>
      firstDay == null ? null : Dates.monthStart(firstDay!);

  /// Si el primer mes se empezo a mitad.
  bool get startedMidMonth => firstDay != null && firstDay!.day > 1;

  /// El de dos fechas que sea mas antiguo, tolerando nulos.
  factory TrackingStart.earliestOf(DateTime? a, DateTime? b) {
    if (a == null) return TrackingStart(b == null ? null : Dates.day(b));
    if (b == null) return TrackingStart(Dates.day(a));
    return TrackingStart(Dates.day(a.isBefore(b) ? a : b));
  }

  MonthCoverage coverageOf(DateTime month, DateTime today) {
    final start = firstMonth;
    if (start == null) return MonthCoverage.untracked;

    final target = Dates.monthStart(month);
    if (target.isBefore(start)) return MonthCoverage.untracked;
    if (target.isAtSameMomentAs(Dates.monthStart(today))) {
      return MonthCoverage.inProgress;
    }
    if (target.isAtSameMomentAs(start) && startedMidMonth) {
      return MonthCoverage.partial;
    }
    return MonthCoverage.complete;
  }

  /// Texto corto que explica por que un mes no se juzga.
  String? noteFor(DateTime month, DateTime today) =>
      switch (coverageOf(month, today)) {
        MonthCoverage.inProgress => 'en curso',
        MonthCoverage.partial => 'desde el ${firstDay!.day}',
        _ => null,
      };
}

/// Guarda y recupera el dia del primer arranque.
class TrackingStartService {
  TrackingStartService(this._db, this._preferences);

  final AppDatabase _db;
  final SharedPreferencesAsync _preferences;

  static const _key = 'tracking_first_day';

  /// Deja anotado el primer arranque si no lo estaba, y lo devuelve.
  ///
  /// Se anota de forma perezosa, la primera vez que alguien pregunta. No hace
  /// falta un gancho en el arranque: el resultado es el mismo y no hay un
  /// sitio mas donde se pueda olvidar.
  Future<DateTime?> ensureRecorded(DateTime today) async {
    try {
      final stored = await _preferences.getString(_key);
      final parsed = stored == null ? null : DateTime.tryParse(stored);
      if (parsed != null) return Dates.day(parsed);

      final day = Dates.day(today);
      await _preferences.setString(_key, isoDay(day));
      return day;
    } catch (_) {
      // Las preferencias son una comodidad, no la fuente de verdad. Si no se
      // pueden leer, se sigue con lo que digan los datos: perder el historico
      // entero por esto seria peor que quedarse sin la fecha de arranque.
      return null;
    }
  }

  /// Fecha del movimiento mas antiguo, por su fecha real o prevista.
  Future<DateTime?> earliestMovementDay() async {
    final rows = await (_db.select(
      _db.transactions,
    )..where((t) => t.isDeleted.equals(false))).get();

    DateTime? earliest;
    for (final row in rows) {
      final date = row.actualDate ?? row.expectedDate;
      if (earliest == null || date.isBefore(earliest)) earliest = date;
    }
    return earliest;
  }

  Future<TrackingStart> resolve(DateTime today) async {
    final recorded = await ensureRecorded(today);
    final fromData = await earliestMovementDay();
    return TrackingStart.earliestOf(recorded, fromData);
  }
}

final trackingStartServiceProvider = Provider<TrackingStartService>(
  (ref) => TrackingStartService(
    ref.watch(appDatabaseProvider),
    SharedPreferencesAsync(),
  ),
);

/// Desde cuando hay seguimiento, recalculado si cambian los movimientos.
///
/// Observa la tabla porque restaurar una copia puede traer historia mas
/// antigua que el primer arranque de esta instalacion.
final trackingStartProvider = StreamProvider<TrackingStart>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = ref.watch(trackingStartServiceProvider);

  return watchTables(db, [
    db.transactions,
  ]).asyncMap((_) => service.resolve(Dates.today()));
});
