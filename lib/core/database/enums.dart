/// Enumeraciones del modelo financiero.
///
/// Cada valor expone un [code] de texto estable que es lo que se persiste.
/// No se guardan posiciones del enum: reordenar o insertar valores no debe
/// corromper una base existente.
library;

/// Tipo de movimiento (`transactions.type`).
enum MovementType {
  expense('expense'),
  salary('salary'),
  projectIncome('project_income'),
  otherIncome('other_income'),
  transfer('transfer');

  const MovementType(this.code);

  final String code;

  /// Ingresos economicos. Una transferencia no lo es: mueve dinero propio.
  bool get isIncome =>
      this == MovementType.salary ||
      this == MovementType.projectIncome ||
      this == MovementType.otherIncome;

  bool get isExpense => this == MovementType.expense;

  bool get isTransfer => this == MovementType.transfer;
}

/// Estado de un movimiento (`transactions.status`).
enum MovementStatus {
  previsto('previsto'),
  pendiente('pendiente'),
  pagado('pagado'),
  cobrado('cobrado'),
  cancelado('cancelado');

  const MovementStatus(this.code);

  final String code;

  /// Estados que representan dinero que ya se ha movido de verdad.
  bool get isRealised =>
      this == MovementStatus.pagado || this == MovementStatus.cobrado;
}

/// Tipo de cuenta (`accounts.type`).
enum AccountType {
  bank('bank'),
  cash('cash'),
  savings('savings'),
  other('other');

  const AccountType(this.code);

  final String code;
}

/// Naturaleza de una categoria (`categories.kind`).
enum CategoryKind {
  expense('expense'),
  income('income'),
  both('both');

  const CategoryKind(this.code);

  final String code;

  bool acceptsExpense() =>
      this == CategoryKind.expense || this == CategoryKind.both;

  bool acceptsIncome() =>
      this == CategoryKind.income || this == CategoryKind.both;
}

/// Frecuencia de una regla recurrente (`recurring_rules.frequency`).
enum RecurrenceFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const RecurrenceFrequency(this.code);

  final String code;
}

/// Modalidad de facturacion orientativa de un proyecto.
enum BillingType {
  fixed('fixed'),
  hourly('hourly'),
  monthly('monthly'),
  perUnit('per_unit');

  const BillingType(this.code);

  final String code;
}

/// Como se mide un objetivo de ahorro (`savings_goals.kind`).
enum SavingsGoalKind {
  /// Juntar una cantidad concreta: un fondo de emergencia, un portatil.
  amount('amount'),

  /// Apartar un importe todos los meses, sin un total al que llegar.
  monthly('monthly');

  const SavingsGoalKind(this.code);

  final String code;

  bool get isMonthly => this == SavingsGoalKind.monthly;
}
