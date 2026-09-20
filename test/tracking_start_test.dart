import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/tracking_start.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Desde cuando se puede juzgar un mes.
///
/// El fallo que arregla: alguien que instala la aplicacion el dia 14 veia su
/// primer mes en rojo, con un neto negativo que solo significaba «faltan
/// catorce dias y el sueldo todavia no ha entrado». Y los meses de antes de
/// instalarla salian a cero con el icono de objetivo incumplido.
void main() {
  group('reparto de meses', () {
    final hoy = DateTime.utc(2026, 9, 20);

    test('el mes en que se empezo a mitad es parcial', () {
      final start = TrackingStart(DateTime.utc(2026, 7, 14));

      expect(
        start.coverageOf(DateTime.utc(2026, 7), hoy),
        MonthCoverage.partial,
      );
      expect(start.noteFor(DateTime.utc(2026, 7), hoy), 'desde el 14');
    });

    test('empezar el dia 1 cubre el mes entero', () {
      final start = TrackingStart(DateTime.utc(2026, 7));

      expect(
        start.coverageOf(DateTime.utc(2026, 7), hoy),
        MonthCoverage.complete,
      );
      expect(start.noteFor(DateTime.utc(2026, 7), hoy), isNull);
    });

    test('el mes corriente esta en curso, aunque se cubriera entero', () {
      final start = TrackingStart(DateTime.utc(2026, 1));

      expect(
        start.coverageOf(DateTime.utc(2026, 9), hoy),
        MonthCoverage.inProgress,
      );
      expect(start.noteFor(DateTime.utc(2026, 9), hoy), 'en curso');
    });

    test('los meses de antes de instalarla no se ensenan', () {
      final start = TrackingStart(DateTime.utc(2026, 7, 14));

      for (final mes in [
        DateTime.utc(2026, 4),
        DateTime.utc(2026, 5),
        DateTime.utc(2026, 6),
      ]) {
        expect(start.coverageOf(mes, hoy), MonthCoverage.untracked);
        expect(start.coverageOf(mes, hoy).isVisible, isFalse);
      }
    });

    test('solo un mes cerrado y entero se puede juzgar', () {
      final start = TrackingStart(DateTime.utc(2026, 7, 14));

      expect(start.coverageOf(DateTime.utc(2026, 8), hoy).isComparable, isTrue);
      expect(
        start.coverageOf(DateTime.utc(2026, 7), hoy).isComparable,
        isFalse,
      );
      expect(
        start.coverageOf(DateTime.utc(2026, 9), hoy).isComparable,
        isFalse,
      );
    });

    test('el caso de Andy: empezo el 14 y es el mes corriente', () {
      // Instalo la aplicacion a mitad de septiembre y su primer movimiento es
      // del 14. Septiembre no puede salir como mes fallado.
      final start = TrackingStart(DateTime.utc(2026, 9, 14));

      final coverage = start.coverageOf(DateTime.utc(2026, 9), hoy);
      expect(coverage, MonthCoverage.inProgress);
      expect(coverage.isComparable, isFalse);
      expect(coverage.isVisible, isTrue);
    });

    test('sin nada todavia, ningun mes cuenta', () {
      final start = TrackingStart(null);

      expect(
        start.coverageOf(DateTime.utc(2026, 9), hoy),
        MonthCoverage.untracked,
      );
    });
  });

  group('de donde sale la fecha', () {
    test('gana la mas antigua de las dos', () {
      final start = TrackingStart.earliestOf(
        DateTime.utc(2026, 9, 20),
        DateTime.utc(2026, 3, 5),
      );

      expect(start.firstDay, DateTime.utc(2026, 3, 5));
    });

    test('con una sola, esa', () {
      expect(
        TrackingStart.earliestOf(DateTime.utc(2026, 9, 20), null).firstDay,
        DateTime.utc(2026, 9, 20),
      );
      expect(
        TrackingStart.earliestOf(null, DateTime.utc(2026, 3, 5)).firstDay,
        DateTime.utc(2026, 3, 5),
      );
    });

    test('sin ninguna, nada', () {
      expect(TrackingStart.earliestOf(null, null).firstDay, isNull);
    });
  });

  group('servicio', () {
    late AppDatabase db;
    late TrackingStartService service;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      db = openTestDatabase();
      service = TrackingStartService(db, SharedPreferencesAsync());
    });

    tearDown(() => db.close());

    Future<void> insertMovement(DateTime date) async {
      final accountId = await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Cuenta ${date.day}',
              type: AccountType.bank,
              currency: 'EUR',
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.pagado,
              concept: 'Gasto',
              amount: 1000,
              currency: 'EUR',
              accountId: accountId,
              expectedDate: date,
              actualDate: Value(date),
            ),
          );
    }

    test('si las preferencias fallan, se sigue con los datos', () async {
      // Sin plataforma de preferencias, leerlas lanza. El historico no puede
      // desaparecer por eso: se cae a la fecha del primer movimiento.
      SharedPreferencesAsyncPlatform.instance = null;
      await insertMovement(DateTime.utc(2026, 3, 5));

      final start = await service.resolve(DateTime.utc(2026, 9, 20));

      expect(start.firstDay, DateTime.utc(2026, 3, 5));
    });

    test('el primer arranque se anota una vez y no se mueve', () async {
      final first = await service.ensureRecorded(DateTime.utc(2026, 9, 20));
      final second = await service.ensureRecorded(DateTime.utc(2026, 12, 3));

      expect(first, DateTime.utc(2026, 9, 20));
      // Preguntar otro dia no reescribe el arranque.
      expect(second, DateTime.utc(2026, 9, 20));
    });

    test('sin movimientos, el arranque es el primer dia', () async {
      final start = await service.resolve(DateTime.utc(2026, 9, 20));

      expect(start.firstDay, DateTime.utc(2026, 9, 20));
    });

    test('restaurar historia mas antigua adelanta el arranque', () async {
      // Instalacion nueva en un movil nuevo, pero los datos vienen de antes.
      await service.ensureRecorded(DateTime.utc(2026, 9, 20));
      await insertMovement(DateTime.utc(2026, 3, 5));

      final start = await service.resolve(DateTime.utc(2026, 9, 20));

      expect(start.firstDay, DateTime.utc(2026, 3, 5));
    });

    test('un movimiento posterior no retrasa el arranque', () async {
      await service.ensureRecorded(DateTime.utc(2026, 9, 20));
      await insertMovement(DateTime.utc(2026, 10, 2));

      final start = await service.resolve(DateTime.utc(2026, 9, 20));

      // Se vivio septiembre entero sin gastar nada; eso no borra el mes.
      expect(start.firstDay, DateTime.utc(2026, 9, 20));
    });
  });
}
