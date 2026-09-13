import 'package:drift/drift.dart';

import 'converters.dart';

/// Columnas comunes a todas las tablas.
///
/// Los timestamps se inicializan al insertar; quien edite una fila debe
/// actualizar `updatedAt` explicitamente.
mixin _Timestamps on Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Codigo de moneda ISO de tres letras mayusculas.
///
/// No hay catalogo ISO, cambio de divisas ni suma entre monedas distintas.
const String _currencyCheck = "currency GLOB '[A-Z][A-Z][A-Z]'";

/// Cuentas donde vive el dinero.
///
/// `initialBalance` es firmado: permite arrancar con una cuenta en negativo.
/// El saldo actual no se almacena, se deriva de los movimientos reales.
class Accounts extends Table with _Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 80)();

  TextColumn get type => text().map(accountTypeConverter)();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  IntColumn get initialBalance => integer().withDefault(const Constant(0))();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    // Referenciada por la clave compuesta (cuenta, moneda) de movimientos y
    // reglas: impide registrar un importe en una moneda distinta de la cuenta.
    'UNIQUE (id, currency)',
    'CHECK ($_currencyCheck)',
    'CHECK (type IN (${accountTypeConverter.sqlValues}))',
  ];
}

/// Clasificacion de movimientos, con jerarquia opcional de un nivel o mas.
@TableIndex(name: 'idx_categories_parent', columns: {#parentId})
class Categories extends Table with _Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 60)();

  TextColumn get kind => text().map(categoryKindConverter)();

  IntColumn get parentId => integer().nullable().references(Categories, #id)();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'CHECK (kind IN (${categoryKindConverter.sqlValues}))',
    // Autoparentesco rechazado. Los ciclos de varios niveles se validan en
    // el servicio de edicion, no en SQLite.
    'CHECK (parent_id IS NULL OR parent_id <> id)',
  ];
}

/// Cliente para el que se ejecutan proyectos.
class Clients extends Table with _Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 80)();

  TextColumn get contact => text().nullable().withLength(max: 160)();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

/// Proyecto de un cliente. El importe orientativo es una referencia, nunca
/// sustituye al importe real de los cobros.
@TableIndex(name: 'idx_projects_client', columns: {#clientId})
class Projects extends Table with _Timestamps {
  IntColumn get clientId => integer().references(Clients, #id)();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get billingType => text().nullable().map(billingTypeConverter)();

  IntColumn get estimatedAmount => integer().nullable()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => [
    // Permite exigir desde transactions que el par (proyecto, cliente) sea
    // coherente con el cliente real del proyecto.
    'UNIQUE (id, client_id)',
    'CHECK ($_currencyCheck)',
    'CHECK (estimated_amount IS NULL OR estimated_amount >= 0)',
    'CHECK (billing_type IS NULL OR '
        'billing_type IN (${billingTypeConverter.sqlValues}))',
  ];
}

/// Fuente de ingresos salariales recurrentes.
class SalarySources extends Table with _Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 80)();

  IntColumn get expectedAmount => integer().nullable()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  TextColumn get frequency =>
      text().nullable().map(recurrenceFrequencyConverter)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => [
    'CHECK ($_currencyCheck)',
    'CHECK (expected_amount IS NULL OR expected_amount >= 0)',
    'CHECK (frequency IS NULL OR '
        'frequency IN (${recurrenceFrequencyConverter.sqlValues}))',
  ];
}

/// Objetivo de ahorro.
///
/// `currentAmount` es un snapshot real declarado por la persona, no una
/// capacidad estimada ni una suma automatica de ingresos (DEC-003).
class SavingsGoals extends Table with _Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 80)();

  IntColumn get targetAmount => integer()();

  IntColumn get currentAmount => integer().nullable()();

  IntColumn get monthlyContribution => integer().nullable()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  DateTimeColumn get targetDate => dateTime().nullable()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'CHECK ($_currencyCheck)',
    'CHECK (target_amount > 0)',
    'CHECK (current_amount IS NULL OR current_amount >= 0)',
    'CHECK (monthly_contribution IS NULL OR monthly_contribution >= 0)',
  ];
}

