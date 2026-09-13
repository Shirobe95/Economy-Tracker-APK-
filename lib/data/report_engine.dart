import '../core/database/app_database.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import '../core/utils/money.dart';

/// Periodo que cubre un informe.
enum ReportRange {
  month('Este mes', 1),
  quarter('3 meses', 3),
  halfYear('6 meses', 6),
  year('12 meses', 12);

  const ReportRange(this.label, this.months);

  final String label;
  final int months;
}

/// Totales de un mes concreto.
class MonthlyTotals {
  const MonthlyTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final int income;
  final int expense;

  int get net => income - expense;
}

/// Cuanto se ha movido en una categoria.
class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.share,
  });

  /// `null` cuando el movimiento no tenia categoria asignada.
  final int? categoryId;
  final String name;
  final int amount;

  /// Fraccion del total del periodo, entre 0 y 1.
  final double share;
}

/// Resultado de un informe.
class ReportResult {
  const ReportResult({
    required this.from,
    required this.to,
    required this.income,
    required this.expense,
    required this.monthly,
    required this.byCategory,
    required this.previousNet,
    required this.pendingIncome,
    required this.pendingExpense,
    required this.movementCount,
  });

  /// Primer dia incluido y primer dia excluido.
  final DateTime from;
  final DateTime to;

  /// Dinero que entro de verdad en el periodo.
  final int income;

  /// Dinero que salio de verdad en el periodo.
  final int expense;

  final List<MonthlyTotals> monthly;
  final List<CategoryTotal> byCategory;

  /// Neto del periodo inmediatamente anterior, de la misma duracion.
  final int previousNet;

  /// Comprometido y todavia no cobrado dentro del periodo.
  final int pendingIncome;

  /// Comprometido y todavia no pagado dentro del periodo.
  final int pendingExpense;

  /// Movimientos reales contados. Cero significa que no hay historia, no
  /// que el balance sea cero.
  final int movementCount;

  bool get hasData => movementCount > 0;

  int get net => income - expense;

  /// Diferencia de neto con el periodo anterior.
  int get netChange => net - previousNet;

  /// Media mensual de gasto real.
  int? get averageMonthlyExpense =>
      monthly.isEmpty ? null : expense ~/ monthly.length;

  /// Media mensual de ingreso real.
  int? get averageMonthlyIncome =>
      monthly.isEmpty ? null : income ~/ monthly.length;

  /// Porcentaje del ingreso que no se gasto, entre 0 y 1.
  ///
  /// `null` si no hubo ingresos: dividir entre cero no es "cero por ciento".
  double? get savingsRate {
    if (income <= 0) return null;
    final rate = net / income;
    return rate < 0 ? 0 : rate;
  }
}

/// Informes sobre lo que ya ha pasado.
///
/// Cuenta solo movimientos realizados —pagados o cobrados— y por su fecha
/// real, no la prevista. Un informe es historia: mezclar lo que aun no ha
/// ocurrido lo convertiria en una previsión disfrazada. Lo comprometido se
/// devuelve aparte, sin sumarlo a los totales.
abstract final class ReportEngine {
  const ReportEngine._();

  static ReportResult build({
    required List<Transaction> movements,
    required List<Category> categories,
    required DateTime reference,
    required ReportRange range,
  }) {
    final to = Dates.nextMonthStart(reference);
    final from = DateTime.utc(to.year, to.month - range.months);
    final previousFrom = DateTime.utc(from.year, from.month - range.months);

    final current = _realisedBetween(movements, from, to);
    final previous = _realisedBetween(movements, previousFrom, from);

    final income = _sumOf(current.where((m) => m.type.isIncome));
    final expense = _sumOf(current.where((m) => m.type.isExpense));

    return ReportResult(
      from: from,
      to: to,
      income: income,
      expense: expense,
      monthly: _monthlySeries(current, from, range.months),
      byCategory: _categoryBreakdown(
        current.where((m) => m.type.isExpense).toList(),
        categories,
        expense,
      ),
      previousNet:
          _sumOf(previous.where((m) => m.type.isIncome)) -
          _sumOf(previous.where((m) => m.type.isExpense)),
      pendingIncome: _sumOf(
        _committedBetween(movements, from, to).where((m) => m.type.isIncome),
      ),
      pendingExpense: _sumOf(
        _committedBetween(movements, from, to).where((m) => m.type.isExpense),
      ),
      movementCount: current.length,
    );
  }

  /// Movimientos que de verdad movieron dinero dentro del intervalo.
  ///
  /// Se filtran por fecha real: un gasto de enero pagado en marzo pertenece a
  /// marzo, que es cuando salio el dinero. Las transferencias quedan fuera:
  /// mueven dinero propio, no son ingreso ni gasto.
  static List<Transaction> _realisedBetween(
    List<Transaction> movements,
    DateTime from,
    DateTime to,
  ) {
    return [
      for (final movement in movements)
        if (!movement.isDeleted &&
            !movement.type.isTransfer &&
            movement.status.isRealised &&
            movement.actualDate != null &&
            !movement.actualDate!.isBefore(from) &&
            movement.actualDate!.isBefore(to))
          movement,
    ];
  }

  /// Movimientos previstos o pendientes con fecha prevista en el intervalo.
  static List<Transaction> _committedBetween(
    List<Transaction> movements,
    DateTime from,
    DateTime to,
  ) {
    return [
      for (final movement in movements)
        if (!movement.isDeleted &&
            !movement.type.isTransfer &&
            !movement.status.isRealised &&
            movement.status != MovementStatus.cancelado &&
            !movement.expectedDate.isBefore(from) &&
            movement.expectedDate.isBefore(to))
          movement,
    ];
  }

  static List<MonthlyTotals> _monthlySeries(
    List<Transaction> movements,
    DateTime from,
    int months,
  ) {
    return [
      for (var offset = 0; offset < months; offset++)
        () {
          final month = DateTime.utc(from.year, from.month + offset);
          final next = DateTime.utc(from.year, from.month + offset + 1);
          final inMonth = movements.where(
            (m) =>
                !m.actualDate!.isBefore(month) && m.actualDate!.isBefore(next),
          );
          return MonthlyTotals(
            month: month,
            income: _sumOf(inMonth.where((m) => m.type.isIncome)),
            expense: _sumOf(inMonth.where((m) => m.type.isExpense)),
          );
        }(),
    ];
  }

  static List<CategoryTotal> _categoryBreakdown(
    List<Transaction> expenses,
    List<Category> categories,
    int total,
  ) {
    if (expenses.isEmpty || total <= 0) return const [];

    final amounts = <int?, int>{};
    for (final movement in expenses) {
      amounts.update(
        movement.categoryId,
        (value) => value + movement.amount,
        ifAbsent: () => movement.amount,
      );
    }

    final names = {
      for (final category in categories) category.id: category.name,
    };

    final result = [
      for (final entry in amounts.entries)
        CategoryTotal(
          categoryId: entry.key,
          name: names[entry.key] ?? 'Sin categoria',
          amount: entry.value,
          share: entry.value / total,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }

  static int _sumOf(Iterable<Transaction> movements) =>
      Money.sum(movements.map((m) => m.amount)) ?? 0;
}
