import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Base de datos local de la aplicacion.
///
/// Local-first (DEC-001, DEC-002): un unico archivo SQLite en el
/// almacenamiento privado de la app. Sin backend, sincronizacion ni cifrado.
@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Clients,
    Projects,
    SalarySources,
    SavingsGoals,
    RecurringRules,
    Transactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// v1: esquema financiero con las ocho tablas.
  /// v2: `salary_sources.payment_day`, para poder prever cuando entra una
  ///     nomina y no solo cuanto.
  /// v3: `savings_goals.kind`, para distinguir un objetivo por importe de uno
  ///     mensual, y unicidad de (regla, fecha prevista) en movimientos, que
  ///     es lo que permite marcar una ocurrencia recurrente como pagada sin
  ///     arriesgarse a duplicarla.
  ///
  /// Al cambiarlo: subir version, anadir un paso explicito en [migration] y
  /// probarlo con datos previos. Nunca sustituirlo por borrar el archivo.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Una base de una version mas nueva que la aplicacion no se toca: pasa
      // si alguien instala un APK anterior encima. Abrirla con un esquema
      // que no conocemos es la forma rapida de corromper datos que quiza no
      // tengan copia.
      if (from > to) {
        throw UnsupportedError(
          'Estos datos son de una version mas nueva de la aplicacion '
          '(datos v$from, esta app usa v$to). Actualiza la aplicacion en vez '
          'de abrirlos con esta.',
        );
      }

      if (from <= 1) {
        // Se recrea la tabla en vez de usar ALTER TABLE ADD COLUMN: SQLite no
        // sabe anadir un CHECK a una tabla existente, y con ADD COLUMN una
        // base migrada acabaria con menos restricciones que una recien
        // instalada.
        //
        // `newColumns` es obligatorio para la columna que aun no existe: sin
        // el, Drift la copia por nombre y SQLite resuelve las comillas dobles
        // de una columna inexistente como una cadena de texto, metiendo
        // 'payment_day' en una columna numerica.
        //
        // TableMigration sigue marcada como experimental en Drift, pero es la
        // unica forma de recrear la tabla conservando sus CHECK.
        await m.alterTable(
          // ignore: experimental_member_use
          TableMigration(salarySources, newColumns: [salarySources.paymentDay]),
        );
      }

      if (from <= 2) {
        // Los objetivos ganan tipo: lo que ya existia es de importe, que es
        // lo unico que se podia crear hasta ahora.
        await m.alterTable(
          // ignore: experimental_member_use
          TableMigration(savingsGoals, newColumns: [savingsGoals.kind]),
        );

        // Antes de exigir unicidad hay que quitar los duplicados que
        // pudieran existir, o el indice no se deja crear. Se conserva el
        // movimiento mas antiguo de cada par.
        await customStatement('''
          DELETE FROM transactions
          WHERE recurring_rule_id IS NOT NULL
            AND id NOT IN (
              SELECT MIN(id) FROM transactions
              WHERE recurring_rule_id IS NOT NULL
              GROUP BY recurring_rule_id, expected_date
            )
        ''');
        await m.createIndex(idxTxRuleOccurrence);
      }

      if (to > schemaVersion || from > schemaVersion) {
        throw UnsupportedError(
          'Migracion $from -> $to no implementada. '
          'Anadir el paso explicito antes de subir schemaVersion.',
        );
      }
    },
    beforeOpen: (details) async {
      // Las claves foraneas del esquema solo se aplican si SQLite las tiene
      // activadas; por defecto vienen apagadas en cada conexion.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
