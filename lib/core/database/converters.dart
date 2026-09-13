import 'package:drift/drift.dart';

import 'enums.dart';

/// Convierte un enum a su codigo de texto estable y viceversa.
///
/// Un codigo desconocido falla explicitamente en vez de degradar a un valor
/// por defecto: preferimos un error visible a corromper datos financieros.
class CodeConverter<T extends Enum> extends TypeConverter<T, String> {
  const CodeConverter(this._values, this._codeOf, this._label);

  final List<T> _values;
  final String Function(T) _codeOf;
  final String _label;

  @override
  T fromSql(String fromDb) {
    for (final value in _values) {
      if (_codeOf(value) == fromDb) return value;
    }
    throw ArgumentError.value(fromDb, _label, 'Codigo desconocido');
  }

  @override
  String toSql(T value) => _codeOf(value);

  /// Codigos validos, entrecomillados para usarlos en un CHECK de SQLite.
  String get sqlValues => _values.map((v) => "'${_codeOf(v)}'").join(', ');
}

const movementTypeConverter = CodeConverter<MovementType>(
  MovementType.values,
  _movementTypeCode,
  'MovementType',
);
const movementStatusConverter = CodeConverter<MovementStatus>(
  MovementStatus.values,
  _movementStatusCode,
  'MovementStatus',
);
const accountTypeConverter = CodeConverter<AccountType>(
  AccountType.values,
  _accountTypeCode,
  'AccountType',
);
const categoryKindConverter = CodeConverter<CategoryKind>(
  CategoryKind.values,
  _categoryKindCode,
  'CategoryKind',
);
const recurrenceFrequencyConverter = CodeConverter<RecurrenceFrequency>(
  RecurrenceFrequency.values,
  _recurrenceFrequencyCode,
  'RecurrenceFrequency',
);
const billingTypeConverter = CodeConverter<BillingType>(
  BillingType.values,
  _billingTypeCode,
  'BillingType',
);

String _movementTypeCode(MovementType v) => v.code;
String _movementStatusCode(MovementStatus v) => v.code;
String _accountTypeCode(AccountType v) => v.code;
String _categoryKindCode(CategoryKind v) => v.code;
String _recurrenceFrequencyCode(RecurrenceFrequency v) => v.code;
String _billingTypeCode(BillingType v) => v.code;

/// Fecha civil sin hora, guardada como texto `YYYY-MM-DD`.
///
/// Una fecha financiera es un dia del calendario, no un instante. Guardarla
/// como timestamp obliga a elegir una hora y hace que el dia leido dependa de
/// la zona horaria del dispositivo: medianoche UTC es el dia anterior en
/// cualquier zona con offset negativo. El texto ISO no tiene ese problema y
/// ademas ordena y compara correctamente de forma lexicografica.
///
/// Los campos `createdAt` y `updatedAt` si son instantes y siguen siendo
/// timestamps.
class CivilDateConverter extends TypeConverter<DateTime, String> {
  const CivilDateConverter();

  @override
  DateTime fromSql(String fromDb) {
    final parts = fromDb.split('-');
    if (parts.length != 3) {
      throw ArgumentError.value(fromDb, 'fecha', 'Formato esperado YYYY-MM-DD');
    }
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  String toSql(DateTime value) => format(value);

  /// Representacion textual de un dia, para comparar en consultas SQL.
  static String format(DateTime value) {
    final utc = value.isUtc ? value : value.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year.toString().padLeft(4, '0')}-$month-$day';
  }
}

const civilDateConverter = CivilDateConverter();
