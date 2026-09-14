import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Conexion a la base local, abierta bajo demanda.
///
/// El archivo vive en el directorio privado de soporte de la app. Riverpod
/// cierra la base al desechar el provider.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(
    driftDatabase(
      name: 'economy_tracker',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );
  ref.onDispose(database.close);
  return database;
});

/// Stream que late al suscribirse y despues en cada cambio de [tables].
///
/// Es la forma correcta de observar varias tablas a la vez. El atajo de
/// observar una consulta tonta con `readsFrom` no sirve: Drift cachea los
/// streams por su SQL, asi que dos sitios que usen el mismo texto comparten
/// stream y el segundo acaba escuchando las tablas del primero.
///
/// Se delega con `yield*` en vez de recorrer con `await for`, porque asi la
/// cancelacion llega al stream de origen: con `await for`, cancelar deja el
/// generador esperando para siempre.
Stream<void> watchTables(
  AppDatabase db,
  List<TableInfo<Table, dynamic>> tables,
) async* {
  yield null;
  yield* db.tableUpdates(TableUpdateQuery.onAllTables(tables));
}

/// Base de datos en memoria, para tests y renders.
AppDatabase openInMemoryDatabase() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory()));

/// Alias legible en tests que no montan interfaz.
AppDatabase openTestDatabase() => openInMemoryDatabase();
