import '../core/database/app_database.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import '../core/utils/money.dart';
import 'account_repository.dart';
import 'recurrence_schedule.dart';

/// Un punto de la proyeccion: el saldo estimado al final de un mes.
class ForecastPoint {
  const ForecastPoint({
    required this.month,
    required this.balance,
    required this.income,
    required this.expense,
  });

  /// Primer dia del mes al que corresponde el punto.
  final DateTime month;

  /// Saldo acumulado estimado al terminar ese mes.
  final int balance;

  /// Entradas de dinero estimadas en ese mes.
  final int income;

  /// Salidas de dinero estimadas en ese mes.
  final int expense;

  int get net => income - expense;
}

/// Un movimiento futuro concreto, de los que la proyeccion tiene en cuenta.
class ForecastMilestone {
  const ForecastMilestone({
    required this.date,
    required this.concept,
    required this.amount,
    required this.isIncome,
    required this.fromRule,
  });

  final DateTime date;
  final String concept;

  /// Importe positivo. [isIncome] marca la direccion.
  final int amount;
  final bool isIncome;

  /// True si procede de una regla recurrente y no de un movimiento ya
  /// registrado. Se distingue para no dar por comprometido lo que solo es
  /// una repeticion esperada.
  final bool fromRule;
}

/// Resultado de una proyeccion.
class ForecastResult {
  const ForecastResult({
    required this.startingBalance,
    required this.points,
    required this.milestones,
    required this.hasData,
  });

  /// Saldo real de partida, hoy.
  final int startingBalance;

  /// Un punto por mes proyectado, en orden.
  final List<ForecastPoint> points;

  /// Movimientos futuros que explican la proyeccion, por fecha.
  final List<ForecastMilestone> milestones;

  /// False cuando no hay nada con lo que proyectar. La interfaz debe decirlo
  /// en vez de dibujar una linea plana que parezca una prevision real.
  final bool hasData;

  /// Saldo estimado al final del horizonte.
  int get endingBalance =>
      points.isEmpty ? startingBalance : points.last.balance;

  /// Diferencia entre el final del horizonte y hoy.
  int get delta => endingBalance - startingBalance;

  /// Entradas previstas en todo el horizonte.
  int get totalIncome => Money.sum(points.map((p) => p.income)) ?? 0;

  /// Salidas previstas en todo el horizonte.
  int get totalExpense => Money.sum(points.map((p) => p.expense)) ?? 0;

  /// Capacidad estimada de ahorro al mes: lo que sobra de media.
  ///
  /// No es el objetivo de ahorro ni el ahorro real (DEC-003). Es solo lo que
  /// la proyeccion deja libre cada mes de media.
  int? get monthlyCapacity {
    if (points.isEmpty) return null;
    return (totalIncome - totalExpense) ~/ points.length;
  }
}

/// Motor de previsión.
///
/// Proyecta el saldo combinando lo que ya está comprometido (movimientos
/// previstos o pendientes con fecha futura) con lo que se espera que se
/// repita (reglas recurrentes activas).
///
/// Lo que el motor no hace, a propósito: no inventa gastos variables por
/// media histórica, no da por cobrado lo que solo está previsto y no escribe
/// nada en la base. Proyectar es una consulta, no un efecto.
abstract final class ForecastEngine {
  const ForecastEngine._();

  /// Horizontes que ofrece la interfaz, en meses.
  static const List<int> horizons = [3, 6, 12, 24];

  /// Proyecta [months] meses a partir de [from].
  static ForecastResult project({
    required List<Account> accounts,
    required List<Transaction> movements,
    required List<RecurringRule> rules,
    required DateTime from,
    required int months,
    List<SalarySource> salarySources = const [],
  }) {
    final today = Dates.day(from);
    final startingBalance = _currentBalance(accounts, movements);

    final committed = _committedMilestones(movements, today, months);
    final recurring = _recurringMilestones(rules, movements, today, months);
    final salaries = _salaryMilestones(salarySources, movements, today, months);
    final milestones = [...committed, ...recurring, ...salaries]
      ..sort((a, b) => a.date.compareTo(b.date));

    final points = _accumulate(
      startingBalance: startingBalance,
      milestones: milestones,
      today: today,
      months: months,
    );

    return ForecastResult(
      startingBalance: startingBalance,
      points: points,
      milestones: milestones,
      hasData:
          accounts.isNotEmpty &&
          (milestones.isNotEmpty || movements.isNotEmpty),
    );
  }

  /// Saldo real actual, sumando todas las cuentas vivas.
  static int _currentBalance(
    List<Account> accounts,
    List<Transaction> movements,
  ) {
    final balances = <int>[];
    for (final account in accounts) {
      if (account.isArchived) continue;
      final balance = AccountRepository.balanceOf(account, movements);
      if (balance != null) balances.add(balance);
    }
    return Money.sum(balances) ?? 0;
  }

  /// Movimientos ya registrados que todavia no han ocurrido.
  ///
  /// Solo previsto y pendiente: lo cancelado no va a pasar y lo ya realizado
  /// esta contado en el saldo de partida.
  static List<ForecastMilestone> _committedMilestones(
    List<Transaction> movements,
    DateTime today,
    int months,
  ) {
    // Limite exclusivo: el primer dia del mes siguiente al ultimo
    // proyectado. Debe coincidir con los meses que acumula
    // [_accumulate], o apareceran hitos que ningun punto recoge.
    final horizon = DateTime.utc(today.year, today.month + months);

    return [
      for (final movement in movements)
        if (!movement.isDeleted &&
            !movement.type.isTransfer &&
            !movement.status.isRealised &&
            movement.status != MovementStatus.cancelado &&
            !movement.expectedDate.isBefore(today) &&
            movement.expectedDate.isBefore(horizon))
          ForecastMilestone(
            date: movement.expectedDate,
            concept: movement.concept,
            amount: movement.amount,
            isIncome: movement.type.isIncome,
            fromRule: false,
          ),
    ];
  }

