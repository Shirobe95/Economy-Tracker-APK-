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

/// Base de datos en memoria, para tests y renders.
AppDatabase openInMemoryDatabase() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory()));

/// Alias legible en tests que no montan interfaz.
AppDatabase openTestDatabase() => openInMemoryDatabase();
