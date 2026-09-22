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
/// stream y el segundo acaba escuchando las tablas del primero (DEC-008).
///
/// **El orden de las dos cosas importa, y por eso esto ya no es un `async*`
/// con un `yield null` delante.** En un generador, el `yield` cede el control
/// hasta que el consumidor procesa el valor, y el consumidor de aqui es
/// siempre un `asyncMap` que se va a la base. Mientras dura esa primera
/// carga, el generador aun no ha llegado al `yield*` y **no esta suscrito a
/// las tablas**: cualquier escritura que caiga en esa ventana no dispara
/// nada, y la vista se queda con los datos de antes hasta el siguiente
/// cambio. Suscribiendo primero y latiendo despues, la ventana no existe.
Stream<void> watchTables(
  AppDatabase db,
  List<TableInfo<Table, dynamic>> tables,
) {
  return Stream<void>.multi((controller) {
    final subscription = db
        .tableUpdates(TableUpdateQuery.onAllTables(tables))
        .listen(
          (_) => controller.add(null),
          onError: controller.addError,
          onDone: controller.close,
        );

    controller.onCancel = subscription.cancel;
    // La pausa no se reenvia a proposito: el controlador guarda los pocos
    // avisos que lleguen mientras el consumidor esta ocupado recalculando,
    // que es exactamente lo que no debe perderse.
    controller.add(null);
  });
}

/// Base de datos en memoria, para tests y renders.
AppDatabase openInMemoryDatabase() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory()));

/// Alias legible en tests que no montan interfaz.
AppDatabase openTestDatabase() => openInMemoryDatabase();