  /// Repeticiones esperadas de las reglas activas.
  ///
  /// Se omite la ocurrencia cuya fecha ya tiene un movimiento registrado
  /// desde esa misma regla: ese dia ya lo cuenta [_committedMilestones] y
  /// contarlo dos veces inflaria la proyeccion.
  static List<ForecastMilestone> _recurringMilestones(
    List<RecurringRule> rules,
    List<Transaction> movements,
    DateTime today,
    int months,
  ) {
    // Limite exclusivo: el primer dia del mes siguiente al ultimo
    // proyectado. Debe coincidir con los meses que acumula
    // [_accumulate], o apareceran hitos que ningun punto recoge.
    final horizon = DateTime.utc(today.year, today.month + months);
    final already = <String>{
      for (final movement in movements)
        if (!movement.isDeleted && movement.recurringRuleId != null)
          '${movement.recurringRuleId}@${isoDay(movement.expectedDate)}',
    };

    final milestones = <ForecastMilestone>[];
    for (final rule in rules) {
      if (!rule.isActive) continue;
      if (rule.type.isTransfer) continue;

      final schedule = RecurrenceSchedule.fromRule(rule);
      for (final date in schedule.between(from: today, to: horizon)) {
        if (already.contains('${rule.id}@${isoDay(date)}')) continue;
        milestones.add(
          ForecastMilestone(
            date: date,
            concept: rule.concept,
            amount: rule.amount,
            isIncome: rule.type.isIncome,
            fromRule: true,
          ),
        );
      }
    }
    return milestones;
  }

  /// Nominas esperadas de las fuentes salariales activas.
  ///
  /// Una fuente con importe, frecuencia y dia de cobro es una previsión de
  /// ingreso tan legitima como una regla recurrente: si no entrara aqui, un
  /// sueldo declarado no aparecería en la proyeccion y bastaria un gasto
  /// recurrente pequeño para pintar el futuro en numeros rojos.
  ///
  /// Se omite la ocurrencia cuya fecha ya tiene una nomina registrada de esa
  /// misma fuente, y tambien el mes que ya tiene una: una nomina se cobra una
  /// vez al mes aunque el dia no coincida exactamente con el declarado.
  static List<ForecastMilestone> _salaryMilestones(
    List<SalarySource> sources,
    List<Transaction> movements,
    DateTime today,
    int months,
  ) {
    final horizon = DateTime.utc(today.year, today.month + months);
    final milestones = <ForecastMilestone>[];

    for (final source in sources) {
      final amount = source.expectedAmount;
      final frequency = source.frequency;
      final day = source.paymentDay;

      // Sin importe, frecuencia o dia no hay nada que proyectar, y
      // rellenarlos a ojo seria inventarse el sueldo de alguien.
      if (!source.isActive || amount == null || amount <= 0) continue;
      if (frequency == null || day == null) continue;

      final alreadyPaid = <String>{
        for (final movement in movements)
          if (!movement.isDeleted && movement.salarySourceId == source.id)
            '${movement.expectedDate.year}-${movement.expectedDate.month}',
      };

      final schedule = RecurrenceSchedule(
        anchor: Dates.clampToMonth(today.year, today.month, day),
        frequency: frequency,
        intervalCount: 1,
      );

      for (final date in schedule.between(from: today, to: horizon)) {
        if (alreadyPaid.contains('${date.year}-${date.month}')) continue;
        milestones.add(
          ForecastMilestone(
            date: date,
            concept: source.name,
            amount: amount,
            isIncome: true,
            fromRule: true,
          ),
        );
      }
    }
    return milestones;
  }

  /// Reparte los hitos por mes y acumula el saldo.
  static List<ForecastPoint> _accumulate({
    required int startingBalance,
    required List<ForecastMilestone> milestones,
    required DateTime today,
    required int months,
  }) {
    final points = <ForecastPoint>[];
    var balance = BigInt.from(startingBalance);

    for (var offset = 0; offset < months; offset++) {
      final month = DateTime.utc(today.year, today.month + offset);
      final nextMonth = DateTime.utc(today.year, today.month + offset + 1);

      var income = BigInt.zero;
      var expense = BigInt.zero;

      for (final milestone in milestones) {
        if (milestone.date.isBefore(month)) continue;
        if (!milestone.date.isBefore(nextMonth)) continue;
        if (milestone.isIncome) {
          income += BigInt.from(milestone.amount);
        } else {
          expense += BigInt.from(milestone.amount);
        }
      }

      balance += income - expense;
      points.add(
        ForecastPoint(
          month: month,
          balance: _clampToInt(balance),
          income: _clampToInt(income),
          expense: _clampToInt(expense),
        ),
      );
    }
    return points;
  }

  static int _clampToInt(BigInt value) {
    if (value > Money64.max) return Money64.max.toInt();
    if (value < Money64.min) return Money64.min.toInt();
    return value.toInt();
  }
}
