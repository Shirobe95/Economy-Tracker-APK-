import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/report_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reference = DateTime.utc(2026, 9, 15);

  Transaction movement({
    int id = 1,
    required MovementType type,
    required MovementStatus status,
    required int amount,
    required DateTime expectedDate,
    DateTime? actualDate,
    int? categoryId,
    bool isDeleted = false,
    String concept = 'Movimiento',
  }) => Transaction(
    id: id,
    type: type,
    status: status,
    concept: concept,
    amount: amount,
    currency: 'EUR',
    accountId: 1,
    categoryId: categoryId,
    expectedDate: expectedDate,
    actualDate: actualDate,
    isDeleted: isDeleted,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  Transaction expense(
    int amount,
    DateTime paidOn, {
    int? categoryId,
    int id = 1,
  }) => movement(
    id: id,
    type: MovementType.expense,
    status: MovementStatus.pagado,
    amount: amount,
    expectedDate: paidOn,
    actualDate: paidOn,
    categoryId: categoryId,
  );

  Transaction income(int amount, DateTime collectedOn, {int id = 1}) =>
      movement(
        id: id,
        type: MovementType.salary,
        status: MovementStatus.cobrado,
        amount: amount,
        expectedDate: collectedOn,
        actualDate: collectedOn,
      );

  Category category(int id, String name) => Category(
    id: id,
    name: name,
    kind: CategoryKind.expense,
    isArchived: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  ReportResult build(
    List<Transaction> movements, {
    ReportRange range = ReportRange.quarter,
    List<Category> categories = const [],
  }) => ReportEngine.build(
    movements: movements,
    categories: categories,
    reference: reference,
    range: range,
  );

  group('que entra en el informe', () {
    test('sin movimientos reales no hay datos', () {
      final report = build([]);
      expect(report.hasData, isFalse);
      expect(report.movementCount, 0);
    });

    test('cuenta lo realizado dentro del periodo', () {
      final report = build([
        expense(85000, DateTime.utc(2026, 9, 3)),
        income(180000, DateTime.utc(2026, 9, 1), id: 2),
      ]);

      expect(report.expense, 85000);
      expect(report.income, 180000);
      expect(report.net, 95000);
      expect(report.hasData, isTrue);
    });

    test('lo pendiente no suma a los totales, se devuelve aparte', () {
      final report = build([
        expense(85000, DateTime.utc(2026, 9, 3)),
        movement(
          id: 2,
          type: MovementType.expense,
          status: MovementStatus.pendiente,
          amount: 50000,
          expectedDate: DateTime.utc(2026, 9, 20),
        ),
      ]);

      expect(report.expense, 85000, reason: 'un informe es historia');
      expect(report.pendingExpense, 50000);
    });

    test('usa la fecha real, no la prevista', () {
      // Previsto en junio, pagado en septiembre: el dinero salio en
      // septiembre, y ahi es donde cuenta.
      final report = build([
        movement(
          type: MovementType.expense,
          status: MovementStatus.pagado,
          amount: 42000,
          expectedDate: DateTime.utc(2026, 6, 1),
          actualDate: DateTime.utc(2026, 9, 5),
        ),
      ]);

      expect(report.expense, 42000);
      expect(report.monthly.last.expense, 42000);
    });

    test('ignora lo borrado, lo cancelado y las transferencias', () {
      final report = build([
        expense(
          10000,
          DateTime.utc(2026, 9, 3),
          id: 1,
        ).copyWith(isDeleted: true),
        movement(
          id: 2,
          type: MovementType.expense,
          status: MovementStatus.cancelado,
          amount: 20000,
          expectedDate: DateTime.utc(2026, 9, 4),
        ),
        movement(
          id: 3,
          type: MovementType.transfer,
          status: MovementStatus.pagado,
          amount: 30000,
          expectedDate: DateTime.utc(2026, 9, 5),
          actualDate: DateTime.utc(2026, 9, 5),
        ),
      ]);

      expect(report.expense, 0);
      expect(report.hasData, isFalse);
    });

    test('deja fuera lo anterior al periodo', () {
      final report = build([
        expense(99000, DateTime.utc(2026, 1, 10)),
      ], range: ReportRange.month);
      expect(report.expense, 0);
    });
  });

  group('serie mensual', () {
    test('tiene un punto por mes del periodo', () {
      expect(build([], range: ReportRange.month).monthly.length, 1);
      expect(build([], range: ReportRange.quarter).monthly.length, 3);
      expect(build([], range: ReportRange.year).monthly.length, 12);
    });

    test('reparte cada movimiento en su mes', () {
      final report = build([
        expense(10000, DateTime.utc(2026, 7, 5), id: 1),
        expense(20000, DateTime.utc(2026, 8, 5), id: 2),
        expense(30000, DateTime.utc(2026, 9, 5), id: 3),
      ]);

      expect(report.monthly.map((m) => m.expense), [10000, 20000, 30000]);
      expect(report.monthly.first.month, DateTime.utc(2026, 7));
      expect(report.monthly.last.month, DateTime.utc(2026, 9));
    });

    test('el neto mensual resta gasto de ingreso', () {
      final report = build([
        income(100000, DateTime.utc(2026, 9, 1), id: 1),
        expense(40000, DateTime.utc(2026, 9, 5), id: 2),
      ]);
      expect(report.monthly.last.net, 60000);
    });
  });

  group('reparto por categoria', () {
    test('agrupa, ordena de mayor a menor y calcula la parte', () {
      final report = build(
        [
          expense(85000, DateTime.utc(2026, 9, 3), categoryId: 1, id: 1),
          expense(10000, DateTime.utc(2026, 9, 8), categoryId: 2, id: 2),
          expense(5000, DateTime.utc(2026, 9, 9), categoryId: 1, id: 3),
        ],
        categories: [category(1, 'Vivienda'), category(2, 'Servicios')],
      );

      expect(report.byCategory.first.name, 'Vivienda');
      expect(report.byCategory.first.amount, 90000);
      expect(report.byCategory.first.share, closeTo(0.9, 0.001));
      expect(report.byCategory.last.name, 'Servicios');
    });

    test('los gastos sin categoria se agrupan aparte', () {
      final report = build([expense(10000, DateTime.utc(2026, 9, 3))]);
      expect(report.byCategory.single.name, 'Sin categoria');
      expect(report.byCategory.single.categoryId, isNull);
    });

    test('los ingresos no entran en el reparto de gasto', () {
      final report = build([
        expense(10000, DateTime.utc(2026, 9, 3), id: 1),
        income(50000, DateTime.utc(2026, 9, 1), id: 2),
      ]);
      expect(report.byCategory.single.amount, 10000);
    });
  });

  group('comparacion y medias', () {
    test('compara con el periodo anterior de la misma duracion', () {
      final report = build([
        // Trimestre anterior: abril a junio.
        income(100000, DateTime.utc(2026, 5, 1), id: 1),
        // Trimestre actual: julio a septiembre.
        income(150000, DateTime.utc(2026, 8, 1), id: 2),
      ]);

      expect(report.previousNet, 100000);
      expect(report.net, 150000);
      expect(report.netChange, 50000);
    });

    test('la media mensual reparte entre los meses del periodo', () {
      final report = build([
        expense(30000, DateTime.utc(2026, 8, 5), id: 1),
        expense(60000, DateTime.utc(2026, 9, 5), id: 2),
      ]);
      expect(report.averageMonthlyExpense, 30000);
    });

    test('la tasa de ahorro es la parte del ingreso que no se gasto', () {
      final report = build([
        income(200000, DateTime.utc(2026, 9, 1), id: 1),
        expense(150000, DateTime.utc(2026, 9, 5), id: 2),
      ]);
      expect(report.savingsRate, closeTo(0.25, 0.001));
    });

    test('sin ingresos la tasa de ahorro no existe, no es cero', () {
      final report = build([expense(10000, DateTime.utc(2026, 9, 5))]);
      expect(report.savingsRate, isNull);
    });

    test('gastar mas de lo que entra da tasa cero, no negativa', () {
      final report = build([
        income(50000, DateTime.utc(2026, 9, 1), id: 1),
        expense(80000, DateTime.utc(2026, 9, 5), id: 2),
      ]);
      expect(report.savingsRate, 0);
      expect(report.net, -30000);
    });
  });
}
