import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';

/// Error al leer o aplicar una copia de seguridad.
class BackupError implements Exception {
  const BackupError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Resumen de lo que contiene un archivo de copia, para poder enseñarlo
/// antes de tocar nada.
class BackupPreview {
  const BackupPreview({
    required this.schemaVersion,
    required this.exportedAt,
    required this.counts,
  });

  final int schemaVersion;
  final DateTime exportedAt;

  /// Numero de filas por tabla.
  final Map<String, int> counts;

  int get totalRows => counts.values.fold(0, (a, b) => a + b);
}

/// Copia de seguridad completa de la base local.
///
/// Sin backend ni sincronizacion (DEC-002), esto es lo unico que hay entre
/// los datos y un cambio de movil. El formato es JSON legible a proposito:
/// si algun dia la aplicacion no arranca, los datos se siguen pudiendo leer.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Orden de exportacion e importacion.
  ///
  /// Importa: los padres van antes que quien los referencia, o las claves
  /// foraneas rechazarian la insercion.
  static const List<String> tableOrder = [
    'accounts',
    'categories',
    'clients',
    'projects',
    'salary_sources',
    'savings_goals',
    'recurring_rules',
    'transactions',
  ];

  TableInfo<Table, dynamic> _tableByName(String name) {
    final table = _db.allTables.where((t) => t.actualTableName == name);
    if (table.isEmpty) {
      throw BackupError('La copia menciona una tabla desconocida: $name');
    }
    return table.first;
  }

  /// Serializa toda la base a JSON.
  Future<String> export() async {
    final data = <String, List<Map<String, Object?>>>{};

    for (final name in tableOrder) {
      final rows = await _db.customSelect('SELECT * FROM $name').get();
      // Los valores que devuelve SQLite ya son tipos JSON: este esquema no
      // tiene columnas binarias.
      data[name] = [for (final row in rows) row.data];
    }

    return const JsonEncoder.withIndent('  ').convert({
      'format': 'economy_tracker_backup',
      'formatVersion': 1,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    });
  }

  /// Lee un archivo de copia sin aplicarlo.
  ///
  /// Sirve para enseñar qué hay dentro antes de sustituir nada: una
  /// restauracion borra los datos actuales y no se puede deshacer.
  BackupPreview preview(String content) {
    final decoded = _decode(content);
    final data = decoded['data'] as Map<String, dynamic>;

    return BackupPreview(
      schemaVersion: decoded['schemaVersion'] as int,
      exportedAt:
          DateTime.tryParse(decoded['exportedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      counts: {
        for (final name in tableOrder)
          name: (data[name] as List<dynamic>? ?? const []).length,
      },
    );
  }

  /// Sustituye el contenido de la base por el de la copia.
  ///
  /// Todo o nada: si una sola fila falla, la transaccion se deshace y los
  /// datos actuales quedan intactos.
  Future<void> restore(String content) async {
    final decoded = _decode(content);
    final data = decoded['data'] as Map<String, dynamic>;

    await _db.transaction(() async {
      // Las claves foraneas se apagan durante la restauracion y se vuelven a
      // comprobar al final: insertar en orden no basta cuando una tabla se
      // referencia a si misma, como categories con su padre.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');

      for (final name in tableOrder.reversed) {
        await _db.customStatement('DELETE FROM $name');
      }

      for (final name in tableOrder) {
        final rows = data[name] as List<dynamic>? ?? const [];
        final table = _tableByName(name);

        for (final row in rows) {
          await _insertRow(table, name, row as Map<String, dynamic>);
        }
      }
    });
  }

  Map<String, dynamic> _decode(String content) {
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const BackupError('El archivo no es un JSON valido.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const BackupError('El archivo no tiene el formato esperado.');
    }
    if (decoded['format'] != 'economy_tracker_backup') {
      throw const BackupError(
        'Este archivo no es una copia de Economy Tracker.',
      );
    }
    if (decoded['data'] is! Map<String, dynamic>) {
      throw const BackupError('La copia no contiene datos.');
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int) {
      throw const BackupError('La copia no dice de que version de datos es.');
    }
    if (schemaVersion > _db.schemaVersion) {
      throw BackupError(
        'La copia es de una version mas nueva de la aplicacion '
        '(datos v$schemaVersion, esta app usa v${_db.schemaVersion}). '
        'Actualiza la aplicacion antes de restaurarla.',
      );
    }

    return decoded;
  }

  /// Inserta una fila de la copia con SQL parametrizado.
  ///
  /// Los nombres de columna vienen de un archivo que puede haber editado
  /// cualquiera, asi que se comprueban contra el esquema antes de meterlos
  /// en la consulta: nunca se interpola texto externo sin validar.
  Future<void> _insertRow(
    TableInfo<Table, dynamic> table,
    String tableName,
    Map<String, dynamic> row,
  ) async {
    final columns = <String>[];
    final values = <Object?>[];

    for (final entry in row.entries) {
      final info = table.columnsByName[entry.key];
      if (info == null) {
        throw BackupError(
          'La copia trae una columna que no existe en $tableName: '
          '${entry.key}',
        );
      }
      columns.add(info.name);
      values.add(_decodeValue(info, entry.value));
    }

    if (columns.isEmpty) return;

    final placeholders = List.filled(columns.length, '?').join(', ');
    await _db.customStatement(
      'INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)',
      values,
    );
  }

  /// Convierte un valor del JSON al tipo que espera su columna.
  ///
  /// JSON no distingue entero de decimal: un importe exportado como 1000
  /// puede volver como 1000.0 y romper una columna entera.
  Object? _decodeValue(GeneratedColumn<Object> column, Object? value) {
    if (value == null) return null;
    if (column is GeneratedColumn<int> && value is double) {
      return value.toInt();
    }
    if (column is GeneratedColumn<bool> && value is bool) {
      return value ? 1 : 0;
    }
    return value;
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(appDatabaseProvider)),
);
