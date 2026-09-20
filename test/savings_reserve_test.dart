import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/savings_reserve.dart';
import 'package:flutter_test/flutter_test.dart';

/// El saldo de Inicio se parte en dos: lo apartado y lo que queda.
///
/// Es la cifra mas visible de la aplicacion, asi que aqui se prueba con
/// numeros concretos en vez de con formulas: el ejemplo que pidio Andy, sus
/// bordes, y lo que pasa cuando el dinero no llega.
void main() {
  SavingsGoal goal({
    int id = 1,
    String name = 'Ahorro del mes',
    SavingsGoalKind kind = SavingsGoalKind.monthly,
    required int targetAmount,
    int? currentAmount,
    DateTime? startMonth,
    bool isArchived = false,
  }) {
    final now = DateTime.utc(2026, 1);
    return SavingsGoal(
      id: id,
      createdAt: now,
      updatedAt: now,
      name: name,
      kind: kind,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      monthlyContribution: null,
      currency: 'EUR',
      targetDate: null,
      startMonth: startMonth,
      isArchived: isArchived,
    );
  }

  group('objetivo mensual', () {
    test('el primer mes aparta una sola mensualidad', () {
      final reserve = SavingsReserve.of(
        balance: 50000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 9))],
        today: DateTime.utc(2026, 9, 20),
      );

      // El ejemplo de Andy: 500 de saldo, 200 de ahorro, 300 disponibles.
      expect(reserve.reserved, 20000);
      expect(reserve.available, 30000);
    });

    test('el segundo mes acumula la mensualidad anterior', () {
      final reserve = SavingsReserve.of(
        balance: 100000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 9))],
        today: DateTime.utc(2026, 10, 3),
      );

      // Siguiendo el ejemplo: 1.000 de saldo, 400 apartados, 600 disponibles.
      expect(reserve.reserved, 40000);
      expect(reserve.available, 60000);
    });

    test('un ano entero acumula doce mensualidades', () {
      final reserve = SavingsReserve.of(
        balance: 500000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 1))],
        today: DateTime.utc(2026, 12, 31),
      );

      expect(reserve.target, 240000);
    });

    test('un objetivo que empieza el mes que viene no aparta nada', () {
      final reserve = SavingsReserve.of(
        balance: 50000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 11))],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.reserved, 0);
      expect(reserve.available, 50000);
    });

    test('sin mes de inicio cuenta solo el mes corriente', () {
      // Antes que inventarse meses de ahorro que quiza no ocurrieron, se
      // queda corto: es la cifra que menos daño hace si esta mal.
      final reserve = SavingsReserve.of(
        balance: 500000,
        goals: [goal(targetAmount: 20000)],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.reserved, 20000);
    });
  });

  group('cuando el saldo no llega', () {
    test('lo disponible no baja de cero', () {
      final reserve = SavingsReserve.of(
        balance: 15000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 9))],
        today: DateTime.utc(2026, 9, 20),
      );

      // Es la regla que pidio Andy: agotado lo disponible, se gasta del
      // ahorro. La reserva baja con el saldo en vez de dejarlo en negativo.
      expect(reserve.available, 0);
      expect(reserve.reserved, 15000);
      expect(reserve.missing, 5000);
    });

    test('un saldo en numeros rojos no genera ahorro negativo', () {
      final reserve = SavingsReserve.of(
        balance: -30000,
        goals: [goal(targetAmount: 20000, startMonth: DateTime.utc(2026, 9))],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.reserved, 0);
      // Lo disponible sigue siendo el saldo real: esconder un descubierto
      // detras de un cero seria mentir en la cifra mas visible de la app.
      expect(reserve.available, -30000);
    });
  });

  group('otros objetivos', () {
    test('uno por importe aparta lo declarado, no una acumulacion', () {
      final reserve = SavingsReserve.of(
        balance: 500000,
        goals: [
          goal(
            kind: SavingsGoalKind.amount,
            targetAmount: 600000,
            currentAmount: 325000,
            startMonth: DateTime.utc(2026, 1),
          ),
        ],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.target, 325000);
    });

    test('uno por importe sin ahorro declarado no aparta nada', () {
      final reserve = SavingsReserve.of(
        balance: 500000,
        goals: [goal(kind: SavingsGoalKind.amount, targetAmount: 600000)],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.reserved, 0);
      expect(reserve.lines, isEmpty);
    });

    test('un objetivo archivado deja de apartar', () {
      final reserve = SavingsReserve.of(
        balance: 50000,
        goals: [
          goal(
            targetAmount: 20000,
            startMonth: DateTime.utc(2026, 9),
            isArchived: true,
          ),
        ],
        today: DateTime.utc(2026, 9, 20),
      );

      expect(reserve.reserved, 0);
    });

    test('varios objetivos suman, y cada uno queda identificado', () {
      final reserve = SavingsReserve.of(
        balance: 500000,
        goals: [
          goal(
            id: 1,
            name: 'Ahorro del mes',
            targetAmount: 20000,
            startMonth: DateTime.utc(2026, 8),
          ),
          goal(
            id: 2,
            name: 'Viaje',
            kind: SavingsGoalKind.amount,
            targetAmount: 150000,
            currentAmount: 40000,
          ),
        ],
        today: DateTime.utc(2026, 9, 20),
      );

      // 200 x 2 meses + 400 declarados.
      expect(reserve.target, 80000);
      expect(
        reserve.lines.map((l) => l.goal.name),
        containsAll(['Ahorro del mes', 'Viaje']),
      );
    });
  });

  test('sin objetivos, el saldo entero esta disponible', () {
    final reserve = SavingsReserve.of(
      balance: 123456,
      goals: const [],
      today: DateTime.utc(2026, 9, 20),
    );

    expect(reserve.reserved, 0);
    expect(reserve.available, 123456);
    expect(reserve.hasReserve, isFalse);
  });
}
