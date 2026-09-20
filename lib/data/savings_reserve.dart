import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/utils/dates.dart';
import '../core/utils/money.dart';
import 'account_repository.dart';
import 'goal_repository.dart';

/// Cuanto del saldo esta apartado para ahorrar, y cuanto queda para gastar.
///
/// El saldo de las cuentas es uno solo: el dinero del ahorro esta en la misma
/// cuenta que el de la compra. Esta clase no mueve nada, solo parte esa cifra
/// en dos para que la pantalla de Inicio no invite a gastar dinero que ya
/// tiene destino.
///
/// La reserva se acumula: un objetivo de 200 al mes que empezo en enero pide
/// 200 en enero, 400 en febrero, 600 en marzo. No se descuenta lo que se haya
/// gastado de mas, porque el objetivo es precisamente no gastarlo.
class SavingsReserve {
  const SavingsReserve({
    required this.balance,
    required this.target,
    required this.reserved,
    required this.lines,
  });

  /// Saldo total real de las cuentas.
  final int balance;

  /// Lo que los objetivos piden apartar a dia de hoy.
  final int target;

  /// Lo que de verdad se puede apartar: [target] limitado por [balance].
  ///
  /// Si el saldo no llega, la reserva baja con el. Es la regla que pidio
  /// Andy: cuando lo disponible se agota, se empieza a gastar del ahorro.
  final int reserved;

  /// De donde sale cada parte de la reserva, para poder explicarla.
  final List<SavingsReserveLine> lines;

  /// Lo que queda para gastar. Nunca negativo: si el saldo es menor que la
  /// reserva, lo disponible es cero y la reserva absorbe la diferencia.
  int get available => balance - reserved;

  /// Cuanto falta para tener apartado lo que los objetivos piden.
  int get missing => target - reserved;

  bool get hasReserve => reserved > 0 || target > 0;

  /// Reparte [balance] entre ahorro y disponible segun los objetivos vivos.
  ///
  /// [today] se pasa explicito para poder probarlo sin depender del reloj.
  factory SavingsReserve.of({
    required int balance,
    required List<SavingsGoal> goals,
    required DateTime today,
  }) {
    final month = Dates.monthStart(today);
    final lines = <SavingsReserveLine>[];

    for (final goal in goals) {
      if (goal.isArchived) continue;

      final amount = goal.kind.isMonthly
          ? _monthlyTarget(goal, month)
          // En un objetivo por importe no hay acumulacion que calcular: lo
          // apartado es lo que la persona declara haber apartado. Sin
          // declaracion no se supone ninguna cifra.
          : (goal.currentAmount ?? 0);

      if (amount > 0) {
        lines.add(SavingsReserveLine(goal: goal, amount: amount));
      }
    }

    final target = lines.fold<int>(0, (sum, line) => sum + line.amount);
    // Ni mas que el saldo ni menos que cero: un saldo en numeros rojos no
    // significa que haya ahorro negativo.
    final reserved = balance <= 0 ? 0 : (target > balance ? balance : target);

    return SavingsReserve(
      balance: balance,
      target: target,
      reserved: reserved,
      lines: lines,
    );
  }

  /// Aportacion mensual multiplicada por los meses transcurridos, el actual
  /// incluido.
  ///
  /// Sin mes de inicio no se acumula nada mas que el mes corriente: es
  /// preferible quedarse corto a inventar meses de ahorro que quiza no
  /// ocurrieron.
  static int _monthlyTarget(SavingsGoal goal, DateTime month) {
    final start = goal.startMonth;
    if (start == null) return goal.targetAmount;

    final elapsed = Dates.monthsBetween(Dates.monthStart(start), month);
    if (elapsed < 0) return 0;
    return goal.targetAmount * (elapsed + 1);
  }
}

/// Lo que un objetivo concreto aporta a la reserva.
class SavingsReserveLine {
  const SavingsReserveLine({required this.goal, required this.amount});

  final SavingsGoal goal;
  final int amount;
}

/// Reparto del saldo total entre ahorro apartado y dinero disponible.
final savingsReserveProvider = Provider<AsyncValue<SavingsReserve>>((ref) {
  final balances = ref.watch(accountBalancesProvider);
  final goals = ref.watch(goalsProvider);

  // Mientras falte cualquiera de las dos mitades no se muestra un reparto a
  // medias: un saldo sin sus objetivos se leeria como que no hay ahorro.
  if (balances.isLoading || goals.isLoading) return const AsyncValue.loading();

  return balances.whenData((rows) {
    final total =
        Money.sum(
          rows
              .where((row) => !row.account.isArchived)
              .map((row) => row.balance ?? 0),
        ) ??
        0;

    return SavingsReserve.of(
      balance: total,
      goals: [for (final progress in goals.value ?? const []) progress.goal],
      today: Dates.today(),
    );
  });
});