/// Plantilla de repeticion. No materializa ocurrencias por si sola:
/// `autoGenerate` permanece en false y no hay scheduler.
@TableIndex(name: 'idx_rules_active_next', columns: {#isActive, #nextDate})
@TableIndex(name: 'idx_rules_account', columns: {#accountId})
class RecurringRules extends Table with _Timestamps {
  TextColumn get concept => text().withLength(min: 1, max: 120)();

  TextColumn get type => text().map(movementTypeConverter)();

  IntColumn get accountId => integer()();

  IntColumn get destinationAccountId =>
      integer().nullable().references(Accounts, #id)();

  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  IntColumn get amount => integer()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  TextColumn get frequency => text().map(recurrenceFrequencyConverter)();

  IntColumn get intervalCount => integer().withDefault(const Constant(1))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  IntColumn get monthDay => integer().nullable()();

  IntColumn get weekday => integer().nullable()();

  DateTimeColumn get nextDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  BoolColumn get autoGenerate => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (account_id, currency) REFERENCES accounts (id, currency)',
    'CHECK ($_currencyCheck)',
    'CHECK (type IN (${movementTypeConverter.sqlValues}))',
    'CHECK (frequency IN (${recurrenceFrequencyConverter.sqlValues}))',
    'CHECK (amount > 0)',
    'CHECK (interval_count > 0 AND interval_count <= 120)',
    'CHECK (end_date IS NULL OR end_date >= start_date)',
    'CHECK (month_day IS NULL OR (month_day >= 1 AND month_day <= 31))',
    'CHECK (weekday IS NULL OR (weekday >= 1 AND weekday <= 7))',
    // Una transferencia necesita destino distinto del origen; el resto de
    // tipos no admite destino.
    "CHECK ((type = 'transfer' AND destination_account_id IS NOT NULL "
        'AND destination_account_id <> account_id) OR '
        "(type <> 'transfer' AND destination_account_id IS NULL))",
  ];
}

/// Unica entidad de movimiento: gastos, salarios, cobros de proyecto, otros
/// ingresos y transferencias.
///
/// El importe es siempre positivo; el tipo determina la direccion. Una
/// transferencia es una sola fila con cuenta origen y destino.
@TableIndex(name: 'idx_tx_expected', columns: {#expectedDate})
@TableIndex(name: 'idx_tx_actual', columns: {#actualDate})
@TableIndex(name: 'idx_tx_status', columns: {#status})
@TableIndex(name: 'idx_tx_account', columns: {#accountId})
@TableIndex(name: 'idx_tx_destination', columns: {#destinationAccountId})
@TableIndex(name: 'idx_tx_category', columns: {#categoryId})
@TableIndex(name: 'idx_tx_client', columns: {#clientId})
@TableIndex(name: 'idx_tx_project', columns: {#projectId})
@TableIndex(name: 'idx_tx_salary_source', columns: {#salarySourceId})
@TableIndex(name: 'idx_tx_savings_goal', columns: {#savingsGoalId})
@TableIndex(name: 'idx_tx_rule', columns: {#recurringRuleId})
class Transactions extends Table with _Timestamps {
  TextColumn get type => text().map(movementTypeConverter)();

  TextColumn get status => text().map(movementStatusConverter)();

  TextColumn get concept => text().withLength(min: 1, max: 120)();

  IntColumn get amount => integer()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  IntColumn get accountId => integer()();

  IntColumn get destinationAccountId =>
      integer().nullable().references(Accounts, #id)();

  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  IntColumn get clientId => integer().nullable().references(Clients, #id)();

  IntColumn get projectId => integer().nullable()();

  IntColumn get salarySourceId =>
      integer().nullable().references(SalarySources, #id)();

  IntColumn get savingsGoalId =>
      integer().nullable().references(SavingsGoals, #id)();

  IntColumn get recurringRuleId =>
      integer().nullable().references(RecurringRules, #id)();

  /// Fecha en la que se espera que ocurra. Siempre existe.
  DateTimeColumn get expectedDate => dateTime()();

  /// Fecha en la que ocurrio de verdad. Solo en estados realizados.
  DateTimeColumn get actualDate => dateTime().nullable()();

  TextColumn get notes => text().nullable().withLength(max: 500)();

  /// Borrado logico: conserva historia y relaciones, sale del saldo.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (account_id, currency) REFERENCES accounts (id, currency)',
    // El cliente del movimiento debe ser el cliente real del proyecto.
    'FOREIGN KEY (project_id, client_id) REFERENCES projects (id, client_id)',
    'CHECK ($_currencyCheck)',
    'CHECK (type IN (${movementTypeConverter.sqlValues}))',
    'CHECK (status IN (${movementStatusConverter.sqlValues}))',
    'CHECK (amount > 0)',
    'CHECK (project_id IS NULL OR client_id IS NOT NULL)',
    // Estados no realizados no tienen fecha real.
    "CHECK (status NOT IN ('previsto', 'pendiente', 'cancelado') "
        'OR actual_date IS NULL)',
    // Pagado es salida de dinero: gasto o transferencia, con fecha real.
    "CHECK (status <> 'pagado' OR (actual_date IS NOT NULL "
        "AND type IN ('expense', 'transfer')))",
    // Cobrado es entrada de dinero: solo ingresos, con fecha real.
    "CHECK (status <> 'cobrado' OR (actual_date IS NOT NULL "
        "AND type IN ('salary', 'project_income', 'other_income')))",
    "CHECK ((type = 'transfer' AND destination_account_id IS NOT NULL "
        'AND destination_account_id <> account_id) OR '
        "(type <> 'transfer' AND destination_account_id IS NULL))",
  ];
}
