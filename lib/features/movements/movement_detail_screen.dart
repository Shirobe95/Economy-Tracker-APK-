import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_indicator.dart';
import '../../data/account_repository.dart';
import '../../data/movement_repository.dart';

/// Detalle de un movimiento, con sus acciones (UI-04).
class MovementDetailScreen extends ConsumerWidget {
  const MovementDetailScreen({super.key, required this.movementId});

  final int movementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movement = ref.watch(movementDetailProvider(movementId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          if (movement.value case final row?) ...[
            // Los conceptos se repiten mucho —supermercado, desayuno— y
            // volver a teclear el mismo importe cada vez es el trabajo que
            // hace que una aplicacion asi se acabe abandonando.
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Repetir este movimiento',
              onPressed: () =>
                  context.push('/movimientos/$movementId/repetir', extra: row),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => context.push(
                '/movimientos/$movementId/editar',
                extra: row.type,
              ),
            ),
          ],
        ],
      ),
      body: movement.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('No se ha podido cargar: $error')),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Este movimiento ya no existe.'));
          }
          return _Body(movement: value);
        },
      ),
    );
  }
}

final movementDetailProvider = StreamProvider.family<Transaction?, int>(
  (ref, id) => ref.watch(movementRepositoryProvider).watchById(id),
);

class _Body extends ConsumerWidget {
  const _Body({required this.movement});

  final Transaction movement;

  Future<void> _markRealised(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: Dates.today(),
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2100),
      helpText: movement.type.isIncome
          ? 'Fecha en la que se cobro'
          : 'Fecha en la que se pago',
    );
    if (picked == null) return;

    try {
      await ref
          .read(movementRepositoryProvider)
          .markRealised(movement.id, picked);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movement.type.isIncome
                ? 'Marcado como cobrado'
                : 'Marcado como pagado',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se ha podido marcar: $error')));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text(
          'Se quitara "${movement.concept}" del listado y del saldo. '
          'La operacion no se puede deshacer desde la aplicacion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.negative),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(movementRepositoryProvider).delete(movement.id);
    if (!context.mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = movement.type.isIncome;
    final signedAmount = isIncome ? movement.amount : -movement.amount;

    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        Center(
          child: Column(
            children: [
              RoundIcon(
                _iconFor(movement.type),
                color: isIncome ? AppTokens.positive : AppTokens.negative,
                size: 64,
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                movement.concept,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space2),
              MoneyText(
                signedAmount,
                currency: movement.currency,
                signed: true,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppTokens.space3),
              StatusIndicator(movement.status),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space5),
        FinanceCard(
          child: Column(
            children: [
              _Row(label: 'Tipo', value: _labelFor(movement.type)),
              _Row(
                label: 'Fecha prevista',
                value: formatDay(movement.expectedDate),
              ),
              if (movement.actualDate != null)
                _Row(
                  label: movement.type.isIncome
                      ? 'Fecha de cobro'
                      : 'Fecha de pago',
                  value: formatDay(movement.actualDate!),
                ),
              _AccountRow(accountId: movement.accountId, label: 'Cuenta'),
              if (movement.destinationAccountId != null)
                _AccountRow(
                  accountId: movement.destinationAccountId!,
                  label: 'Destino',
                ),
              if (movement.notes != null)
                _Row(label: 'Notas', value: movement.notes!),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space5),
        if (!movement.status.isRealised &&
            movement.status != MovementStatus.cancelado)
          FilledButton.icon(
            onPressed: () => _markRealised(context, ref),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              isIncome ? 'Marcar como cobrado' : 'Marcar como pagado',
            ),
          ),
        const SizedBox(height: AppTokens.space3),
        TextButton.icon(
          onPressed: () => _delete(context, ref),
          icon: const Icon(Icons.delete_outline, color: AppTokens.negative),
          label: const Text(
            'Eliminar',
            style: TextStyle(color: AppTokens.negative),
          ),
        ),
      ],
    );
  }

  static IconData _iconFor(MovementType type) => switch (type) {
    MovementType.expense => Icons.arrow_downward_rounded,
    MovementType.salary => Icons.badge_outlined,
    MovementType.projectIncome => Icons.euro_rounded,
    MovementType.otherIncome => Icons.arrow_upward_rounded,
    MovementType.transfer => Icons.swap_horiz_rounded,
  };

  static String _labelFor(MovementType type) => switch (type) {
    MovementType.expense => 'Gasto',
    MovementType.salary => 'Salario',
    MovementType.projectIncome => 'Cobro de proyecto',
    MovementType.otherIncome => 'Ingreso',
    MovementType.transfer => 'Transferencia',
  };
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTokens.textSecondary),
            ),
          ),
          const SizedBox(width: AppTokens.space4),
          Expanded(flex: 2, child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _AccountRow extends ConsumerWidget {
  const _AccountRow({required this.accountId, required this.label});

  final int accountId;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountBalancesProvider);
    final name = accounts.value
        ?.where((a) => a.account.id == accountId)
        .firstOrNull
        ?.account
        .name;
    return _Row(label: label, value: name ?? '—');
  }
}
