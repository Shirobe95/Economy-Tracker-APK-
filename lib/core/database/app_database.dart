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
  ///
  /// Al cambiarlo: subir version, anadir un paso explicito en [migration] y
  /// probarlo con datos previos. Nunca sustituirlo por borrar el archivo.
  @override
  int get schemaVersion => 2;

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

      if (from == 1 && to == 2) {
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
        return;
      }

      throw UnsupportedError(
        'Migracion $from -> $to no implementada. '
        'Anadir el paso explicito antes de subir schemaVersion.',
      );
    },
    beforeOpen: (details) async {
      // Las claves foraneas del esquema solo se aplican si SQLite las tiene
      // activadas; por defecto vienen apagadas en cada conexion.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
