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

  /// Version 1: esquema financiero completo con las ocho tablas.
  ///
  /// Al cambiarlo: subir version, anadir un paso explicito en
  /// [migration], conservar el snapshot en `drift_schemas/` y probar la
  /// migracion con datos previos. Nunca sustituirlo por borrar el archivo.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
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
