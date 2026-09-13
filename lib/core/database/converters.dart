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
